//
//  GankConfig.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/1.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class GankConfig {
    
    public static var tabbarSoundEffectAction: (() -> Void)?
    public static var heavyFeedbackEffectAction: (() -> Void)?
    
    public static let appGroupID: String = "group.coryphaei.Gank"

    class func getScreenRect() -> CGRect {
        return UIScreen.main.bounds
    }
    
    class func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    class func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    struct NotificationName {
        static let chooseGank = Notification.Name(rawValue: "GankConfig.Notification.chooseGank")
        static let watchNew = Notification.Name(rawValue: "GankConfig.Notification.watchNew")
    }
    
    // Share
    struct Weibo {
        static let appID = "319020087"
        static let appKey = "0710a11f0afb95b52377a0fbcfa309f8"
        static let redirectURL = "http://gank.io"
    }
    
    struct Wechat {
        static let appID = "wx1e11dfd8e7673779"
        static let appKey = "85b84783349fdba9472bd437de1cb899"
    }
    
    struct QQ {
        static let appID = "101415627"
    }
    
    struct Pocket {
        static let appID = "69596-6856d7b60049116e92ae8b46"
        static let redirectURL = "pocketapp69596:authorizationFinished" // pocketapp + $prefix + :authorizationFinished
    }

}
