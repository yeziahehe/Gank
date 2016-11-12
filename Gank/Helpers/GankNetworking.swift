//
//  GankNetworking.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/31.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire

public struct Resource<A>: CustomStringConvertible {
    let path: String
    let method: HTTPMethod
    let requestBody: Data?
    let headers: [String: String]
    let parse: (Data) -> A?
    
    public var description: String {
        let decodeRequestBody: JSONDictionary
        if let requestBody = requestBody {
            decodeRequestBody = decodeJSON(requestBody) ?? [:]
        } else {
            decodeRequestBody = [:]
        }
        
        return "Resource(Method: \(method), path: \(path), headers: \(headers), requestBody: \(decodeRequestBody))"
    }
    
    public init(path: String, method: HTTPMethod, requestBody: Data?, headers: [String: String], parse: @escaping (Data) -> A?) {
        self.path = path
        self.method = method
        self.requestBody = requestBody
        self.headers = headers
        self.parse = parse
    }
}

public enum Reason: CustomStringConvertible {
    case couldNotParseJSON
    case noData
    case other(Error?)
    
    public var description: String {
        switch self {
        case .couldNotParseJSON:
            return "CouldNotParseJSON"
        case .noData:
            return "NoData"
        case .other(let error):
            return "Other, Error: \(error)"
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
    
    Alamofire.request(url, method: method).validate().responseJSON { response in
        if let responseData = response.data {
           if let result = resource.parse(responseData) {
                completion(result)
            } else {
                let dataString = String(data: responseData, encoding: .utf8)
                print(dataString!)
                print("\(resource)\n")
                failure(.couldNotParseJSON, "JSON 解析失败")
            }
            
        } else {
            failure(.noData, "无数据")
            print("\(resource)\n")
        }
    }
}

func isErrorInData(_ data: Data?) -> Bool {
    if let data = data {
        if let json = decodeJSON(data) {
            if let isError = json["error"] as? Bool {
                return isError
            }
        }
    }
    return true
}

func errorMessageInData(_ data: Data?) -> String? {
    if let data = data {
        if let json = decodeJSON(data) {
            if let errorMessage = json["msg"] as? String {
                return errorMessage
            }
        }
    }
    
    return nil
}

func resultsInData(_ data: Data?) -> JSONDictionary {
    if let data = data {
        if let json = decodeJSON(data) {
            if let results = json["results"] as? JSONDictionary {
                return results
            }
        }
    }
    return [:]
}

// Here are some convenience functions for dealing with JSON APIs

public typealias JSONDictionary = [String: Any]

public func decodeJSON(_ data: Data) -> JSONDictionary? {
    
    guard data.count > 0 else {
        return [:] // 允许不返回数据，只有状态码
    }
    
    guard let result = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) else {
        return nil
    }
    
    if let dictionary = result as? JSONDictionary {
        return dictionary
    } else if let array = result as? [JSONDictionary] {
        return ["data": array]
    } else {
        return nil
    }
}

public func encodeJSON(_ dict: JSONDictionary) -> Data? {
    return dict.count > 0 ? (try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())) : nil
}

public func jsonResource<A>(path: String, method: HTTPMethod, requestParameters: JSONDictionary, parse: @escaping (JSONDictionary) -> A?) -> Resource<A> {
    
    let jsonParse: (Data) -> A? = { data in
        if let json = decodeJSON(data) {
            return parse(json)
        }
        return nil
    }
    
    let jsonBody = encodeJSON(requestParameters)
    var headers = [
        "Content-Type": "application/json",
        ]
    
    let locale = Locale.autoupdatingCurrent
    if let
        languageCode = (locale as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String,
        let countryCode = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String {
        headers["Accept-Language"] = languageCode + "-" + countryCode
    }
    
    return Resource(path: path, method: method, requestBody: jsonBody, headers: headers, parse: jsonParse)
}
