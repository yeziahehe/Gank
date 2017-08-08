//
//  UserInfoCell.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/3.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class UserInfoCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure() {
        if GankUserDefaults.isLogined {
            nameLabel.text = GankUserDefaults.name.value
            loginLabel.text = GankUserDefaults.login.value
            avatarImageView.kf.setImage(with: URL(string: GankUserDefaults.avatarUrl.value!)!)
            isUserInteractionEnabled = false
        } else {
            nameLabel.text = "用 GitHub 登录"
            loginLabel.text = "登录后可提交干货"
            avatarImageView.image = nil
            isUserInteractionEnabled = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
