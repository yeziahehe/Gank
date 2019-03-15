//
//  LCNumber.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/27/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud number type.

 It is a wrapper of `Swift.Double` type, used to store a number value.
 */
public final class LCNumber: NSObject, LCValue, LCValueExtension, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public private(set) var value: Double = 0

    public override init() {
        super.init()
    }

    public convenience init(_ value: Double) {
        self.init()
        self.value = value
    }

    public convenience required init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }

    public convenience required init(integerLiteral value: IntegerLiteralType) {
        self.init(Double(value))
    }

    public required init?(coder aDecoder: NSCoder) {
        value = aDecoder.decodeDouble(forKey: "value")
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
    }

    public func copy(with zone: NSZone?) -> Any {
        return LCNumber(value)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LCNumber {
            return object === self || object.value == value
        } else {
            return false
        }
    }

    public var jsonValue: Any {
        return value
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        return String(format: "%g", value)
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

    static func instance() -> LCValue {
        return LCNumber()
    }

    func forEachChild(_ body: (_ child: LCValue) throws -> Void) rethrows {
        /* Nothing to do. */
    }

    func add(_ other: LCValue) throws -> LCValue {
        let result = LCNumber(value)

        result.addInPlace((other as! LCNumber).value)

        return result
    }

    func addInPlace(_ amount: Double) {
        value += amount
    }

    func concatenate(_ other: LCValue, unique: Bool) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be concatenated.")
    }

    func differ(_ other: LCValue) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be differed.")
    }
}
