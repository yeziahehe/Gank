//
//  GankHUD.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/1.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import PKHUD

public class GankHUD {
    
    public class func success(_ status: String!) {
        HUD.flash(.labeledSuccess(title: nil, subtitle: status), delay: 2.0)
    }
    
    public class func error(_ status: String!) {
        HUD.flash(.labeledError(title: nil, subtitle: status), delay: 2.0)
    }
    
    public class func show() {
        HUD.show(.progress)
    }
    
    public class func dismiss() {
        HUD.hide()
    }
}
