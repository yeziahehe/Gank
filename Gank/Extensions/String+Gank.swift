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
    
    public var toTimeFormat: String {
        var string = self.replacingOccurrences(of: "T", with: " ")
        string = string[startIndex...string.index(startIndex, offsetBy: 18)]
        return string
    }
    
}

