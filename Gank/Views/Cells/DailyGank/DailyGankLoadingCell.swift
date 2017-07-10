//
//  DailyGankLoadingCell.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/20.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class DailyGankLoadingCell: UITableViewCell {
    
    @IBOutlet var titleLoadingImageView: UIImageView!
    @IBOutlet var contentshortLoadingImageView: UIImageView!
    @IBOutlet var contentLongLoadingImageView: UIImageView!
    @IBOutlet var contentMediumLoadingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLoadingImageView.startShimmering()
        contentshortLoadingImageView.startShimmering()
        contentLongLoadingImageView.startShimmering()
        contentMediumLoadingImageView.startShimmering()
    }
}
