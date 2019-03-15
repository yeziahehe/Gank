//
//  Engine.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 5/10/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

public final class LCEngine {
    /**
     Call LeanEngine function with parameters.

     - parameter function:   The function name.
     - parameter parameters: The parameters to be passed to remote function.

     - returns: The result of function call.
     */
    public static func call(_ function: String, parameters: LCDictionaryConvertible? = nil) -> LCValueOptionalResult {
        return expect { fulfill in
            call(function, parameters: parameters, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Call LeanEngine function with parameters asynchronously.

     - parameter function:   The function name.
     - parameter parameters: The parameters to be passed to remote function.

     - parameter completion: The completion callback closure.
     */
    public static func call(_ function: String, parameters: LCDictionaryConvertible? = nil, completion: @escaping (LCValueOptionalResult) -> Void) -> LCRequest {
        return call(function, parameters: parameters, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func call(_ function: String, parameters: LCDictionaryConvertible? = nil, completionInBackground completion: @escaping (LCValueOptionalResult) -> Void) -> LCRequest {
        let parameters = parameters?.lcDictionary.lconValue as? [String: Any]
        let request = HTTPClient.default.request(.post, "call/\(function)", parameters: parameters) { response in
            let result = LCValueOptionalResult(response: response, keyPath: "result")
            completion(result)
        }

        return request
    }

    /**
     Call LeanEngine function with parameters.

     The parameters will be serialized to JSON representation.

     - parameter function:   The function name.
     - parameter parameters: The parameters to be passed to remote function.

     - returns: The result of function call.
     */
    public static func call(_ function: String, parameters: LCObject) -> LCValueOptionalResult {
        return call(function, parameters: parameters.dictionary)
    }

    /**
     Call LeanEngine function with parameters asynchronously.

     The parameters will be serialized to JSON representation.

     - parameter function:   The function name.
     - parameter parameters: The parameters to be passed to remote function.

     - parameter completion: The completion callback closure.
     */
    public static func call(_ function: String, parameters: LCObject, completion: @escaping (LCValueOptionalResult) -> Void) -> LCRequest {
        return call(function, parameters: parameters.dictionary, completion: completion)
    }
}
