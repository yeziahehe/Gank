//
//  SettingCell.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/3.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet weak var annotationLabel: UILabel!
    @IBOutlet weak var newTag: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
