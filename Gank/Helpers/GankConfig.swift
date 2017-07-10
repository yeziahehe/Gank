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

    class func getScreenRect() -> CGRect {
        return UIScreen.main.bounds
    }
    
    class func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    class func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

}
