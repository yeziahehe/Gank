//
//  YFShareProtocol.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/20.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

public protocol YFShareViewDelegate: class {
    
    /// Will Present YFMoreOperationViewController.
    /// - Parameters:
    ///     - moreOperation: The YFMoreOperation ViewController requesting this information.
    ///     - tag: The YFMoreOperationItem Tag.
    func shareview(_ shareview: YFShareViewController, didSelectItemAt index: Int, type: YFShareItemType)
}
