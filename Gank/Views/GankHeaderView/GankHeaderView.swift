//
//  GankHeaderView.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/2.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class GankHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(titleString string: String) {
        titleLabel.text = string
    }
    
    class func instanceFromNib() -> GankHeaderView {
        return UINib(nibName: "GankHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! GankHeaderView
        
//        return Bundle.main.loadNibNamed("GankHeaderView", owner: nil, options: nil)?.last as! GankHeaderView
    }
    
}
