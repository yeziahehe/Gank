//
//  HTTPRouter.swift
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/9/5.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

import Foundation

extension LCError {

    static let appRouterUrlNotFound = LCError(
        code: .inconsistency,
        reason: "App router URL not found.")

    static let applicationNotInitialized = LCError(
        code: .inconsistency,
        reason: "Application not initialized.")

}

/**
 HTTP router for application.
 */
class HTTPRouter {

    /**
     Application API module.
     */
    enum Module: String {

        case api
        case push
        case engine
        case stats
        case rtm = "rtm_router"

        var key: String {
            return "\(rawValue)_server"
        }

        init?(key: String) {
            guard key.hasSuffix("_server") else {
                return nil
            }

            let prefix = String(key.dropLast(7))

            if let module = Module(rawValue: prefix) {
                self = module
            } else {
                return nil
            }
        }

    }

    /**
     HTTP router configuration.
     */
    struct Configuration {

        let apiVersion: String

        static let `default` = Configuration(apiVersion: "1.1")

    }

    let application: LCApplication

    let configuration: Configuration

    init(application: LCApplication, configuration: Configuration) {
        self.application = application
        self.configuration = configuration
    }

    /// HTTPClient and HTTPRouter is not really circular referenced.
    /// Here, router retains a **newly created** client, not the client which retains current router.
    private lazy var httpClient = HTTPClient(application: application, configuration: .default)

    private let appRouterURL = URL(string: "https://app-router.leancloud.cn/2/route")

    /// Current app router request.
    private var appRouterRequest: LCRequest?

    /// App router completion array.
    private var appRouterCompletions: [(LCBooleanResult) -> Void] = []

    /// App router cache.
    private lazy var appRouterCache = AppRouterCache(application: application)

    /// RTM router path.
    private let rtmRouterPath = "v1/route"

    /// Module table indexed by first path component.
    private let moduleTable: [String: Module] = [
        "push": .push,
        "installations": .push,

        "call": .engine,
        "functions": .engine,

        "stats": .stats,
        "statistics": .stats,
        "always_collect": .stats
    ]

    /**
     Get module of path.

     - parameter path: A REST API path.

     - returns: The module of path.
     */
    private func findModule(path: String) -> Module {
        if path == rtmRouterPath {
            return .rtm
        } else if let firstPathComponent = path.components(separatedBy: "/").first, let module = moduleTable[firstPathComponent] {
            return module
        } else {
            return .api
        }
    }

    /**
     Check if a host has scheme.

     - parameter host: URL host string.

     - returns: true if host has scheme, false otherwise.
     */
    private func hasScheme(host: String) -> Bool {
        guard let url = URL(string: host), let scheme = url.scheme else {
            return false
        }

        /* For host "example.com:8080", url.scheme is "example.com". So, we need a farther check here. */

        guard host.hasPrefix(scheme + "://") else {
            return false
        }

        return true
    }

    /**
     Add scheme to host.

     - parameter host: URL host string. If the host already has scheme, it will be returned without change.

     - returns: A host with scheme.
     */
    private func addScheme(host: String) -> String {
        if hasScheme(host: host) {
            return host
        } else {
            return "https://\(host)"
        }
    }

    /**
     Versionize a path.

     - parameter path: The path to be versionized.

     - returns: A versionized path.
     */
    private func versionizedPath(_ path: String) -> String {
        return configuration.apiVersion.appendingPathComponent(path)
    }

    /**
     Make path to be absolute.

     - parameter path: The path. It may already be a absolute path.

     - returns: An absolute path.
     */
    private func absolutePath(_ path: String) -> String {
        return "/".appendingPathComponent(path)
    }

    /**
     Create batch request path.

     - parameter path: A path without API version.

     - returns: A versionized absolute path.
     */
    func batchRequestPath(for path: String) -> String {
        return absolutePath(versionizedPath(path))
    }

    /**
     Create absolute url with host and path.

     - parameter host: URL host, maybe with scheme and port, or even path, like "http://example.com:8000/foo".
     - parameter path: URL path.

     - returns: An absolute URL.
     */
    func absoluteUrl(host: String, path: String) -> URL? {
        let fullHost = addScheme(host: host)

        guard var components = URLComponents(string: fullHost) else {
            return nil
        }

        let fullPath = absolutePath(components.path.appendingPathComponent(path))

        if let fullPathUrl = URL(string: fullPath) {
            components.path = fullPathUrl.path
            components.query = fullPathUrl.query
            components.fragment = fullPathUrl.fragment
        }

        let url = components.url

        return url
    }

    /**
     Get fallback URL for path and module.

     - parameter path: A REST API path.
     - parameter module: The module of path.

     - returns: The fallback URL.
     */
    func fallbackUrl(path: String, module: Module) -> URL? {
        let tld = application.region.domain
        let prefix = String(application.id.prefix(upTo: 8)).lowercased()

        let host = "\(prefix).\(module).\(tld)"
        let url = absoluteUrl(host: host, path: path)

        return url
    }

    /**
     Cache app router.

     - parameter dictionary: The raw dictionary returned by app router.
     */
    func cacheAppRouter(_ dictionary: LCDictionary) throws {
        guard let ttl = dictionary.removeValue(forKey: "ttl") as? LCNumber else {
            throw LCError(code: .malformedData, reason: "Malformed router table.")
        }

        var hostTable: [Module: String] = [:]

        dictionary.forEach { (key, value) in
            if
                let module = Module(key: key),
                let host = value.stringValue
            {
                hostTable[module] = host
            }
        }

        let expirationDate = Date(timeIntervalSinceNow: ttl.value)

        try appRouterCache.cacheHostTable(hostTable, expirationDate: expirationDate)
    }

    /**
     Handle app router request.

     It will call and clear app router completions.

     - parameter result: Result of app router request.
     */
    private func handleAppRouterResult(_ result: LCValueResult<LCDictionary>) {
        synchronize(on: self) {
            var booleanResult = LCBooleanResult.success

            switch result {
            case .success(let object):
                do {
                    try cacheAppRouter(object)
                } catch let error {
                    booleanResult = .failure(error: LCError(error: error))
                }
            case .failure(let error):
                booleanResult = .failure(error: error)
            }

            appRouterCompletions.forEach { completion in
                completion(booleanResult)
            }

            appRouterCompletions.removeAll()
            appRouterRequest = nil
        }
    }

    /**
     Request app router without throttle.

     - parameter completion: The completion handler.

     - returns: App router request.
     */
    private func requestAppRouterWithoutThrottle(completion: @escaping (LCValueResult<LCDictionary>) -> Void) -> LCRequest {
        guard let url = appRouterURL else {
            return httpClient.request(
                error: LCError.appRouterUrlNotFound,
                completionHandler: completion)
        }
        guard let id = application.id else {
            return httpClient.request(
                error: LCError.applicationNotInitialized,
                completionHandler: completion)
        }
        return httpClient.request(url: url, method: .get, parameters: ["appId": id]) { response in
            completion(LCValueResult(response: response))
        }
    }

    /**
     Request app router.

     - note: The request will be controlled by a throttle, only one request is allowed one at a time.

     - parameter completion: The completion handler.

     - returns: App router request.
     */
    @discardableResult
    func requestAppRouter(completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return synchronize(on: self) {
            appRouterCompletions.append(completion)

            if let appRouterRequest = appRouterRequest {
                return appRouterRequest
            } else {
                let appRouterRequest = requestAppRouterWithoutThrottle { result in
                    self.handleAppRouterResult(result)
                }
                self.appRouterRequest = appRouterRequest
                return appRouterRequest
            }
        }
    }

    /**
     Get cached url for path and module.

     - parameter path: URL path.
     - parameter module: API module.

     - returns: The cached url, or nil if cache expires or not found.
     */
    func cachedUrl(path: String, module: Module) -> URL? {
        return synchronize(on: self) {
            do {
                guard let host = try appRouterCache.fetchHost(module: module) else {
                    return nil
                }
                return absoluteUrl(host: host, path: path)
            } catch let error {
                Logger.shared.error(error)
                return nil
            }
        }
    }

    /**
     Route a path to API module.

     - parameter path: A path without API version.
     - parameter module: API module. If nil, it will use default rules.

     - returns: An absolute URL.
     */
    func route(path: String, module: Module? = nil) -> URL? {
        let module = module ?? findModule(path: path)
        let fullPath = versionizedPath(path)

        if let url = cachedUrl(path: fullPath, module: module) {
            return url
        } else {
            requestAppRouter { _ in /* Nothing to do */ }
        }

        if let url = fallbackUrl(path: fullPath, module: module) {
            return url
        } else {
            return nil
        }
    }

}
