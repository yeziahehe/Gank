//
//  UIApplication+Gank.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/4.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension UIApplication {
    
    func reviewOnTheAppStore() {
        
        let appID = "1164948361"
        
        guard let appURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8") else {
            return
        }
        
        if canOpenURL(appURL) {
            open(appURL, options: [:], completionHandler: nil)
        }
    }
}
