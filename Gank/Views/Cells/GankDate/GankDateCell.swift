//
//  GankDateCell.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/12.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import JTAppleCalendar

class GankDateCell: JTAppleCell {
    
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    
    func configure(_ cellState: CellState) {
        if cellState.isSelected {
            dayLabel.textColor = UIColor.white
            selectView.isHidden = false
        } else {
            selectView.isHidden = true
            if cellState.dateBelongsTo == .thisMonth {
                dayLabel.textColor = UIColor.gankTextColor()
            } else {
                dayLabel.textColor = UIColor.gankFooterColor()
            }
        }
        
    }
    
}
