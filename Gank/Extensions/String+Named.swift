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
    
    static var titleKnown: String {
        return "知道了"
    }
    
    static var titleToday: String {
        return "干货更新啦"
    }
    
    static var messageNoDailyGank: String {
        return "今日干货未更新，有新干货会第一时间推送给你~"
    }
    
    static var messageTodayGank: String {
        return "今天的干货很棒，欢迎戳来看预览~ "
    }
}
