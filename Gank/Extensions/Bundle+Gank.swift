//
//  Bundle+Gank.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/31.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import Foundation

extension Bundle {
    
    static var releaseVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var buildVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}
