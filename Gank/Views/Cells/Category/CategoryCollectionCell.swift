//
//  CategoryCollectionCell.swift
//  Gank
//
//  Created by 叶帆 on 2017/11/8.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(_ category: String) {
        categoryLabel.text = category
        categoryImageView.image = UIImage(named: category)
    }

}
