//
//  LCValue.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/27/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 Abstract data type.

 All LeanCloud data types must confirm this protocol.
 */
public protocol LCValue: NSObjectProtocol, NSCoding, NSCopying, LCValueConvertible {
    /**
     The JSON representation.
     */
    var jsonValue: Any { get }

    /**
     The pretty description.
     */
    var jsonString: String { get }

    /**
     The raw value of current value.

     For JSON-compatible objects, such as string, array, etc., raw value is the value of corresponding Swift built-in type.
     For some objects of other types, such as `LCObject`, `LCACL` etc., raw value is itself.
     */
    var rawValue: LCValueConvertible { get }

    /* Shorthands for type conversion. */

    var intValue: Int? { get }
    var uintValue: UInt? { get }
    var int8Value: Int8? { get }
    var uint8Value: UInt8? { get }
    var int16Value: Int16? { get }
    var uint16Value: UInt16? { get }
    var int32Value: Int32? { get }
    var uint32Value: UInt32? { get }
    var int64Value: Int64? { get }
    var uint64Value: UInt64? { get }
    var floatValue: Float? { get }
    var doubleValue: Double? { get }
    var boolValue: Bool? { get }
    var stringValue: String? { get }
    var arrayValue: [LCValueConvertible]? { get }
    var dictionaryValue: [String: LCValueConvertible]? { get }
    var dataValue: Data? { get }
    var dateValue: Date? { get }
}

extension LCValue {
    public var intValue: Int? {
        guard let number = rawValue as? Double else { return nil }
        return Int(number)
    }

    public var uintValue: UInt? {
        guard let number = rawValue as? Double else { return nil }
        return UInt(number)
    }

    public var int8Value: Int8? {
        guard let number = rawValue as? Double else { return nil }
        return Int8(number)
    }

    public var uint8Value: UInt8? {
        guard let number = rawValue as? Double else { return nil }
        return UInt8(number)
    }

    public var int16Value: Int16? {
        guard let number = rawValue as? Double else { return nil }
        return Int16(number)
    }

    public var uint16Value: UInt16? {
        guard let number = rawValue as? Double else { return nil }
        return UInt16(number)
    }

    public var int32Value: Int32? {
        guard let number = rawValue as? Double else { return nil }
        return Int32(number)
    }

    public var uint32Value: UInt32? {
        guard let number = rawValue as? Double else { return nil }
        return UInt32(number)
    }

    public var int64Value: Int64? {
        guard let number = rawValue as? Double else { return nil }
        return Int64(number)
    }

    public var uint64Value: UInt64? {
        guard let number = rawValue as? Double else { return nil }
        return UInt64(number)
    }

    public var floatValue: Float? {
        guard let number = rawValue as? Double else { return nil }
        return Float(number)
    }

    public var doubleValue: Double? {
        guard let number = rawValue as? Double else { return nil }
        return Double(number)
    }

    public var boolValue: Bool? {
        guard let number = rawValue as? Double else { return nil }
        return number != 0
    }

    public var stringValue: String? {
        return rawValue as? String
    }

    public var arrayValue: [LCValueConvertible]? {
        return rawValue as? [LCValueConvertible]
    }

    public var dictionaryValue: [String: LCValueConvertible]? {
        return rawValue as? [String: LCValueConvertible]
    }

    public var dataValue: Data? {
        return rawValue as? Data
    }

    public var dateValue: Date? {
        return rawValue as? Date
    }
}

/**
 Extension of LCValue.

 By convention, all types that confirm `LCValue` must also confirm `LCValueExtension`.
 */
protocol LCValueExtension: LCValue {
    /**
     The LCON (LeanCloud Object Notation) representation.

     For JSON-compatible objects, such as string, array, etc., LCON value is the same as JSON value.

     However, some types might have different representations, or even have no LCON value.
     For example, when an object has not been saved, its LCON value is nil.
     */
    var lconValue: Any? { get }

    /**
     Create an instance of current type.

     This method exists because some data types cannot be instantiated externally.

     - returns: An instance of current type.
     */
    static func instance() throws -> LCValue

    // MARK: Enumeration

    /**
     Iterate children by a closure.

     - parameter body: The iterator closure.
     */
    func forEachChild(_ body: (_ child: LCValue) throws -> Void) rethrows

    // MARK: Arithmetic

    /**
     Add an object.

     - parameter other: The object to be added, aka the addend.

     - returns: The sum of addition.
     */
    func add(_ other: LCValue) throws -> LCValue

    /**
     Concatenate an object with unique option.

     - parameter other:  The object to be concatenated.
     - parameter unique: Whether to concatenate with unique or not.

        If `unique` is true, for each element in `other`, if current object has already included the element, do nothing.
        Otherwise, the element will always be appended.

     - returns: The concatenation result.
     */
    func concatenate(_ other: LCValue, unique: Bool) throws -> LCValue

    /**
     Calculate difference with other.

     - parameter other: The object to differ.

     - returns: The difference result.
     */
    func differ(_ other: LCValue) throws -> LCValue

    /**
     Get formatted JSON string with indent.

     - parameter indentLevel: The indent level.
     - parameter numberOfSpacesForOneIndentLevel: The number of spaces for one indent level.

     - returns: The JSON string.
     */
    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int) -> String
}

/**
 Convertible protocol for `LCValue`.
 */
public protocol LCValueConvertible {
    /**
     Get the `LCValue` value for current object.
     */
    var lcValue: LCValue { get }
}

extension LCValueConvertible {
    public var intValue: Int? {
        return lcValue.intValue
    }

    public var uintValue: UInt? {
        return lcValue.uintValue
    }

    public var int8Value: Int8? {
        return lcValue.int8Value
    }

    public var uint8Value: UInt8? {
        return lcValue.uint8Value
    }

    public var int16Value: Int16? {
        return lcValue.int16Value
    }

    public var uint16Value: UInt16? {
        return lcValue.uint16Value
    }

    public var int32Value: Int32? {
        return lcValue.int32Value
    }

    public var uint32Value: UInt32? {
        return lcValue.uint32Value
    }

    public var int64Value: Int64? {
        return lcValue.int64Value
    }

    public var uint64Value: UInt64? {
        return lcValue.uint64Value
    }

    public var floatValue: Float? {
        return lcValue.floatValue
    }

    public var doubleValue: Double? {
        return lcValue.doubleValue
    }

    public var boolValue: Bool? {
        return lcValue.boolValue
    }

    public var stringValue: String? {
        return lcValue.stringValue
    }

    public var arrayValue: [LCValueConvertible]? {
        return lcValue.arrayValue
    }

    public var dictionaryValue: [String: LCValueConvertible]? {
        return lcValue.dictionaryValue
    }

    public var dataValue: Data? {
        return lcValue.dataValue
    }

    public var dateValue: Date? {
        return lcValue.dateValue
    }
}

/**
 Convertible protocol for `LCNull`.
 */
public protocol LCNullConvertible: LCValueConvertible {
    var lcNull: LCNull { get }
}

/**
 Convertible protocol for `LCNumber`.
 */
public protocol LCNumberConvertible: LCValueConvertible {
    var lcNumber: LCNumber { get }
}

/**
 Convertible protocol for `LCBool`.
 */
public protocol LCBoolConvertible: LCValueConvertible {
    var lcBool: LCBool { get }
}

/**
 Convertible protocol for `LCString`.
 */
public protocol LCStringConvertible: LCValueConvertible {
    var lcString: LCString { get }
}

/**
 Convertible protocol for `LCArray`.
 */
public protocol LCArrayConvertible: LCValueConvertible {
    var lcArray: LCArray { get }
}

/**
 Convertible protocol for `LCDictionary`.
 */
public protocol LCDictionaryConvertible: LCValueConvertible {
    var lcDictionary: LCDictionary { get }
}

/**
 Convertible protocol for `LCData`.
 */
public protocol LCDataConvertible: LCValueConvertible {
    var lcData: LCData { get }
}

/**
 Convertible protocol for `LCDate`.
 */
public protocol LCDateConvertible: LCValueConvertible {
    var lcDate: LCDate { get }
}

extension NSNull: LCNullConvertible {
    public var lcValue: LCValue {
        return lcNull
    }

    public var lcNull: LCNull {
        return LCNull()
    }
}

extension Int: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension UInt: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension Int8: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension UInt8: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension Int16: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension UInt16: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension Int32: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension UInt32: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension Int64: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension UInt64: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension Float: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension Double: LCNumberConvertible {
    public var lcValue: LCValue {
        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(Double(self))
    }
}

extension Bool: LCBoolConvertible {
    public var lcValue: LCValue {
        return lcBool
    }

    public var lcBool: LCBool {
        return LCBool(self)
    }
}

extension NSNumber: LCNumberConvertible, LCBoolConvertible {
    public var lcValue: LCValue {
        if ObjectProfiler.shared.isBoolean(self) {
            return lcBool
        }

        return lcNumber
    }

    public var lcNumber: LCNumber {
        return LCNumber(doubleValue)
    }

    public var lcBool: LCBool {
        return LCBool(boolValue)
    }
}

extension String: LCStringConvertible {
    public var lcValue: LCValue {
        return lcString
    }

    public var lcString: LCString {
        return LCString(self)
    }
}

extension NSString: LCStringConvertible {
    public var lcValue: LCValue {
        return lcString
    }

    public var lcString: LCString {
        return LCString(String(self))
    }
}

extension URL: LCStringConvertible {
    public var lcValue: LCValue {
        return lcString
    }

    public var lcString: LCString {
        return LCString(absoluteString)
    }
}

extension Array: LCValueConvertible, LCArrayConvertible where Element: LCValueConvertible {
    public var lcValue: LCValue {
        return lcArray
    }

    public var lcArray: LCArray {
        let value = map { element in element.lcValue }
        return LCArray(value)
    }
}

extension Dictionary: LCValueConvertible, LCDictionaryConvertible where Key == String, Value: LCValueConvertible {
    public var lcValue: LCValue {
        return lcDictionary
    }

    public var lcDictionary: LCDictionary {
        let value = mapValue { value in value.lcValue }
        return LCDictionary(value)
    }
}

extension Data: LCDataConvertible {
    public var lcValue: LCValue {
        return lcData
    }

    public var lcData: LCData {
        return LCData(self)
    }
}

extension NSData: LCDataConvertible {
    public var lcValue: LCValue {
        return lcData
    }

    public var lcData: LCData {
        return LCData(self as Data)
    }
}

extension Date: LCDateConvertible {
    public var lcValue: LCValue {
        return lcDate
    }

    public var lcDate: LCDate {
        return LCDate(self)
    }
}

extension NSDate: LCDateConvertible {
    public var lcValue: LCValue {
        return lcDate
    }

    public var lcDate: LCDate {
        return LCDate(self as Date)
    }
}

extension LCNull: LCValueConvertible, LCNullConvertible {
    public var lcValue: LCValue {
        return self
    }

    public var lcNull: LCNull {
        return self
    }
}

extension LCNumber: LCValueConvertible, LCNumberConvertible {
    public var lcValue: LCValue {
        return self
    }

    public var lcNumber: LCNumber {
        return self
    }
}

extension LCBool: LCValueConvertible, LCBoolConvertible {
    public var lcValue: LCValue {
        return self
    }

    public var lcBool: LCBool {
        return self
    }
}

extension LCString: LCValueConvertible, LCStringConvertible {
    public var lcValue: LCValue {
        return self
    }

    public var lcString: LCString {
        return self
    }
}

extension LCArray: LCValueConvertible, LCArrayConvertible {
    public var lcValue: LCValue {
        return self
    }

    public var lcArray: LCArray {
        return self
    }
}

extension LCDictionary: LCValueConvertible, LCDictionaryConvertible {
    public var lcValue: LCValue {
        return self
    }

    public var lcDictionary: LCDictionary {
        return self
    }
}

extension LCObject: LCValueConvertible {
    public var lcValue: LCValue {
        return self
    }
}

extension LCRelation: LCValueConvertible {
    public var lcValue: LCValue {
        return self
    }
}

extension LCGeoPoint: LCValueConvertible {
    public var lcValue: LCValue {
        return self
    }
}

extension LCData: LCValueConvertible, LCDataConvertible {
    public var lcValue: LCValue {
        return self
    }

    public var lcData: LCData {
        return self
    }
}

extension LCDate: LCValueConvertible, LCDateConvertible {
    public var lcValue: LCValue {
        return self
    }

    public var lcDate: LCDate {
        return self
    }
}

extension LCACL: LCValueConvertible {
    public var lcValue: LCValue {
        return self
    }
}
