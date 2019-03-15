//
//  GankBackgroundFetchService.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/13.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class GankBackgroundFetchService: NSObject {
    
    static let shared = GankBackgroundFetchService()
    
    fileprivate override init() {
        super.init()
        setup()
    }
    
    public func setup() {
        guard let isEnable = GankUserDefaults.isBackgroundEnable.value else {
            turnOff()
            return
        }
        
        if isEnable {
            turnOn()
        } else {
            turnOff()
        }
    }
    
    public func turnOn() {
        GankUserDefaults.isBackgroundEnable.value = true
//        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
    }
    
    public func turnOff() {
        GankUserDefaults.isBackgroundEnable.value = false
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
    }
    
    public func performFetchWithCompletionHandler(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        lastestGankDate(failureHandler: { (_, _) in
            completionHandler(.failed)
        }, completion: { (isGankToday, date) in
            if isGankToday {
                
                guard let noticationDay = GankUserDefaults.notificationDay.value else {
                    GankUserDefaults.notificationDay.value = date
                    SafeDispatch.async {
                        GankNotificationService.shared.push()
                        completionHandler(.newData)
                    }
                    return
                }
                
                guard noticationDay == date else {
                    GankUserDefaults.notificationDay.value = date
                    SafeDispatch.async {
                        GankNotificationService.shared.push()
                        completionHandler(.newData)
                    }
                    return
                }
                
                SafeDispatch.async {
                    completionHandler(.noData)
                }
            }
        })
    }
    
}
