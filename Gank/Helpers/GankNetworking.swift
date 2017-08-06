//
//  GankNetworking.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/31.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Resource<A>: CustomStringConvertible {
    let path: String
    let method: HTTPMethod
    let requestParamters: Parameters?
    let parse: (JSON) -> A?
    
    public var description: String {
        return "Resource(Method: \(method), path: \(path), requestParamters: \(String(describing: requestParamters)))"
    }
    
    public init(path: String, method: HTTPMethod, requestParamters: Parameters?, parse: @escaping (JSON) -> A?) {
        self.path = path
        self.method = method
        self.requestParamters = requestParamters
        self.parse = parse
    }
}

public enum Reason: CustomStringConvertible {
    case error
    case couldNotParseJSON
    case noData
    case other(Error?)
    
    public var description: String {
        switch self {
        case .error:
            return "Error"
        case .couldNotParseJSON:
            return "CouldNotParseJSON"
        case .noData:
            return "NoData"
        case .other(let error):
            return "Other, Error: \(String(describing: error))"
        }
    }
}

public typealias FailureHandler = (_ reason: Reason, _ errorMessage: String?) -> Void

public let defaultFailureHandler: FailureHandler = { (reason, errorMessage) in
    print("\n***************************** GankNetworking Failure *****************************")
    print("Reason: \(reason)")
    if let errorMessage = errorMessage {
        print("errorMessage: >>>\(errorMessage)<<<\n")
    }
}

public func apiRequest<A>(_ modifyRequest: (URLRequest) -> (), baseURL: URL, resource: Resource<A>?, failure: FailureHandler?, completion: @escaping (A) -> Void) {
    
    let failure: FailureHandler = { (reason, errorMessage) in
        defaultFailureHandler(reason, errorMessage)
        failure?(reason, errorMessage)
    }
    
    guard let resource = resource else {
        failure(.other(nil), "No resource")
        return
    }
    
    let url = baseURL.appendingPathComponent(resource.path)
    let method = resource.method
        
    Alamofire.request(url, method: method, parameters:resource.requestParamters).validate().responseJSON { response in
        switch response.result {
        case .success(let value):
            let error = isErrorInData(value)
            if error {
                failure(.error, errorMessageInData(value))
            } else {
                if let result = resource.parse(JSON(value)) {
                    completion(result)
                } else {
                    failure(.couldNotParseJSON, errorMessageInData(value))
                }
            }
        case .failure(let error):
            failure(.noData, errorMessageInData(error))
        }
    }
}

func isErrorInData(_ data: Any) -> Bool {
    let json = JSON(data)
    if let isError = json["error"].bool {
        return isError
    }
    return true
}

func errorMessageInData(_ data: Any) -> String? {
    let json = JSON(data)
    if let errorMessage = json["msg"].string {
        return errorMessage
    }
    return nil
}
