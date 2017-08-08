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

public enum resourceMode: String {
    case url
    case json
    case auth
}

public struct Resource<A>: CustomStringConvertible {
    let path: String
    let method: HTTPMethod
    let headers: HTTPHeaders?
    let requestParameters: Parameters?
    let encoding: ParameterEncoding
    let mode: resourceMode
    let username: String?
    let password: String?
    let parse: (JSON) -> A?
    
    public var description: String {
        return "Resource(Method: \(method), path: \(path), headers: \(String(describing: headers)), requestParamters: \(String(describing: requestParameters))), resourceMode: \(mode)"
    }
    
    public init(path: String, method: HTTPMethod, headers: HTTPHeaders?, requestParameters: Parameters?, encoding: ParameterEncoding, mode: resourceMode, username: String?, password: String?, parse: @escaping (JSON) -> A?) {
        self.path = path
        self.method = method
        self.headers = headers
        self.requestParameters = requestParameters
        self.encoding = encoding
        self.mode = mode
        self.username = username
        self.password = password
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
    
    switch resource.mode {
    case .json:
        Alamofire.request(url, method: method, parameters: resource.requestParameters, encoding: resource.encoding, headers: resource.headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let result = resource.parse(JSON(value)) {
                    completion(result)
                } else {
                    failure(.couldNotParseJSON, errorMessageInData(value))
                }
            case .failure(let error):
                failure(.noData, errorMessageInData(error))
            }
        }
        return
    case .url:
        Alamofire.request(url, method: method, parameters: resource.requestParameters, encoding: resource.encoding).validate().responseJSON { response in
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
        return
    case .auth:
        Alamofire.request(url, method: method, encoding: resource.encoding, headers: resource.headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                if let errorMessage = json["message"].string {
                    failure(.error, errorMessage)
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

public func urlResource<A>(path: String, method: HTTPMethod, requestParameters: Parameters?, parse: @escaping (JSON) -> A?) -> Resource<A> {
    return Resource(path: path, method: method, headers: nil, requestParameters: requestParameters, encoding: URLEncoding.default, mode: .url, username: nil, password: nil, parse: parse)
}

public func jsonResource<A>(path: String, method: HTTPMethod, requestParameters: Parameters?, parse: @escaping (JSON) -> A?) -> Resource<A> {
    let headers = [
        "Content-Type": "application/json; charset=UTF-8",
        "X-Accept": "application/json",
        ]
    return Resource(path: path, method: method, headers: headers, requestParameters: requestParameters, encoding: JSONEncoding.default, mode: .json, username: nil, password: nil, parse: parse)
}

public func authJsonResource<A>(username: String, password: String, path: String, method: HTTPMethod, parse: @escaping (JSON) -> A?) -> Resource<A> {
//    let headers = [
//        "X-Accept": "application/json",
//        ]
    var headers: HTTPHeaders = [:]
    
    if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
        headers[authorizationHeader.key] = authorizationHeader.value
    }
    return Resource(path: path, method: method, headers: headers, requestParameters: nil, encoding: JSONEncoding.default, mode: .auth, username: username, password: password, parse: parse)
}

