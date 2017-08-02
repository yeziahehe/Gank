//
//  SearchFooterView.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/2.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class SearchFooterView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    class func instanceFromNib() -> SearchFooterView {
        return UINib(nibName: "SearchFooterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SearchFooterView
    }

}
