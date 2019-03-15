//
//  YFMoreViewDelegate.swift
//  YFMoreViewController
//
//  Created by 叶帆 on 2017/8/3.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

public protocol YFMoreViewDelegate: class {
    
    func moreview(_ moreview: YFMoreViewController, didSelectItemAt index: Int, type: YFMoreItemType)
    
    func moreView(_ moreview: YFMoreViewController, didSelectItemAt tag: String, type: YFMoreItemType)
}

public extension YFMoreViewDelegate {
    func moreview(_ moreview: YFMoreViewController, didSelectItemAt index: Int, type: YFMoreItemType) {
        
    }
}

