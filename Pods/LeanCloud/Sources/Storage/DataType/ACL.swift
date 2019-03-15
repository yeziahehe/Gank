//
//  LCACL.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 5/4/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud access control lists type.

 You can use it to set access control lists on an object.
 */
public final class LCACL: NSObject, LCValue, LCValueExtension {
    typealias Access = [String: Bool]
    typealias AccessTable = [String: Access]

    var value: AccessTable = [:]

    /// The key for public, aka, all users.
    static let publicAccessKey = "*"

    /// The key for `read` permission.
    static let readPermissionKey = "read"

    /// The key for `write` permission.
    static let writePermissionKey = "write"

    public override init() {
        super.init()
    }

    init?(jsonValue: Any?) {
        guard let value = jsonValue as? AccessTable else {
            return nil
        }

        self.value = value
    }

    public required init?(coder aDecoder: NSCoder) {
        value = (aDecoder.decodeObject(forKey: "value") as? AccessTable) ?? [:]
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
    }

    public func copy(with zone: NSZone?) -> Any {
        let copy = LCACL()

        copy.value = value

        return copy
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LCACL {
            return object === self || object.value == value
        } else {
            return false
        }
    }

    public var jsonValue: Any {
        return value
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        return LCDictionary(value).formattedJSONString(indentLevel: indentLevel, numberOfSpacesForOneIndentLevel: numberOfSpacesForOneIndentLevel)
    }

    public var jsonString: String {
        return formattedJSONString(indentLevel: 0)
    }

    public var rawValue: LCValueConvertible {
        return self
    }

    var lconValue: Any? {
        return jsonValue
    }

    static func instance() -> LCValue {
        return self.init()
    }

    func forEachChild(_ body: (_ child: LCValue) throws -> Void) rethrows {
        /* Nothing to do. */
    }

    func add(_ other: LCValue) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be added.")
    }

    func concatenate(_ other: LCValue, unique: Bool) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be concatenated.")
    }

    func differ(_ other: LCValue) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be differed.")
    }

    /**
     Permission type.
     */
    public struct Permission: OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let read  = Permission(rawValue: 1 << 0)
        public static let write = Permission(rawValue: 1 << 1)
    }

    /**
     Generate access key for role name.

     - parameter roleName: The name of role.

     - returns: An access key for role name.
     */
    static func accessKey(roleName: String) -> String {
        return "role:\(roleName)"
    }

    /**
     Get access permission for public.

     - parameter permission: The permission that you want to get.

     - returns: true if the permission is allowed, false otherwise.
     */
    public func getAccess(_ permission: Permission) -> Bool {
        return getAccess(permission, key: LCACL.publicAccessKey)
    }

    /**
     Set access permission for public.

     - parameter permission: The permission to be set.
     - parameter allowed:    A boolean value indicates whether permission is allowed or not.
     */
    public func setAccess(_ permission: Permission, allowed: Bool) {
        setAccess(permission, key: LCACL.publicAccessKey, allowed: allowed)
    }

    /**
     Get access permission for user.

     - parameter permission: The permission that you want to get.
     - parameter userID:     The user object ID for which you want to get.

     - returns: true if the permission is allowed, false otherwise.
     */
    public func getAccess(_ permission: Permission, forUserID userID: String) -> Bool {
        return getAccess(permission, key: userID)
    }

    /**
     Set access permission for user.

     - parameter permission: The permission to be set.
     - parameter allowed:    A boolean value indicates whether permission is allowed or not.
     - parameter userID:     The user object ID for which the permission will be set.
     */
    public func setAccess(_ permission: Permission, allowed: Bool, forUserID userID: String) {
        setAccess(permission, key: userID, allowed: allowed)
    }

    /**
     Get access permission for role.

     - parameter permission: The permission that you want to get.
     - parameter roleName:   The role name for which you want to get.

     - returns: true if the permission is allowed, false otherwise.
     */
    public func getAccess(_ permission: Permission, forRoleName roleName: String) -> Bool {
        return getAccess(permission, key: LCACL.accessKey(roleName: roleName))
    }

    /**
     Set access permission for role.

     - parameter permission: The permission to be set.
     - parameter allowed:    A boolean value indicates whether permission is allowed or not.
     - parameter roleName:   The role name for which the permission will be set.
     */
    public func setAccess(_ permission: Permission, allowed: Bool, forRoleName roleName: String) {
        setAccess(permission, key: LCACL.accessKey(roleName: roleName), allowed: allowed)
    }

    /**
     Get access for key.

     - parameter permission: The permission that you want to get.
     - parameter key:        The key for which you want to get.

     - returns: true if all permission is allowed, false otherwise.
     */
    func getAccess(_ permission: Permission, key: String) -> Bool {
        guard let access = value[key] else {
            return false
        }

        /* We use AND logic here. If any one of permissions is disallowed, return false. */
        if permission.contains(.read) {
            if access[LCACL.readPermissionKey] == nil {
                return false
            }
        }
        if permission.contains(.write) {
            if access[LCACL.writePermissionKey] == nil {
                return false
            }
        }

        return true
    }

    /**
     Update permission for given key.

     - parameter permission: The permission.
     - parameter key:        The key for which the permission to be updated.
     - parameter allowed:    A boolean value indicates whether permission is allowed or not.
     */
    func setAccess(_ permission: Permission, key: String, allowed: Bool) {
        var access = value[key] ?? [:]

        /* We reserve the allowed permissions only. */
        if permission.contains(.read) {
            access[LCACL.readPermissionKey] = allowed ? allowed : nil
        }
        if permission.contains(.write) {
            access[LCACL.writePermissionKey] = allowed ? allowed : nil
        }

        value[key] = !access.isEmpty ? access : nil
    }
}
