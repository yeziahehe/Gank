//
//  VersionFooterView.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/3.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class VersionFooterView: UIView {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        versionLabel.text = String(format:"v%@（Build %@）", Bundle.releaseVersionNumber!, Bundle.buildVersionNumber!)
    }
    
    class func instanceFromNib() -> VersionFooterView {
        return UINib(nibName: "VersionFooterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! VersionFooterView
    }
    
}
