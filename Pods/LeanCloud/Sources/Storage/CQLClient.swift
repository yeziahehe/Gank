//
//  CQLClient.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 5/30/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 A type represents the result value of CQL execution.
 */
public final class LCCQLValue {
    let response: LCResponse

    init(response: LCResponse) {
        self.response = response
    }

    var results: [[String: Any]] {
        return (response.results as? [[String: Any]]) ?? []
    }

    var className: String {
        return response["className"] ?? LCObject.objectClassName()
    }

    /**
     Get objects for object query.
     */
    public var objects: [LCObject] {
        let results   = self.results
        let className = self.className

        do {
            let objects = try results.map { dictionary in
                try ObjectProfiler.shared.object(dictionary: dictionary, className: className)
            }

            return objects
        } catch {
            return []
        }
    }

    /**
     Get count value for count query.
     */
    public var count: Int {
        return response.count
    }
}

/**
 CQL client.

 CQLClient allow you to use CQL (Cloud Query Language) to make CRUD for object.
 */
public final class LCCQLClient {
    static let endpoint = "cloudQuery"

    /**
     Assemble parameters for CQL execution.

     - parameter cql:        The CQL statement.
     - parameter parameters: The parameters for placeholders in CQL statement.

     - returns: The parameters for CQL execution.
     */
    static func parameters(_ cql: String, parameters: LCArrayConvertible?) -> [String: Any] {
        var result = ["cql": cql]

        if let parameters = parameters?.lcArray {
            if !parameters.isEmpty {
                result["pvalues"] = Utility.jsonString(parameters.lconValue!)
            }
        }

        return result
    }

    /**
     Execute CQL statement synchronously.

     - parameter cql:        The CQL statement to be executed.
     - parameter parameters: The parameters for placeholders in CQL statement.

     - returns: The result of CQL statement.
     */
    public static func execute(_ cql: String, parameters: LCArrayConvertible? = nil) -> LCCQLResult {
        return expect { fulfill in
            execute(cql, parameters: parameters, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Execute CQL statement asynchronously.

     - parameter cql:        The CQL statement to be executed.
     - parameter parameters: The parameters for placeholders in CQL statement.
     - parameter completion: The completion callback closure.
     */
    public static func execute(_ cql: String, parameters: LCArrayConvertible? = nil, completion: @escaping (_ result: LCCQLResult) -> Void) -> LCRequest {
        return execute(cql, parameters: parameters, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func execute(_ cql: String, parameters: LCArrayConvertible? = nil, completionInBackground completion: @escaping (LCCQLResult) -> Void) -> LCRequest {
        let parameters = self.parameters(cql, parameters: parameters)
        let request = HTTPClient.default.request(.get, endpoint, parameters: parameters) { response in
            let result = LCCQLResult(response: response)
            completion(result)
        }

        return request
    }
}
