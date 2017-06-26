//
//  SafeDispatch.swift
//  Gank
//
//  Created by 叶帆 on 2017/6/26.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import Foundation

final public class SafeDispatch {
    
    private let mainQueueKey = DispatchSpecificKey<Int>()
    private let mainQueueValue = Int(1)
    
    private static let sharedSafeDispatch = SafeDispatch()
    
    private init() {
        DispatchQueue.main.setSpecific(key: mainQueueKey, value: mainQueueValue)
    }
    
    public class func async(onQueue queue: DispatchQueue = DispatchQueue.main, forWork block: @escaping () -> Void) {
        if queue === DispatchQueue.main {
            if DispatchQueue.getSpecific(key: sharedSafeDispatch.mainQueueKey) == sharedSafeDispatch.mainQueueValue {
                block()
            } else {
                DispatchQueue.main.async {
                    block()
                }
            }
        } else {
            queue.async {
                block()
            }
        }
    }
}
