//
//  Application.swift
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/8/28.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud application.

 An `LCApplication` object is an abstract of remote LeanCloud application.

 It is a context of application-specific settings and objects.
 */
public final class LCApplication: NSObject {

    /**
     Application region.
     */
    enum Region {

        case cn
        case ce
        case us

        private enum Suffix: String {

            case cn = "-gzGzoHsz"
            case ce = "-9Nh9j0Va"
            case us = "-MdYXbMMI"

        }

        init(id: String) {
            if id.hasSuffix(Suffix.cn.rawValue) {
                self = .cn
            } else if id.hasSuffix(Suffix.ce.rawValue) {
                self = .ce
            } else if id.hasSuffix(Suffix.us.rawValue) {
                self = .us
            } else { /* Old application of cn region may have no suffix. */
                self = .cn
            }
        }

        var domain: String {
            switch self {
            case .cn:
                return "lncld.net"
            case .ce:
                return "lncldapi.com"
            case .us:
                return "lncldglobal.com"
            }
        }

    }

    /**
     Application log level.

     We assume that log levels are ordered.
     */
    public enum LogLevel: Int, Comparable {

        case off
        case error
        case debug
        case all

        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        var description: String {
            switch self {
            case .error:
                return "Error"
            case .debug:
                return "Debug"
            default:
                return ""
            }
        }

    }

    /// Application ID.
    public private(set) var id: String!

    /// Application key.
    public private(set) var key: String!

    /// Application region.
    var region: Region {
        return Region(id: id)
    }

    /// Application log level.
    public var logLevel: LogLevel = .off

    /**
     Default application.

     You must call method `set(id:key:region:)` to initialize it when application did finish launch.
     */
    public static let `default` = LCApplication()

    /**
     Create an application.

     - note: We make initializer internal before multi-applicaiton is supported.
     */
    override init() {
        /* Nop */
    }

    /**
     Create an application with id and key.

     - parameter id: Application ID.
     - parameter key: Application key.

     - note: We make initializer internal before multi-applicaiton is supported.
     */
    init(id: String, key: String) {
        self.id = id
        self.key = key
    }

    /**
     Initialize application by application information.

     - parameter id:    Application ID.
     - parameter key:   Application key.
     */
    public func set(id: String, key: String) {
        self.id = id
        self.key = key
    }

}
