//
//  LCArray.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/27/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud list type.

 It is a wrapper of `Swift.Array` type, used to store a list of objects.
 */
public final class LCArray: NSObject, LCValue, LCValueExtension, Collection, ExpressibleByArrayLiteral {
    public typealias Index = Int
    public typealias Element = LCValue

    public private(set) var value: [Element] = []

    public override init() {
        super.init()
    }

    public convenience init(_ value: [Element]) {
        self.init()
        self.value = value
    }

    public convenience init(_ value: [LCValueConvertible]) {
        self.init()
        self.value = value.map { element in element.lcValue }
    }

    public convenience required init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    public convenience init(unsafeObject: Any) throws {
        self.init()

        guard let object = unsafeObject as? [Any] else {
            throw LCError(
                code: .malformedData,
                reason: "Failed to construct LCArray with non-array object.")
        }

        value = try object.map { element in
            try ObjectProfiler.shared.object(jsonValue: element)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        value = (aDecoder.decodeObject(forKey: "value") as? [Element]) ?? []
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
    }

    public func copy(with zone: NSZone?) -> Any {
        return LCArray(value)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LCArray {
            return object === self || object.value == value
        } else {
            return false
        }
    }

    public func makeIterator() -> IndexingIterator<[Element]> {
        return value.makeIterator()
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return value.count
    }

    public func index(after i: Int) -> Int {
        return value.index(after: i)
    }

    public subscript(index: Int) -> LCValue {
        get { return value[index] }
    }

    public var jsonValue: Any {
        return value.map { element in element.jsonValue }
    }

    func formattedJSONString(indentLevel: Int, numberOfSpacesForOneIndentLevel: Int = 4) -> String {
        if value.isEmpty {
            return "[]"
        }

        let lastIndent = " " * (numberOfSpacesForOneIndentLevel * indentLevel)
        let bodyIndent = " " * (numberOfSpacesForOneIndentLevel * (indentLevel + 1))
        let body = value
            .map { value in (value as! LCValueExtension).formattedJSONString(indentLevel: indentLevel + 1, numberOfSpacesForOneIndentLevel: numberOfSpacesForOneIndentLevel) }
            .joined(separator: ",\n" + bodyIndent)

        return "[\n\(bodyIndent)\(body)\n\(lastIndent)]"
    }

    public var jsonString: String {
        return formattedJSONString(indentLevel: 0)
    }

    public var rawValue: LCValueConvertible {
        let array = value.map { element in element.rawValue }
        return array as! LCValueConvertible
    }

    var lconValue: Any? {
        return value.compactMap { element in (element as? LCValueExtension)?.lconValue }
    }

    static func instance() -> LCValue {
        return self.init([])
    }

    func forEachChild(_ body: (_ child: LCValue) throws -> Void) rethrows {
        try forEach { element in try body(element) }
    }

    func add(_ other: LCValue) throws -> LCValue {
        throw LCError(code: .invalidType, reason: "Object cannot be added.")
    }

    func concatenate(_ other: LCValue, unique: Bool) throws -> LCValue {
        let result   = LCArray(value)
        let elements = (other as! LCArray).value

        result.concatenateInPlace(elements, unique: unique)

        return result
    }

    func concatenateInPlace(_ elements: [Element], unique: Bool) {
        value = unique ? (value +~ elements) : (value + elements)
    }

    func differ(_ other: LCValue) throws -> LCValue {
        let result   = LCArray(value)
        let elements = (other as! LCArray).value

        result.differInPlace(elements)

        return result
    }

    func differInPlace(_ elements: [Element]) {
        value = value - elements
    }
}
