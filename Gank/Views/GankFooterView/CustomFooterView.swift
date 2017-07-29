//
//  CustomFooterView.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/3.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class CustomFooterView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    class func instanceFromNib() -> CustomFooterView {
        return UINib(nibName: "CustomFooterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomFooterView
    }

}
