//
//  LCGeoPoint.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 4/1/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud geography point type.

 This type can be used to represent a 2D location with latitude and longitude.
 */
public final class LCGeoPoint: NSObject, LCValue, LCValueExtension {
    public private(set) var latitude: Double = 0
    public private(set) var longitude: Double = 0

    public enum Unit: String {
        case mile = "Miles"
        case kilometer = "Kilometers"
        case radian = "Radians"
    }

    public struct Distance {
        let value: Double
        let unit: Unit

        public init(value: Double, unit: Unit) {
            self.value = value
            self.unit  = unit
        }
    }

    public override init() {
        super.init()
    }

    public convenience init(latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }

    init?(dictionary: [String: Any]) {
        guard let type = dictionary["__type"] as? String else {
            return nil
        }
        guard let dataType = HTTPClient.DataType(rawValue: type) else {
            return nil
        }
        guard case dataType = HTTPClient.DataType.geoPoint else {
            return nil
        }
        guard let latitude = dictionary["latitude"] as? Double else {
            return nil
        }
        guard let longitude = dictionary["longitude"] as? Double else {
            return nil
        }

        self.latitude  = latitude
        self.longitude = longitude
    }

    public required init?(coder aDecoder: NSCoder) {
        latitude  = aDecoder.decodeDouble(forKey: "latitude")
        longitude = aDecoder.decodeDouble(forKey: "longitude")
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
    }

    public func copy(with zone: NSZone?) -> Any {
        return LCGeoPoint(latitude: latitude, longitude: longitude)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LCGeoPoint {
            return object === self || (object.latitude == latitude && object.longitude == longitude)
        } else {
            return false
        }
    }

    public var jsonValue: Any {
        return typedJSONValue
    }

    private var typedJSONValue: [String: LCValueConvertible] {
        return [
            "__type"    : "GeoPoint",
            "latitude"  : latitude,
            "longitude" : longitude
        ]
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        return LCDictionary(typedJSONValue).formattedJSONString(indentLevel: indentLevel, numberOfSpacesForOneIndentLevel: numberOfSpacesForOneIndentLevel)
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
}
