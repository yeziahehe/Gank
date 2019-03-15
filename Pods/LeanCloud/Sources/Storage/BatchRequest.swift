//
//  BatchRequest.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/22/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

class BatchRequest {
    let object: LCObject
    let method: HTTPClient.Method?
    let operationTable: OperationTable?

    init(object: LCObject, method: HTTPClient.Method? = nil, operationTable: OperationTable? = nil) {
        self.object = object
        self.method = method
        self.operationTable = operationTable
    }

    var isNewborn: Bool {
        return !object.hasObjectId
    }

    var actualMethod: HTTPClient.Method {
        return method ?? (isNewborn ? .post : .put)
    }

    func getBody(internalId: String) -> [String: Any] {
        var body: [String: Any] = [:]

        body["__internalId"] = internalId

        var children: [(String, LCObject)] = []

        operationTable?.forEach { (key, operation) in
            switch operation.name {
            case .set:
                /* If object is newborn, put it in __children field. */
                if let child = operation.value as? LCObject {
                    if !child.hasObjectId {
                        children.append((key, child))
                        break
                    }
                }

                body[key] = operation.lconValue
            default:
                body[key] = operation.lconValue
            }
        }

        if children.count > 0 {
            var list: [Any] = []

            children.forEach { (key, child) in
                list.append([
                    "className": child.actualClassName,
                    "cid": child.internalId,
                    "key": key
                ])
            }

            body["__children"] = list
        }

        return body
    }

    func jsonValue() throws -> Any {
        let method = actualMethod
        let path = try HTTPClient.default.getBatchRequestPath(object: object, method: method)
        let internalId = object.objectId?.value ?? object.internalId

        if let request = try object.preferredBatchRequest(method: method, path: path, internalId: internalId) {
            return request
        }

        var request: [String: Any] = [
            "path": path,
            "method": method.rawValue
        ]

        switch method {
        case .get:
            break
        case .post, .put:
            request["body"] = getBody(internalId: internalId)

            if isNewborn {
                request["new"] = true
            }
        case .delete:
            break
        }

        return request
    }
}

class BatchRequestBuilder {
    /**
     Get a list of requests of an object.

     - parameter object: The object from which you want to get.

     - returns: A list of request.
     */
    static func buildRequests(_ object: LCObject) -> [BatchRequest] {
        return operationTableList(object).map { element in
            BatchRequest(object: object, operationTable: element)
        }
    }

    /**
     Get initial operation table list of an object.

     - parameter object: The object from which to get.

     - returns: The operation table list.
     */
    private static func initialOperationTableList(_ object: LCObject) -> OperationTableList {
        var operationTable: OperationTable = [:]

        /* Collect all non-null properties. */
        object.forEach { (key, value) in
            switch value {
            case let relation as LCRelation:
                /* If the property type is relation,
                   We should use "AddRelation" instead of "Set" as operation type.
                   Otherwise, the relations will added as an array. */
                operationTable[key] = Operation(name: .addRelation, key: key, value: LCArray(relation.value))
            default:
                operationTable[key] = Operation(name: .set, key: key, value: value)
            }
        }

        return [operationTable]
    }

    /**
     Get operation table list of object.

     - parameter object: The object from which you want to get.

     - returns: A list of operation tables.
     */
    private static func operationTableList(_ object: LCObject) -> OperationTableList {
        if object.hasObjectId {
            return object.operationHub.operationTableList()
        } else {
            return initialOperationTableList(object)
        }
    }
}
