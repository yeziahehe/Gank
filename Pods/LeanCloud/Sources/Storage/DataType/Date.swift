//
//  LCDate.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 4/1/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud date type.

 This type used to represent a point in UTC time.
 */
public final class LCDate: NSObject, LCValue, LCValueExtension {
    public private(set) var value: Date = Date()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static func dateFromString(_ isoString: String) -> Date? {
        return dateFormatter.date(from: isoString)
    }

    static func stringFromDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    var isoString: String {
        return LCDate.stringFromDate(value)
    }

    public override init() {
        super.init()
    }

    public convenience init(_ date: Date) {
        self.init()
        value = date
    }

    init?(isoString: String) {
        guard let date = LCDate.dateFromString(isoString) else {
            return nil
        }

        value = date
    }

    init?(dictionary: [String: Any]) {
        guard let type = dictionary["__type"] as? String else {
            return nil
        }
        guard let dataType = HTTPClient.DataType(rawValue: type) else {
            return nil
        }
        guard case dataType = HTTPClient.DataType.date else {
            return nil
        }
        guard let ISOString = dictionary["iso"] as? String else {
            return nil
        }
        guard let date = LCDate.dateFromString(ISOString) else {
            return nil
        }

        value = date
    }

    init?(jsonValue: Any?) {
        var value: Date?

        switch jsonValue {
        case let ISOString as String:
            value = LCDate.dateFromString(ISOString)
        case let dictionary as [String: Any]:
            if let date = LCDate(dictionary: dictionary) {
                value = date.value
            }
        case let date as LCDate:
            value = date.value
        default:
            break
        }

        guard let someValue = value else {
            return nil
        }

        self.value = someValue
    }

    public required init?(coder aDecoder: NSCoder) {
        value = (aDecoder.decodeObject(forKey: "value") as? Date) ?? Date()
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
    }

    public func copy(with zone: NSZone?) -> Any {
        return LCDate((value as NSDate).copy() as! Date)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LCDate {
            return object === self || object.value == value
        } else {
            return false
        }
    }

    public var jsonValue: Any {
        return typedJSONValue
    }

    private var typedJSONValue: [String: String] {
        return [
            "__type": "Date",
            "iso": isoString
        ]
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        return LCDictionary(typedJSONValue).formattedJSONString(indentLevel: indentLevel, numberOfSpacesForOneIndentLevel: numberOfSpacesForOneIndentLevel)
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
