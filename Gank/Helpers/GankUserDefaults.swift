//
//  GankUserDefaults.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/11.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

private let notificationDayKey = "notificationDay"

public struct Listener<T>: Hashable {
    
    let name: String
    
    public typealias Action = (T) -> Void
    let action: Action
    
    public var hashValue: Int {
        return name.hashValue
    }
}

public func ==<T>(lhs: Listener<T>, rhs: Listener<T>) -> Bool {
    return lhs.name == rhs.name
}

final public class Listenable<T> {
    
    public var value: T {
        didSet {
            setterAction(value)
            
            for listener in listenerSet {
                listener.action(value)
            }
        }
    }
    
    public typealias SetterAction = (T) -> Void
    var setterAction: SetterAction
    
    var listenerSet = Set<Listener<T>>()
    
    public func bindListener(_ name: String, action: @escaping Listener<T>.Action) {
        let listener = Listener(name: name, action: action)
        listenerSet.update(with: listener)
        
        // @available(swift, obsoleted: 3.0)
        // listenerSet.insert(listener)
    }
    
    public func bindAndFireListener(_ name: String, action: @escaping Listener<T>.Action) {
        bindListener(name, action: action)
        
        action(value)
    }
    
    public func removeListenerWithName(_ name: String) {
        for listener in listenerSet {
            if listener.name == name {
                listenerSet.remove(listener)
                break
            }
        }
    }
    
    public func removeAllListeners() {
        listenerSet.removeAll(keepingCapacity: false)
    }
    
    public init(_ v: T, setterAction action: @escaping SetterAction) {
        value = v
        setterAction = action
    }
}

final public class GankUserDefaults {
    
    static let defaults = UserDefaults(suiteName: GankConfig.appGroupID)!
    
    public static var notificationDay: Listenable<String?> = {
        let notificationDay = defaults.string(forKey: notificationDayKey)
        
        return Listenable<String?>(notificationDay) { notificationDay in
            defaults.set(notificationDay, forKey: notificationDayKey)
        }
    }()

}
