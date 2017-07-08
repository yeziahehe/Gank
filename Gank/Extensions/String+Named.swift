//
//  String+Named.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/8.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension String {
    
    static func titleDailyGankAuthor(_ author: String) -> String{
        return String(format:"via. %@", author)
    }
    
}

extension String {
    static var titleDailyGankAuthorBot: String {
        return "via. 机器人"
    }
}
