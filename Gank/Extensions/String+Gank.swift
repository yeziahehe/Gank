//
//  String+Gank.swift
//  Gank
//
//  Created by 叶帆 on 2017/6/26.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension String {
    
    public func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
    public func toDateOfSecond() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
    public func toGankUrl() -> String {
        let stringArray = self.components(separatedBy: "/")
        return String(format:"此网页由 %@ 提供", stringArray[2])
        
    }
    
    public var toTimeFormat: String {
        var string = self.replacingOccurrences(of: "T", with: " ")
        string = String(string[startIndex...string.index(startIndex, offsetBy: 18)])
        return string
    }
    
    public var toChineseMonth: String {
        switch self {
        case "01":
            return "一月"
        case "02":
            return "二月"
        case "03":
            return "三月"
        case "04":
            return "四月"
        case "05":
            return "五月"
        case "06":
            return "六月"
        case "07":
            return "七月"
        case "08":
            return "八月"
        case "09":
            return "九月"
        case "10":
            return "十月"
        case "11":
            return "十一月"
        case "12":
            return "十二月"
        default:
            return ""
        }
    }
    
}

