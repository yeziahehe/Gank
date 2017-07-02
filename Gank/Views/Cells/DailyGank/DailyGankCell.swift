//
//  DailyGankCell.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/20.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class DailyGankCell: UITableViewCell {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    func configure(withGankDetail gankDetail: Gank) {
        timeLabel.text = gankDetail.publishedAt.toTimeFormat.toDateOfSecond()!.timeAgo
        titleLabel.text = gankDetail.desc
        guard let who = gankDetail.who else {
            authorLabel.text = "via. 机器人"
            return
        }
        authorLabel.text = String(format:"via. %@", who)
        
    }
    
}
