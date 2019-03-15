//
//  LCNull.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 4/23/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud null type.

 A LeanCloud data type represents null value.

 - note: This type is not a singleton type, because Swift does not support singleton well currently.
 */
public final class LCNull: NSObject, LCValue, LCValueExtension {
    public override init() {
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        /* Nothing to decode. */
    }

    public func encode(with aCoder: NSCoder) {
        /* Nothing to encode. */
    }

    public func copy(with zone: NSZone?) -> Any {
        return LCNull()
    }

    public override func isEqual(_ object: Any?) -> Bool {
        return object is LCNull
    }

    public var jsonValue: Any {
        return NSNull()
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        return "null"
    }

    public var jsonString: String {
        return formattedJSONString(indentLevel: 0)
    }

    public var rawValue: LCValueConvertible {
        return NSNull()
    }

    var lconValue: Any? {
        return jsonValue
    }

    static func instance() throws -> LCValue {
        return LCNull()
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
