//
//  Operation.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/25/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 Operation.

 Used to present an action of object update.
 */
class Operation {
    /**
     Operation Name.
     */
    enum Name: String {
        case set            = "Set"
        case delete         = "Delete"
        case increment      = "Increment"
        case add            = "Add"
        case addUnique      = "AddUnique"
        case remove         = "Remove"
        case addRelation    = "AddRelation"
        case removeRelation = "RemoveRelation"
    }

    let name: Name
    let key: String
    let value: LCValue?

    required init(name: Name, key: String, value: LCValue?) {
        try! Operation.validateKey(key)

        self.name  = name
        self.key   = key
        self.value = value?.copy(with: nil) as? LCValue
    }

    /**
     The LCON representation of operation.
     */
    var lconValue: Any? {
        let lconValue = (value as? LCValueExtension)?.lconValue

        switch name {
        case .set:
            return lconValue
        case .delete:
            return [
                "__op": name.rawValue
            ]
        case .increment:
            guard let lconValue = lconValue else {
                return nil
            }
            return [
                "__op": name.rawValue,
                "amount": lconValue
            ]
        case .add,
             .addUnique,
             .addRelation,
             .remove,
             .removeRelation:
            guard let lconValue = lconValue else {
                return nil
            }
            return [
                "__op": name.rawValue,
                "objects": lconValue
            ]
        }
    }

    /**
     Validate the column name of object.

     - parameter key: The key you want to validate.

     - throws: A MalformedData error if key is invalid.
     */
    static func validateKey(_ key: String) throws {
        let options: NSString.CompareOptions = [
            .regularExpression,
            .caseInsensitive
        ]

        guard key.range(of: "^[a-z0-9][a-z0-9_]*$", options: options) != nil else {
            throw LCError(code: .malformedData, reason: "Malformed key.", userInfo: ["key": key])
        }
    }

    static func reducerType(_ type: LCValue.Type) -> OperationReducer.Type {
        switch type {
        case _ where type === LCArray.self:
            return OperationReducer.Array.self

        case _ where type === LCNumber.self:
            return OperationReducer.Number.self

        case _ where type === LCRelation.self:
            return OperationReducer.Relation.self

        default:
            return OperationReducer.Key.self
        }
    }

    var reducerType: OperationReducer.Type? {
        switch name {
        case .set:
            return Operation.reducerType(type(of: value!))
        case .delete:
            return nil
        case .add,
             .addUnique,
             .remove:
            return OperationReducer.Array.self
        case .increment:
            return OperationReducer.Number.self
        case .addRelation,
             .removeRelation:
            return OperationReducer.Relation.self
        }
    }
}

typealias OperationStack     = [String:[Operation]]
typealias OperationTable     = [String:Operation]
typealias OperationTableList = [OperationTable]

/**
 Operation hub.

 Used to manage a batch of operations.
 */
class OperationHub {
    weak var object: LCObject!

    /// The table of operation reducers indexed by operation key.
    var operationReducerTable: [String: OperationReducer] = [:]

    /// The table of unreduced operations indexed by operation key.
    var unreducedOperationTable: [String: Operation] = [:]

    /// Return true iff operation hub has no operations.
    var isEmpty: Bool {
        return operationReducerTable.isEmpty && unreducedOperationTable.isEmpty
    }

    init(_ object: LCObject) {
        self.object = object
    }

    /**
     Reduce an operation.

     - parameter operation: The operation which you want to reduce.
     */
    func reduce(_ operation: Operation) {
        let key = operation.key
        let operationReducer = operationReducerTable[key]

        if let operationReducer = operationReducer {
            try! operationReducer.reduce(operation)
        } else if let operationReducerType = operationReducerType(operation) {
            let operationReducer = operationReducerType.init()

            operationReducerTable[key] = operationReducer

            if let unreducedOperation = unreducedOperationTable[key] {
                unreducedOperationTable.removeValue(forKey: key)
                try! operationReducer.reduce(unreducedOperation)
            }

            try! operationReducer.reduce(operation)
        } else {
            unreducedOperationTable[key] = operation
        }
    }

    /**
     Get operation reducer type for operation.

     - parameter operation: The operation object.

     - returns: Operation reducer type, or nil if not found.
     */
    func operationReducerType(_ operation: Operation) -> OperationReducer.Type? {
        let propertyName = operation.key
        let propertyType = ObjectProfiler.shared.getLCValue(object, propertyName)

        if let propertyType = propertyType {
            return Operation.reducerType(propertyType)
        } else {
            return operation.reducerType
        }
    }

    /**
     Get an operation stack.

     The operation stack is a structure that maps operation key to a list of operations.

     - returns: An operation stack indexed by property key.
     */
    func operationStack() -> OperationStack {
        var operationStack: OperationStack = [:]

        operationReducerTable.forEach { (key, operationReducer) in
            let operations = operationReducer.operations()

            if operations.count > 0 {
                operationStack[key] = operations
            }
        }

        unreducedOperationTable.forEach { (key, operation) in
            operationStack[key] = [operation]
        }

        return operationStack
    }

    /**
     Extract an operation table from an operation stack.

     - parameter operationStack: An operation stack from which the operation table will be extracted.

     - returns: An operation table, or nil if no operations can be extracted.
     */
    func extractOperationTable(_ operationStack: inout OperationStack) -> OperationTable? {
        var table: OperationTable = [:]

        operationStack.forEach { (key, operations) in
            if operations.isEmpty {
                operationStack.removeValue(forKey: key)
            } else {
                table[key] = operations.first
                operationStack[key] = Array(operations[1..<operations.count])
            }
        }

        return table.isEmpty ? nil : table
    }

    /**
     Get an operation table list.

     Operation table list is flat version of operation stack.
     When a key has two or more operations in operation stack,
     each operation will be extracted to each operation table in an operation table list.

     For example, `["foo":[op1,op2]]` will extracted as `[["foo":op1],["foo":op2]]`.

     The reason for making this transformation is that one request should
     not contain multiple operations on one key.

     - returns: An operation table list.
     */
    func operationTableList() -> OperationTableList {
        var list: OperationTableList = []
        var operationStack = self.operationStack()

        while !operationStack.isEmpty {
            if let operationTable = extractOperationTable(&operationStack) {
                list.append(operationTable)
            }
        }

        return list
    }

    /**
     Remove all operations.
     */
    func reset() {
        operationReducerTable = [:]
        unreducedOperationTable = [:]
    }
}

/**
 Operation reducer.

 Operation reducer is used to reduce operations to remove redundancy.
 */
class OperationReducer {
    required init() {
        /* Stub method. */
    }

    class func validOperationNames() -> [Operation.Name] {
        return []
    }

    /**
     Validate operation.

     - parameter operation: The operation to validate.
     */
    func validate(_ operation: Operation) throws {
        let operationNames = type(of: self).validOperationNames()

        guard operationNames.contains(operation.name) else {
            throw LCError(code: .invalidType, reason: "Invalid operation type.", userInfo: nil)
        }
    }

    /**
     Reduce another operation.

     - parameter operation: The operation to be reduced.
     */
    func reduce(_ operation: Operation) throws {
        throw LCError(code: .invalidType, reason: "Operation cannot be reduced.", userInfo: nil)
    }

    /**
     Get all reduced operations.

     - returns: An array of reduced operations.
     */
    func operations() -> [Operation] {
        return []
    }

    /**
     Key oriented operation.

     It only accepts following operations:

     - SET
     - DELETE
     */
    class Key: OperationReducer {
        var operation: Operation?

        override class func validOperationNames() -> [Operation.Name] {
            return [.set, .delete]
        }

        override func reduce(_ operation: Operation) {
            try! super.validate(operation)

            /* SET or DELETE will always override the previous. */
            self.operation = operation
        }

        override func operations() -> [Operation] {
            return (operation != nil) ? [operation!] : []
        }
    }

    /**
     Number oriented operation.

     It only accepts following operations:

     - SET
     - DELETE
     - INCREMENT
     */
    class Number: OperationReducer {
        var operation: Operation?

        override class func validOperationNames() -> [Operation.Name] {
            return [.set, .delete, .increment]
        }

        override func reduce(_ operation: Operation) {
            try! super.validate(operation)

            if let previousOperation = self.operation {
                self.operation = reduce(operation, previousOperation: previousOperation)
            } else {
                self.operation = operation
            }
        }

        func reduce(_ operation: Operation, previousOperation: Operation) -> Operation? {
            let lhs = previousOperation
            let rhs = operation

            switch (lhs.name, rhs.name) {
            case (.set,       .set):       return rhs
            case (.delete,    .set):       return rhs
            case (.increment, .set):       return rhs
            case (.set,       .delete):    return rhs
            case (.delete,    .delete):    return rhs
            case (.increment, .delete):    return rhs
            case (.set,       .increment): return Operation(name: .set,       key: operation.key, value: try! (lhs.value as! LCValueExtension).add(rhs.value!))
            case (.delete,    .increment): return Operation(name: .set,       key: operation.key, value: rhs.value)
            case (.increment, .increment): return Operation(name: .increment, key: operation.key, value: try! (lhs.value as! LCValueExtension).add(rhs.value!))
            default:                       return nil
            }
        }

        override func operations() -> [Operation] {
            return (operation != nil) ? [operation!] : []
        }
    }

    /**
     Array oriented operation.

     It only accepts following operations:

     - SET
     - DELETE
     - ADD
     - ADDUNIQUE
     - REMOVE
     */
    class Array: OperationReducer {
        var operationTable: [Operation.Name:Operation] = [:]

        override class func validOperationNames() -> [Operation.Name] {
            return [.set, .delete, .add, .addUnique, .remove]
        }

        override func reduce(_ operation: Operation) {
            try! super.validate(operation)

            switch operation.name {
            case .set:
                reset()
                setOperation(operation)
            case .delete:
                reset()
                setOperation(operation)
            case .add:
                removeObjects(operation, .remove)
                removeObjects(operation, .addUnique)

                if hasOperation(.set) || hasOperation(.delete) {
                    addObjects(operation, .set)
                } else {
                    addObjects(operation, .add)
                }
            case .addUnique:
                removeObjects(operation, .add)
                removeObjects(operation, .remove)

                if hasOperation(.set) || hasOperation(.delete) {
                    addObjects(operation, .set, unique: true)
                } else {
                    addObjects(operation, .addUnique, unique: true)
                }
            case .remove:
                removeObjects(operation, .set)
                removeObjects(operation, .add)
                removeObjects(operation, .addUnique)

                addObjects(operation, .remove, unique: true)
            default:
                break
            }
        }

        override func operations() -> [Operation] {
            var operationTable = self.operationTable
            removeEmptyOperation(&operationTable, [.add, .addUnique, .remove])
            return Swift.Array(operationTable.values)
        }

        /**
         Remove empty operations from operation table.

         - parameter operationTable: The operation table.
         - parameter operationNames: A set of operation names that specify which operation should be removed from operation table if it is empty.
         */
        func removeEmptyOperation(_ operationTable: inout [Operation.Name:Operation], _ operationNames:Set<Operation.Name>) {
            operationNames.forEach { (operationName) in
                if let operation = operationTable[operationName] {
                    if !hasObjects(operation) {
                        operationTable[operationName] = nil
                    }
                }
            }
        }

        /**
         Check whether an operation has objects.

         - parameter operation: The operation.

         - returns: true if operation has objects, false otherwise.
         */
        func hasObjects(_ operation: Operation) -> Bool {
            if let array = operation.value as? LCArray {
                return !array.value.isEmpty
            } else {
                return false
            }
        }

        /**
         Check whether an operation existed for given operation name.

         - parameter name: The operation name.

         - returns: true if operation existed for operation name, false otherwise.
         */
        func hasOperation(_ name: Operation.Name) -> Bool {
            return operationTable[name] != nil
        }

        /**
         Remove objects from operation specified by operation name.

         - parameter operation:     The operation that contains objects to be removed.
         - parameter operationName: The operation name that specifies operation from which the objects will be removed.
         */
        func removeObjects(_ operation: Operation, _ operationName: Operation.Name) {
            guard let rhs = operation.value as? LCArray else {
                return
            }
            guard let lhs = operationTable[operationName]?.value as? LCArray else {
                return
            }

            let operation = Operation(name: operation.name, key: operation.key, value: try! lhs.differ(rhs))

            setOperation(operation)
        }

        /**
         Add objects in an operation from operation specified by operation name.

         - parameter operation:     The operation that contains objects to be removed.
         - parameter operationName: The operation name that specifies operation from which the objects will be removed.
         */
        func addObjects(_ operation: Operation, _ operationName: Operation.Name, unique: Bool = false) {
            guard var value = operation.value else {
                return
            }

            if let baseValue = operationTable[operationName]?.value as? LCArray {
                value = try! baseValue.concatenate(value, unique: unique)
            }

            let operation = Operation(name: operationName, key: operation.key, value: value)

            setOperation(operation)
        }

        /**
         Set operation to operation table.

         - parameter operation: The operation to set.
         */
        func setOperation(_ operation: Operation) {
            self.operationTable[operation.name] = operation
        }

        /**
         Reset operation table.
         */
        func reset() {
            self.operationTable = [:]
        }
    }

    /**
     Relation oriented operation.

     It only accepts following operations:

     - ADDRELATION
     - REMOVERELATION
     */
    class Relation: Array {
        override class func validOperationNames() -> [Operation.Name] {
            return [.addRelation, .removeRelation]
        }

        override func reduce(_ operation: Operation) {
            try! super.validate(operation)

            switch operation.name {
            case .addRelation:
                removeObjects(operation, .removeRelation)
                addObjects(operation, .addRelation)
            case .removeRelation:
                removeObjects(operation, .addRelation)
                addObjects(operation, .removeRelation, unique: true)
            default:
                break
            }
        }
        /* Stub class. */
    }
}
