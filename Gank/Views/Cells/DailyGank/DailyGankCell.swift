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
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    func configure(withGankDetail gankDetail: Gank, isHiddenTag: Bool = true) {
        timeLabel.text = gankDetail.publishedAt.toTimeFormat.toDateOfSecond()!.timeAgo
        titleLabel.text = gankDetail.desc
        titleLabel.setLineHeight(lineHeight: 1.2)
        tagLabel.isHidden = isHiddenTag
        if isHiddenTag == false {
            tagLabel.text = String(format:" %@ ", gankDetail.type)
            switch gankDetail.type {
            case "iOS":
                tagLabel.backgroundColor = UIColor.gankIosTagColor()
                break
            case "Android":
                tagLabel.backgroundColor = UIColor.gankAndroidTagColor()
                break
            case "前端":
                tagLabel.backgroundColor = UIColor.gankFrontendTagColor()
                break
            case "拓展资源":
                tagLabel.backgroundColor = UIColor.gankResourceTagColor()
                break
            case "App":
                tagLabel.backgroundColor = UIColor.gankAppTagColor()
                break
            case "瞎推荐":
                tagLabel.backgroundColor = UIColor.gankRecommTagColor()
                break
            case "休息视频":
                tagLabel.backgroundColor = UIColor.gankVideoTagColor()
                break
            case "福利":
                tagLabel.backgroundColor = UIColor.gankMeiziTagColor()
                break
            default:
                break
            }
        }
        guard let who = gankDetail.who else {
            authorLabel.text = String.titleDailyGankAuthorBot
            return
        }
        authorLabel.text = String.titleDailyGankAuthor(who)
    }
    
}
