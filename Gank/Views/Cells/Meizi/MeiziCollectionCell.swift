//
//  MeiziCollectionCell.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/30.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class MeiziCollectionCell: UICollectionViewCell {

    @IBOutlet weak var meiziImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(withGankDetail gankDetail: Gank) {
        timeLabel.text = gankDetail.publishedAt.toTimeFormat.toDateOfSecond()!.toString()
        meiziImage.kf.setImage(with: URL(string: gankDetail.url)!, placeholder: UIImage.gank_meiziLoading)
    }

}
