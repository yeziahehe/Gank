//
//  LoadMoreCollectionCell.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/30.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class LoadMoreCollectionCell: UICollectionViewCell {
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                loadingActivityIndicator.startAnimating()
            } else {
                loadingActivityIndicator.stopAnimating()
            }
        }
    }
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
