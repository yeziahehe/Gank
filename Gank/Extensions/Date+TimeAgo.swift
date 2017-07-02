//
//  Date+TimeAgo.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/2.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import Foundation

let kMinute = 60
let kDay = kMinute * 24
let kWeek = kDay * 7
let kMonth = kDay * 31
let kYear = kDay * 365

public extension Date {
    
    public var timeAgo: String {
        let now = Date()
        let deltaSeconds = max(Int(now.timeIntervalSince(self)), 0)
        let deltaMinutes = deltaSeconds / 60
        
        if deltaSeconds < 5 {
            return String(format: "刚刚")
        } else if deltaSeconds < kMinute {
            return String(format: "%d秒前", deltaSeconds)
        } else if deltaSeconds < 120 {
            return String(format: "1分钟前")
        } else if deltaMinutes < kMinute {
            return String(format: "%d分钟前", deltaMinutes)
        } else if deltaMinutes < 120 {
            return String(format: "1小时前")
        } else if deltaMinutes < kDay {
            let value = Int(floor(Float(deltaMinutes / kMinute)))
            return String(format: "%d小时前", value)
        } else if deltaMinutes < (kDay * 2) {
            return String(format: "1天前")
        } else if deltaMinutes < kYear {
            let value = Int(floor(Float(deltaMinutes / kDay)))
            return String(format: "%d天前", value)
        } else {
            return self.toString()
        }
    }

}
