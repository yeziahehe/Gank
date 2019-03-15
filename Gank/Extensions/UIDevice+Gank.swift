//
//  UIDevice+Gank.swift
//  Gank
//
//  Created by 叶帆 on 2017/11/2.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    
    var iPhone5: Bool {
        return UIScreen.main.nativeBounds.width == 640
    }
    
    var iPhonePlus: Bool {
        return UIScreen.main.nativeBounds.width == 1080.0 || UIScreen.main.nativeBounds.width == 1242.0
    }
    
    var iPhoneXR: Bool {
        return UIScreen.main.nativeBounds.width == 828.0
    }
    
    var iPhoneXSMax: Bool {
        return (UIScreen.main.bounds.size.width == 414.0 &&  UIScreen.main.bounds.size.height == 896.0)
    }
    
    var iPhoneX_later: Bool {
        return iPhoneX || iPhoneXR || iPhoneXSMax
    }
}
