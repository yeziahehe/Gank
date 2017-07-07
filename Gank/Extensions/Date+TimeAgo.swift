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

extension Date {
    
    public var timeAgo: String {
        let now = Date()
        let deltaSeconds = max(Int(now.timeIntervalSince(self)), 0)
        
        switch deltaSeconds {
        case 0..<5:
            return String(format: "刚刚")
        case 5..<kMinute:
            return String(format: "%d秒前", deltaSeconds)
        case kMinute..<120:
            return String(format: "1分钟前")
        case 120..<kMinute*60:
            return String(format: "%d分钟前", deltaSeconds/60)
        case kMinute*60..<120*60:
            return String(format: "1小时前")
        case 120*60..<kDay*60:
            let value = Int(floor(Float(deltaSeconds/60/kMinute)))
            return String(format: "%d小时前", value)
        case kDay*60..<kDay*120:
            return String(format: "1天前")
        case kDay*120..<kYear*60:
            let value = Int(floor(Float(deltaSeconds/60/kDay)))
            return String(format: "%d天前", value)
        default:
            return self.toString()
        }
    }

}
