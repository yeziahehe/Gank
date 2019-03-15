//
//  Runtime.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/23/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

class Runtime {
    /**
     Get all properties of a class.

     - parameter aClass: Target class.

     - returns: An array of all properties of the given class.
     */
    static func properties(_ aClass: AnyClass) -> [objc_property_t] {
        var result = [objc_property_t]()

        var count: UInt32 = 0

        guard let properties: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(aClass, &count) else {
            return result
        }
        
        defer {
            properties.deallocate()
        }

        for i in 0..<Int(count) {
            let property: objc_property_t = properties[i]
            result.append(property)
        }

        return result
    }

    /**
     Get all non-computed properties of a class.

     - parameter aClass: Inpected class.

     - returns: An array of all non-computed properties of the given class.
     */
    static func nonComputedProperties(_ aClass: AnyClass) -> [objc_property_t] {
        
        var properties: [objc_property_t] = self.properties(aClass)
        
        properties = properties.filter { property in
            if let varChars: UnsafeMutablePointer<Int8> = property_copyAttributeValue(property, "V") {
                
                defer {
                    let utf8Str = String(validatingUTF8: varChars)!
                    varChars.deallocate()
                }
                
                return true
            } else {
                return false
            }
        }
        
        return properties
    }

    /**
     Get property type encoding.

     - parameter property: Inspected property.
     */
    static func typeEncoding(_ property: objc_property_t) -> String? {
        
        guard let typeChars: UnsafeMutablePointer<Int8> = property_copyAttributeValue(property, "T") else {
            return nil
        }
        
        let utf8Str = String(validatingUTF8: typeChars)!
        
        defer {
            typeChars.deallocate()
        }
        
        return utf8Str
    }

    /**
     Get property name.

     - parameter property: Inspected property.
     */
    static func propertyName(_ property: objc_property_t) -> String {
        let propChars: UnsafePointer<Int8> = property_getName(property)
        let utf8Str = String(validatingUTF8: propChars)!
        return utf8Str
    }

    /**
     Get property's backing instance variable from a class.

     - parameter aClass:       The class from where you want to get.
     - parameter propertyName: The property name.

     - returns: Instance variable correspond to the property name.
     */
    static func instanceVariable(_ aClass: AnyClass, _ propertyName: String) -> Ivar? {
        
        guard let property: objc_property_t = class_getProperty(aClass, propertyName) else {
            return nil
        }
        
        guard let varChars: UnsafeMutablePointer<Int8> = property_copyAttributeValue(property, "V") else {
            return nil
        }
        
        defer {
            let utf8Str = String(validatingUTF8: varChars)!
            varChars.deallocate()
        }
        
        let ivar: Ivar? = class_getInstanceVariable(aClass, varChars)
        
        return ivar
    }

    /**
     Get instance variable value from an object.

     - parameter object:       The object from where you want to get.
     - parameter propertyName: The property name.

     - returns: Value of instance variable correspond to the property name.
     */
    static func instanceVariableValue(_ object: Any, _ propertyName: String) -> Any? {
        guard
            let aClass = object_getClass(object),
            let ivar = instanceVariable(aClass, propertyName)
        else {
            return nil
        }

        let ivarValue = object_getIvar(object, ivar)
        
        return ivarValue
    }

    /**
     Set instance variable value of a property.

     - parameter object:       The object.
     - parameter propertyName: Property name on which you want to set.
     - parameter value:        New property value.
     */
    static func setInstanceVariable(_ object: Any, _ propertyName: String, _ value: Any?) {
        guard
            let aClass = object_getClass(object),
            let ivar = instanceVariable(aClass, propertyName)
        else {
            return
        }

        if let value = value {
            let ivarValue = retainedObject(value as AnyObject)
            object_setIvar(object, ivar, ivarValue)
        } else {
            object_setIvar(object, ivar, nil)
        }
    }

    /**
     Get retained object.

     - parameter object: The object which you want to retain.

     - returns: An retained object.
     */
    static func retainedObject<T: AnyObject>(_ object: T) -> T {
        return Unmanaged.passRetained(object).takeUnretainedValue()
    }
}
