//
//  NoDataFooterView.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/27.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class NoDataFooterView: UIView {
    
    public var reloadAction: (() -> Void)?
    public var reasonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didReload(_:)))
        self.addGestureRecognizer(tap)
    }
    
    class func instanceFromNib() -> NoDataFooterView {
        return UINib(nibName: "NoDataFooterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NoDataFooterView
    }
    
    @objc fileprivate func didReload(_ sender: UITapGestureRecognizer) {
        reloadAction?()
    }

    @IBAction func showReason(_ sender: Any) {
        reasonAction?()
    }
}
