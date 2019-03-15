//
//  Result.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 4/26/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

public protocol LCResultType {
    var error: LCError? { get }
    var isSuccess: Bool { get }
    var isFailure: Bool { get }
}

extension LCResultType {
    public var isFailure: Bool {
        return !isSuccess
    }
}

public enum LCBooleanResult: LCResultType {
    case success
    case failure(error: LCError)

    public var error: LCError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    init(response: LCResponse) {
        if let error = LCError(response: response) {
            self = .failure(error: error)
        } else {
            self = .success
        }
    }
}

enum LCGenericResult<T>: LCResultType {
    case success(value: T)
    case failure(error: LCError)

    public var error: LCError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}

/**
 Result type for object request.
 */
public enum LCValueResult<T: LCValue>: LCResultType {
    case success(object: T)
    case failure(error: LCError)

    init(response: LCResponse) {
        if let error = LCError(response: response) {
            self = .failure(error: error)
            return
        }
        guard var jsonValue = response.value else {
            self = .failure(error: LCError(code: .notFound, reason: "Response data not found."))
            return
        }

        var value: LCValue

        do {
            /* Add missing meta data for object. */
            if
                let objectClass = T.self as? LCObject.Type,
                var dictionary = jsonValue as? [String: Any]
            {
                dictionary["__type"]    = HTTPClient.DataType.object.rawValue
                dictionary["className"] = objectClass.objectClassName()

                jsonValue = dictionary
            }

            value = try ObjectProfiler.shared.object(jsonValue: jsonValue)
        } catch let error {
            self = .failure(error: LCError(error: error))
            return
        }

        guard let object = value as? T else {
            self = .failure(error: LCError(code: .invalidType, reason: "Invalid response data type."))
            return
        }

        self = .success(object: object)
    }

    public var error: LCError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    public var object: T? {
        switch self {
        case let .success(object):
            return object
        case .failure:
            return nil
        }
    }
}

/**
 Result type for optional request.
 */
public enum LCValueOptionalResult: LCResultType {
    case success(object: LCValue?)
    case failure(error: LCError)

    init(response: LCResponse, keyPath: String) {
        if let error = LCError(response: response) {
            self = .failure(error: error)
            return
        }

        if let jsonValue: Any = response[keyPath] {
            self = .success(object: try? ObjectProfiler.shared.object(jsonValue: jsonValue))
        } else {
            self = .success(object: nil)
        }
    }

    public var error: LCError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    public var object: LCValue? {
        switch self {
        case let .success(object):
            return object
        case .failure:
            return nil
        }
    }
}

public enum LCQueryResult<T: LCObject>: LCResultType {
    case success(objects: [T])
    case failure(error: LCError)

    public var error: LCError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    public var objects: [T]? {
        switch self {
        case let .success(objects):
            return objects
        case .failure:
            return nil
        }
    }
}

public enum LCCountResult: LCResultType {
    case success(count: Int)
    case failure(error: LCError)

    init(response: LCResponse) {
        if let error = LCError(response: response) {
            self = .failure(error: error)
        } else {
            self = .success(count: response.count)
        }
    }

    public var error: LCError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    public var intValue: Int {
        switch self {
        case let .success(count):
            return count
        case .failure:
            return 0
        }
    }
}

public enum LCCQLResult: LCResultType {
    case success(value: LCCQLValue)
    case failure(error: LCError)

    init(response: LCResponse) {
        if let error = LCError(response: response) {
            self = .failure(error: error)
        } else {
            self = .success(value: LCCQLValue(response: response))
        }
    }

    public var error: LCError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    public var objects: [LCObject] {
        switch self {
        case let .success(value):
            return value.objects
        case .failure:
            return []
        }
    }

    public var count: Int {
        switch self {
        case let .success(value):
            return value.count
        case .failure:
            return 0
        }
    }
}
