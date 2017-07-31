//
//  NoDataFooterCollectionView.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/30.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class NoDataFooterCollectionView: UICollectionReusableView {
    
    public var reloadAction: (() -> Void)?
    public var reasonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(didReload(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc fileprivate func didReload(_ sender: UITapGestureRecognizer) {
        reloadAction?()
    }

    @IBAction func showReason(_ sender: Any) {
        reasonAction?()
    }
    
}
