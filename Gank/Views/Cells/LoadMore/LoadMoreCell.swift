//
//  LoadMoreCell.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/27.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class LoadMoreCell: UITableViewCell {
    
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
