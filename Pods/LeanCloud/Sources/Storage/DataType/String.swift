//
//  LCString.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/27/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud string type.

 It is a wrapper of `Swift.String` type, used to store a string value.
 */
public final class LCString: NSObject, LCValue, LCValueExtension, ExpressibleByStringLiteral {
    public private(set) var value: String = ""

    public typealias UnicodeScalarLiteralType = Character
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    public override init() {
        super.init()
    }

    public convenience init(_ value: String) {
        self.init()
        self.value = value
    }

    public convenience required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(String(value))
    }

    public convenience required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(String(value))
    }

    public convenience required init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    public required init?(coder aDecoder: NSCoder) {
        value = (aDecoder.decodeObject(forKey: "value") as? String) ?? ""
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
    }

    public func copy(with zone: NSZone?) -> Any {
        return LCString(value)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LCString {
            return object === self || object.value == value
        } else {
            return false
        }
    }

    public var jsonValue: Any {
        return value
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        return "\"\(value.doubleQuoteEscapedString)\""
    }

    public var jsonString: String {
        return formattedJSONString(indentLevel: 0)
    }

    public var rawValue: LCValueConvertible {
        return value
    }

    var lconValue: Any? {
        return jsonValue
    }

    class func instance() -> LCValue {
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
}
