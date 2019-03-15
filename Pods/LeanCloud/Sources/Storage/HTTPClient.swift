//
//  HTTPClient.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/30/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation
import Alamofire

/**
 LeanCloud REST client.

 This class manages requests for LeanCloud REST API.
 */
class HTTPClient {
    /// HTTP Method.
    enum Method: String {
        case get
        case post
        case put
        case delete

        /// Get Alamofire corresponding method
        var alamofireMethod: Alamofire.HTTPMethod {
            switch self {
            case .get:    return .get
            case .post:   return .post
            case .put:    return .put
            case .delete: return .delete
            }
        }
    }

    /// Data type.
    enum DataType: String {
        case object   = "Object"
        case pointer  = "Pointer"
        case relation = "Relation"
        case geoPoint = "GeoPoint"
        case bytes    = "Bytes"
        case date     = "Date"
        case file     = "File"
    }

    /// Header field name.
    class HeaderFieldName {
        static let id         = "X-LC-Id"
        static let signature  = "X-LC-Sign"
        static let session    = "X-LC-Session"
        static let production = "X-LC-Prod"
        static let userAgent  = "User-Agent"
        static let accept     = "Accept"
    }

    /**
     HTTPClient configuration.
     */
    struct Configuration {

        let userAgent: String

        /// Default timeout interval for request. If not given, defaults to 60 seconds.
        let defaultTimeoutInterval: TimeInterval?

        static let `default` = Configuration(
            userAgent: "LeanCloud-Swift-SDK/\(LeanCloud.version)",
            defaultTimeoutInterval: nil)

    }

    static let `default` = HTTPClient(application: .default, configuration: .default)

    let application: LCApplication

    let configuration: Configuration

    init(application: LCApplication, configuration: Configuration) {
        self.application = application
        self.configuration = configuration
    }

    lazy var router = HTTPRouter(application: application, configuration: .default)

    lazy var sessionManager: SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default

        if let defaultTimeoutInterval = configuration.defaultTimeoutInterval {
            sessionConfiguration.timeoutIntervalForRequest = defaultTimeoutInterval
        }

        let sessionManager = SessionManager(configuration: sessionConfiguration)

        return sessionManager
    }()

    /// Default completion dispatch queue.
    let defaultCompletionDispatchQueue = DispatchQueue(label: "LeanCloud.HTTPClient.Completion", attributes: .concurrent)

    /// Create a signature for request.
    func createRequestSignature() -> String {
        let timestamp = String(format: "%.0f", 1000 * Date().timeIntervalSince1970)
        let hash = (timestamp + application.key).md5.lowercased()

        return "\(hash),\(timestamp)"
    }

    /// Common REST request headers.
    func createCommonHeaders() -> [String: String] {
        var headers: [String: String] = [
            HeaderFieldName.id:        application.id,
            HeaderFieldName.signature: createRequestSignature(),
            HeaderFieldName.userAgent: configuration.userAgent,
            HeaderFieldName.accept:    "application/json"
        ]

        if let sessionToken = LCUser.current?.sessionToken {
            headers[HeaderFieldName.session] = sessionToken.value
        }

        return headers
    }

    /**
     Get endpoint of class name.

     - parameter className: The object class name.

     - returns: The endpoint of class name.
     */
    func getClassEndpoint(className: String) -> String {
        switch className {
        case LCUser.objectClassName():
            return "users"
        case LCRole.objectClassName():
            return "roles"
        case LCInstallation.objectClassName():
            return "installations"
        default:
            return "classes/\(className)"
        }
    }

    /**
     Get class endpoint of object.

     - parameter object: The object from which you want to get the endpoint.

     - returns: The class endpoint of object.
     */
    func getClassEndpoint(object: LCObject) -> String {
        return getClassEndpoint(className: object.actualClassName)
    }

    /**
     Get endpoint for object.

     - parameter object: The object which the request will access.

     - returns: The endpoint for object.
     */
    func getObjectEndpoint(object: LCObject) -> String? {
        guard let objectId = object.objectId else {
            return nil
        }

        let classEndpoint = getClassEndpoint(object: object)

        return "\(classEndpoint)/\(objectId.value)"
    }

    /**
     Get versioned path for object and method.

     - parameter object: The object which the request will access.
     - parameter method: The HTTP method.

     - returns: A path with API version.
     */
    func getBatchRequestPath(object: LCObject, method: Method) throws -> String {
        var path: String

        switch method {
        case .get, .put, .delete:
            guard let objectEndpoint = getObjectEndpoint(object: object) else {
                throw LCError(code: .notFound, reason: "Cannot access object before save.")
            }
            path = objectEndpoint
        case .post:
            path = getClassEndpoint(object: object)
        }

        return router.batchRequestPath(for: path)
    }

    /**
     Merge headers with common headers.

     Field in `headers` will overrides the field in common header with the same name.

     - parameter headers: The headers to be merged.

     - returns: The merged headers.
     */
    func mergeCommonHeaders(_ headers: [String: String]?) -> [String: String] {
        var result = createCommonHeaders()

        headers?.forEach { (key, value) in result[key] = value }

        return result
    }

    /**
     Creates a request to REST API and sends it asynchronously.

     - parameter method:                    The HTTP Method.
     - parameter path:                      The REST API path.
     - parameter parameters:                The request parameters.
     - parameter headers:                   The request headers.
     - parameter completionDispatchQueue:   The dispatch queue in which the completion handler will be called. By default, it's a concurrent queue.
     - parameter completionHandler:         The completion callback closure.

     - returns: A request object.
     */
    func request(
        _ method: Method,
        _ path: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completionDispatchQueue: DispatchQueue? = nil,
        completionHandler: @escaping (LCResponse) -> Void)
        -> LCRequest
    {
        let completionDispatchQueue = (
            completionDispatchQueue ??
            defaultCompletionDispatchQueue)

        guard let url = router.route(path: path) else {
            let error = LCError(code: .notFound, reason: "URL not found.")

            let response = LCResponse(response: DataResponse<Any>(
                request: nil, response: nil, data: nil, result: .failure(error)))

            completionDispatchQueue.sync {
                completionHandler(response)
            }

            return LCSingleRequest(request: nil)
        }

        let method    = method.alamofireMethod
        let headers   = mergeCommonHeaders(headers)
        var encoding: ParameterEncoding

        switch method {
        case .get: encoding = URLEncoding.default
        default:   encoding = JSONEncoding.default
        }

        let request = sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate()
        log(request: request)

        request.responseJSON(queue: completionDispatchQueue) { response in
            self.log(response: response, request: request)
            completionHandler(LCResponse(response: response))
        }

        return LCSingleRequest(request: request)
    }

    /**
     Creates a request to REST API and sends it asynchronously.

     - parameter url:                       The absolute URL.
     - parameter method:                    The HTTP Method.
     - parameter parameters:                The request parameters.
     - parameter headers:                   The request headers.
     - parameter completionDispatchQueue:   The dispatch queue in which the completion handler will be called. By default, it's a concurrent queue.
     - parameter completionHandler:         The completion callback closure.

     - returns: A request object.
     */
    func request(
        url: URL,
        method: Method,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completionDispatchQueue: DispatchQueue? = nil,
        completionHandler: @escaping (LCResponse) -> Void)
        -> LCRequest
    {
        let method    = method.alamofireMethod
        let headers   = mergeCommonHeaders(headers)
        var encoding: ParameterEncoding!

        switch method {
        case .get: encoding = URLEncoding.default
        default:   encoding = JSONEncoding.default
        }

        let request = sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate()
        log(request: request)

        let completionDispatchQueue = completionDispatchQueue ?? defaultCompletionDispatchQueue

        request.responseJSON(queue: completionDispatchQueue) { response in
            self.log(response: response, request: request)
            completionHandler(LCResponse(response: response))
        }

        return LCSingleRequest(request: request)
    }

    /**
     Create request for error.

     - parameter error:                     The error object.
     - parameter completionDispatchQueue:   The dispatch queue in which the completion handler will be called. By default, it's a concurrent queue.
     - parameter completionHandler:         The completion callback closure.

     - returns: A request object.
     */
    func request(
        error: Error,
        completionDispatchQueue: DispatchQueue? = nil,
        completionHandler: @escaping (LCBooleanResult) -> Void) -> LCRequest
    {
        return request(object: error, completionDispatchQueue: completionDispatchQueue) { error in
            completionHandler(.failure(error: LCError(error: error)))
        }
    }

    /**
     Create request for error.

     - parameter error:                     The error object.
     - parameter completionDispatchQueue:   The dispatch queue in which the completion handler will be called. By default, it's a concurrent queue.
     - parameter completionHandler:         The completion callback closure.

     - returns: A request object.
     */
    func request<T>(
        error: Error,
        completionDispatchQueue: DispatchQueue? = nil,
        completionHandler: @escaping (LCValueResult<T>) -> Void) -> LCRequest
    {
        return request(object: error, completionDispatchQueue: completionDispatchQueue) { error in
            completionHandler(.failure(error: LCError(error: error)))
        }
    }

    func request<T>(
        object: T,
        completionDispatchQueue: DispatchQueue? = nil,
        completionHandler: @escaping (T) -> Void) -> LCRequest
    {
        let completionDispatchQueue = completionDispatchQueue ?? defaultCompletionDispatchQueue

        completionDispatchQueue.async {
            completionHandler(object)
        }

        return LCSingleRequest(request: nil)
    }

    func log(response: DataResponse<Any>, request: Request) {
        Logger.shared.debug("\n\n\(response.lcDebugDescription(request))\n")
    }

    func log(request: Request) {
        Logger.shared.debug("\n\n\(request.lcDebugDescription)\n")
    }
}

extension Request {

    var lcDebugDescription : String {
        var curl: String = debugDescription

        if curl.hasPrefix("$ ") {
            let startIndex: String.Index = curl.index(curl.startIndex, offsetBy: 2)
            curl = String(curl[startIndex...])
        }

        let taskIdentifier = task?.taskIdentifier ?? 0
        let message = "------ BEGIN LeanCloud HTTP Request\n" +
                      "task: \(taskIdentifier)\n" +
                      "curl: \(curl)\n" +
                      "------ END"
        return message
    }

}

extension DataResponse {

    func lcDebugDescription(_ request : Request) -> String {
        let taskIdentifier = request.task?.taskIdentifier ?? 0

        var message = "------ BEGIN LeanCloud HTTP Response\n"

        message.append("task: \(taskIdentifier)\n")

        if let response = response {
            message.append("code: \(response.statusCode)\n")
        }

        if let error = error {
            message.append("error: \(error.localizedDescription)\n")
        }

        if let data = data {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                let object = try ObjectProfiler.shared.object(jsonValue: jsonObject)
                message.append("data: \(object.jsonString)\n")
            } catch {
                /* Nop */
            }
        }

        message.append("------ END")

        return message
    }

}
