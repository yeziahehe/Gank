//
//  Lazyload.swift
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/10/15.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

import Foundation
import _LeanCloud_Polyfill

extension NSObject {

    func lc_lazyload<T: Any>(_ key: String, _ policy: objc_AssociationPolicy, _ object: () -> T) -> T {
        return lc_lazyload(key, policy, object())
    }

    func lc_lazyload<T: Any>(_ key: String, _ policy: objc_AssociationPolicy, _ object: @autoclosure () -> T) -> T {
        objc_sync_enter(self)

        defer {
            objc_sync_exit(self)
        }

        if let object = lc_associatedObject(forKey: key) as? T {
            return object
        } else {
            let object = object()
            lc_associateObject(object, forKey: key, policy: policy)
            return object
        }
    }

}
