//
//  ObjectProfiler.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/23/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

extension LCError {

    static let circularReference = LCError(
        code: .inconsistency,
        reason: "Circular reference.")

}

class ObjectProfiler {
    private init() {
        registerClasses()
    }

    static let shared = ObjectProfiler()

    /// Registered object class table indexed by class name.
    var objectClassTable: [String: LCObject.Type] = [:]

    /**
     Property list table indexed by synthesized class identifier number.

     - note: Any properties declared by superclass are not included in each property list.
     */
    var propertyListTable: [UInt: [objc_property_t]] = [:]

    /**
     Register an object class.

     - parameter aClass: The object class to be registered.
     */
    func registerClass(_ aClass: LCObject.Type) {
        synthesizeProperty(aClass)
        cache(objectClass: aClass)
    }

    /**
     Synthesize all non-computed properties for object class.

     - parameter aClass: The object class need to be synthesized.
     */
    func synthesizeProperty(_ aClass: LCObject.Type) {
        let properties = synthesizableProperties(aClass)
        properties.forEach { synthesizeProperty($0, aClass) }
        cache(properties: properties, aClass)
    }

    /**
     Cache an object class.

     - parameter aClass: The class to be cached.
     */
    func cache(objectClass: LCObject.Type) {
        objectClassTable[objectClass.objectClassName()] = objectClass
    }

    /**
     Cache a property list.

     - parameter properties: The property list to be cached.
     - parameter aClass:     The class of property list.
     */
    func cache(properties: [objc_property_t], _ aClass: AnyClass) {
        propertyListTable[UInt(bitPattern: ObjectIdentifier(aClass))] = properties
    }

    /**
     Register object classes.

     This method will scan the loaded classes list at runtime to find out object classes.

     - note: When subclass and superclass have the same class name,
             subclass will be registered for the class name.
     */
    func registerClasses() {
        /* Only register builtin classes. */
        let builtinClasses = [LCObject.self, LCRole.self, LCUser.self, LCFile.self, LCInstallation.self]

        builtinClasses.forEach { type in
            registerClass(type)
        }
    }

    /**
     Find all synthesizable properties of object class.

     A synthesizable property must satisfy following conditions:

     * It is a non-computed property.
     * It is a LeanCloud data type property.

     - note: Any synthesizable properties declared by superclass are not included.

     - parameter aClass: The object class.

     - returns: An array of synthesizable properties.
     */
    func synthesizableProperties(_ aClass: LCObject.Type) -> [objc_property_t] {
        return Runtime.nonComputedProperties(aClass).filter { hasLCValue($0) }
    }

    /**
     Check whether a property has LeanCloud data type.

     - parameter property: Target property.

     - returns: true if property type has LeanCloud data type, false otherwise.
     */
    func hasLCValue(_ property: objc_property_t) -> Bool {
        return getLCValue(property) != nil
    }

    /**
     Get concrete LCValue subclass of property.

     - parameter property: The property to be inspected.

     - returns: Concrete LCValue subclass, or nil if property type is not LCValue.
     */
    func getLCValue(_ property: objc_property_t) -> LCValue.Type? {

        guard let typeEncoding: String = Runtime.typeEncoding(property) else {
            return nil
        }
        
        guard typeEncoding.hasPrefix("@\"") else {
            return nil
        }

        let startIndex: String.Index = typeEncoding.index(typeEncoding.startIndex, offsetBy: 2)
        let endIndex: String.Index = typeEncoding.index(typeEncoding.endIndex, offsetBy: -1)
        let name: Substring = typeEncoding[startIndex..<endIndex]

        if let subclass = objc_getClass(String(name)) as? AnyClass {
            if let type = subclass as? LCValue.Type {
                return type
            }
        }

        return nil
    }

    /**
     Get concrete LCValue subclass of an object property.

     - parameter object:       Target object.
     - parameter propertyName: The name of property to be inspected.

     - returns: Concrete LCValue subclass, or nil if property type is not LCValue.
     */
    func getLCValue(_ object: LCObject, _ propertyName: String) -> LCValue.Type? {
        let property = class_getProperty(object_getClass(object), propertyName)

        if property != nil {
            return getLCValue(property!)
        } else {
            return nil
        }
    }

    /**
     Check if object has a property of type LCValue for given name.

     - parameter object:       Target object.
     - parameter propertyName: The name of property to be inspected.

     - returns: true if object has a property of type LCValue for given name, false otherwise.
     */
    func hasLCValue(_ object: LCObject, _ propertyName: String) -> Bool {
        return getLCValue(object, propertyName) != nil
    }

    /**
     Synthesize a single property for class.

     - parameter property: Property which to be synthesized.
     - parameter aClass:   Class of property.
     */
    func synthesizeProperty(_ property: objc_property_t, _ aClass: AnyClass) {
        let getterName = Runtime.propertyName(property)
        let setterName = "set\(getterName.firstUppercaseString):"

        class_replaceMethod(aClass, Selector(getterName), unsafeBitCast(self.propertyGetter, to: IMP.self), "@@:")
        class_replaceMethod(aClass, Selector(setterName), unsafeBitCast(self.propertySetter, to: IMP.self), "v@:@")
    }

    /**
     Iterate all object properties of type LCValue.

     - parameter object: The object to be inspected.
     - parameter body:   The body for each iteration.
     */
    func iterateProperties(_ object: LCObject, body: (String, objc_property_t) -> Void) {
        var visitedKeys: Set<String> = []
        var aClass: AnyClass? = object_getClass(object)

        repeat {
            guard aClass != nil else { return }

            let properties = propertyListTable[UInt(bitPattern: ObjectIdentifier(aClass!))]

            properties?.forEach { property in
                let key = Runtime.propertyName(property)

                if !visitedKeys.contains(key) {
                    visitedKeys.insert(key)
                    body(key, property)
                }
            }

            aClass = class_getSuperclass(aClass)
        } while aClass != LCObject.self
    }

    /**
     Get deepest descendant newborn orphan objects of an object recursively.

     - parameter object:  The root object.
     - parameter parent:  The parent object for each iteration.
     - parameter visited: The visited objects.
     - parameter output:  A set of deepest descendant newborn orphan objects.

     - returns: true if object has newborn orphan object, false otherwise.
     */
    @discardableResult
    func deepestNewbornOrphans(_ object: LCValue, parent: LCValue?, output: inout Set<LCObject>) -> Bool {
        var hasNewbornOrphan = false

        switch object {
        case let object as LCObject:
            object.forEachChild { child in
                if deepestNewbornOrphans(child, parent: object, output: &output) {
                    hasNewbornOrphan = true
                }
            }

            /* Check if object is a newborn orphan.
               If parent is not an LCObject, we think that it is an orphan. */
            if !object.hasObjectId && !(parent is LCObject) {
                if !hasNewbornOrphan {
                    output.insert(object)
                }

                hasNewbornOrphan = true
            }
        default:
            (object as! LCValueExtension).forEachChild { child in
                if deepestNewbornOrphans(child, parent: object, output: &output) {
                    hasNewbornOrphan = true
                }
            }
        }

        return hasNewbornOrphan
    }

    /**
     Get deepest descendant newborn orphan objects.

     - parameter objects: An array of root object.

     - returns: A set of deepest descendant newborn orphan objects.
     */
    func deepestNewbornOrphans(_ objects: [LCObject]) -> [LCObject] {
        var result: [LCObject] = []

        objects.forEach { object in
            var output: Set<LCObject> = []

            deepestNewbornOrphans(object, parent: nil, output: &output)
            output.remove(object)

            result.append(contentsOf: Array(output))
        }

        return result
    }

    private enum VisitState: Int {

        case unvisited
        case visiting
        case visited

    }

    /**
     Get toposort of objects.

     - parameter objects: An array of objects need to be sorted.

     - returns: An toposort of objects.
     */
    func toposort(_ objects: [LCObject]) throws -> [LCObject] {
        var result: [LCObject] = []
        var visitStateTable: [Int: VisitState] = [:]

        try toposortStart(objects.unique, &result, &visitStateTable)

        return result.unique
    }

    private func toposortStart(_ objects: [LCObject], _ result: inout [LCObject], _ visitStateTable: inout [Int: VisitState]) throws {
        try objects.forEach { object in
            try toposortVisit(object, objects, &result, &visitStateTable)
        }
    }

    private func toposortVisit(_ value: LCValue, _ objects: [LCObject], _ result: inout [LCObject], _ visitStateTable: inout [Int: VisitState]) throws {
        guard let value = value as? LCValueExtension else {
            return
        }

        guard let object = value as? LCObject else {
            try value.forEachChild { child in
                try toposortVisit(child, objects, &result, &visitStateTable)
            }
            return
        }

        let key = ObjectIdentifier(object).hashValue
        let visitState = visitStateTable[key] ?? .unvisited

        switch visitState {
        case .unvisited:
            visitStateTable[key] = .visiting
            try object.forEachChild { child in
                try toposortVisit(child, objects, &result, &visitStateTable)
            }
            visitStateTable[key] = .visited

            if objects.contains(object) {
                result.append(object)
            }
        case .visiting:
            throw LCError.circularReference
        case .visited:
            break
        }
    }

    /**
     Get all objects of object family.

     - parameter objects: An array of objects.

     - returns: An array of objects in family.
     */
    func family(_ objects: [LCObject]) throws -> [LCObject] {
        var result: [LCObject] = []
        var visitStateTable: [Int: VisitState] = [:]

        try familyVisit(objects.unique, &result, &visitStateTable)

        return result.unique
    }

    private func familyVisit(_ objects: [LCObject], _ result: inout [LCObject], _ visitStateTable: inout [Int: VisitState]) throws {
        try objects.forEach { try familyVisit($0, &result, &visitStateTable) }
    }

    private func familyVisit(_ value: LCValue, _ result: inout [LCObject], _ visitStateTable: inout [Int: VisitState]) throws {
        guard let value = value as? LCValueExtension else {
            return
        }

        guard let object = value as? LCObject else {
            try value.forEachChild { child in
                try familyVisit(child, &result, &visitStateTable)
            }
            return
        }

        let key = ObjectIdentifier(object).hashValue
        let visitState = visitStateTable[key] ?? .unvisited

        switch visitState {
        case .unvisited:
            visitStateTable[key] = .visiting
            try object.forEachChild { child in
                try familyVisit(child, &result, &visitStateTable)
            }
            visitStateTable[key] = .visited
            result.append(object)
        case .visiting:
            throw LCError.circularReference
        case .visited:
            break
        }
    }

    /**
     Validate circular reference in object graph.

     This method will check object and its all descendant objects.

     - parameter objects: The objects to validate.
     */
    func validateCircularReference(_ objects: [LCObject]) throws {
        var visitStateTable: [Int: VisitState] = [:]

        try objects.unique.forEach { object in
            try validateCircularReference(object, &visitStateTable)
        }
    }

    /**
     Validate circular reference in object graph iteratively.

     - parameter value: The value to validate.
     - parameter visitStateTable: The visit state table.
     */
    private func validateCircularReference(_ value: LCValue, _ visitStateTable: inout [Int: VisitState]) throws {
        guard let value = value as? LCValueExtension else {
            return
        }

        guard let object = value as? LCObject else {
            try value.forEachChild { child in
                try validateCircularReference(child, &visitStateTable)
            }
            return
        }

        let key = ObjectIdentifier(object).hashValue
        let visitState = visitStateTable[key] ?? .unvisited

        switch visitState {
        case .unvisited:
            visitStateTable[key] = .visiting
            try object.forEachChild { child in
                try validateCircularReference(child, &visitStateTable)
            }
            visitStateTable[key] = .visited
        case .visiting:
            throw LCError.circularReference
        case .visited:
            break
        }
    }

    /**
     Check whether value is a boolean.

     - parameter jsonValue: The value to check.

     - returns: true if value is a boolean, false otherwise.
     */
    func isBoolean(_ jsonValue: Any) -> Bool {
        switch String(describing: type(of: jsonValue)) {
        case "__NSCFBoolean", "Bool": return true
        default: return false
        }
    }

    /**
     Get object class by name.

     - parameter className: The name of object class.

     - returns: The class.
     */
    func objectClass(_ className: String) -> LCObject.Type? {
        return objectClassTable[className]
    }

    /**
     Create LCObject object for class name.

     - parameter className: The class name of LCObject type.

     - returns: An LCObject object for class name.
     */
    func object(className: String) -> LCObject {
        if let objectClass = objectClass(className) {
            return objectClass.init()
        } else {
            return LCObject(className: className)
        }
    }

    /**
     Convert a dictionary to an object with specified class name.

     - parameter dictionary: The source dictionary to be converted.
     - parameter className:  The object class name.

     - returns: An LCObject object.
     */
    func object(dictionary: [String: Any], className: String) throws -> LCObject {
        let result = object(className: className)
        let keyValues = try dictionary.compactMapValue { try object(jsonValue: $0) }

        keyValues.forEach { (key, value) in
            result.update(key, value)
        }

        return result
    }

    /**
     Convert a dictionary to an object of specified data type.

     - parameter dictionary: The source dictionary to be converted.
     - parameter dataType:   The data type.

     - returns: An LCValue object, or nil if object can not be decoded.
     */
    func object(dictionary: [String: Any], dataType: HTTPClient.DataType) throws -> LCValue? {
        switch dataType {
        case .object,
             .pointer:
            let className = dictionary["className"] as? String ?? LCObject.objectClassName()
            return try object(dictionary: dictionary, className: className)
        case .relation:
            return LCRelation(dictionary: dictionary)
        case .geoPoint:
            return LCGeoPoint(dictionary: dictionary)
        case .bytes:
            return LCData(dictionary: dictionary)
        case .date:
            return LCDate(dictionary: dictionary)
        case .file:
            return try object(dictionary: dictionary, className: LCFile.objectClassName())
        }
    }

    /**
     Convert a dictionary to an LCValue object.

     - parameter dictionary: The source dictionary to be converted.

     - returns: An LCValue object.
     */
    private func object(dictionary: [String: Any]) throws -> LCValue {
        var result: LCValue!

        if let type = dictionary["__type"] as? String {
            if let dataType = HTTPClient.DataType(rawValue: type) {
                result = try object(dictionary: dictionary, dataType: dataType)
            }
        }

        if result == nil {
            result = LCDictionary(try dictionary.compactMapValue { try object(jsonValue: $0) })
        }

        return result
    }

    /**
     Convert JSON value to LCValue object.

     - parameter jsonValue: The JSON value.

     - returns: An LCValue object of the corresponding JSON value.
     */
    func object(jsonValue: Any) throws -> LCValue {
        switch jsonValue {
        /* Note: a bool is also a number, we must match it first. */
        case let bool where isBoolean(bool):
            return LCBool(bool as! Bool)
        case let number as NSNumber:
            return LCNumber(number.doubleValue)
        case let string as String:
            return LCString(string)
        case let array as [Any]:
            return LCArray(try array.map { try object(jsonValue: $0) })
        case let dictionary as [String: Any]:
            return try object(dictionary: dictionary)
        case let data as Data:
            return LCData(data)
        case let date as Date:
            return LCDate(date)
        case is NSNull:
            return LCNull()
        case let object as LCValue:
            return object
        default:
            break
        }

        throw LCError(code: .invalidType, reason: "Unrecognized object.")
    }

    /**
     Convert an object object to JSON value.

     - parameter object: The object to be converted.

     - returns: The JSON value of object.
     */
    func lconValue(_ object: Any) -> Any? {
        switch object {
        case let array as [Any]:
            return array.compactMap { lconValue($0) }
        case let dictionary as [String: Any]:
            return dictionary.compactMapValue { lconValue($0) }
        case let object as LCValue:
            return (object as? LCValueExtension)?.lconValue
        case let query as LCQuery:
            return query.lconValue
        default:
            return object
        }
    }

    /**
     Update object with a dictionary.

     - parameter object:     The object to be updated.
     - parameter dictionary: A dictionary of key-value pairs.
     */
    func updateObject(_ object: LCObject, _ dictionary: [String: Any]) {
        dictionary.forEach { (key, value) in
            object.update(key, try! self.object(jsonValue: value))
        }
    }

    /**
     Get property name from a setter selector.

     - parameter selector: The setter selector.

     - returns: A property name correspond to the setter selector.
     */
    func propertyName(_ setter: Selector) -> String {
        var propertyName = NSStringFromSelector(setter)
        
        let startIndex: String.Index = propertyName.index(propertyName.startIndex, offsetBy: 3)
        let endIndex: String.Index = propertyName.index(propertyName.endIndex, offsetBy: -1)
        propertyName = String(propertyName[startIndex..<endIndex])

        return propertyName
    }

    /**
     Get property value for given name from an object.

     - parameter object:       The object that owns the property.
     - parameter propertyName: The property name.

     - returns: The property value, or nil if such a property not found.
     */
    func propertyValue(_ object: LCObject, _ propertyName: String) -> LCValue? {
        guard hasLCValue(object, propertyName) else {
            return nil
        }

        return Runtime.instanceVariableValue(object, propertyName) as? LCValue
    }

    /**
     Getter implementation of LeanCloud data type property.
     */
    let propertyGetter: @convention(c) (LCObject, Selector) -> Any? = {
        (object: LCObject, cmd: Selector) -> Any? in
        let key = NSStringFromSelector(cmd)
        return object.get(key)
    }

    /**
     Setter implementation of LeanCloud data type property.
     */
    let propertySetter: @convention(c) (LCObject, Selector, Any?) -> Void = {
        (object: LCObject, cmd: Selector, value: Any?) -> Void in
        let key = ObjectProfiler.shared.propertyName(cmd)
        let value = value as? LCValue

        if ObjectProfiler.shared.getLCValue(object, key) == nil {
            try? object.set(key.firstLowercaseString, lcValue: value)
        } else {
            try? object.set(key, lcValue: value)
        }
    }
}
