//
//  GankHUD.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/1.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import JJHUD

public class GankHUD {
    
    public class func success(_ status: String!) {
        JJHUD.showSuccess(text: status, delay: 2.0)
    }
    
    public class func error(_ status: String!) {
        JJHUD.showError(text: status, delay: 2.0)
    }
    
    public class func show() {
        JJHUD.showLoading()
    }
    
    public class func dismiss() {
        JJHUD.hide()
    }
}
