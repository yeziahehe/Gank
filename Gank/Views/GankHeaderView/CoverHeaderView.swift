//
//  CoverHeaderView.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/3.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher

class CoverHeaderView: UIView {

    @IBOutlet weak var meiziImageView: UIImageView!
    @IBOutlet weak var dateBackImageView: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(meiziData meiziDetail: Gank?) -> CGFloat {
        var height: CGFloat = 200
        
        guard let detail: Gank = meiziDetail else {
            meiziImageView.image = UIImage.gank_meiziLoadingBg
            return height
        }
        
        guard let data: Data = try? Data(contentsOf: URL(string: detail.url)!) else {
            meiziImageView.image = UIImage.gank_meiziLoadingBg
            return height
        }
        
        guard let image: UIImage = UIImage(data: data) else {
            meiziImageView.image = UIImage.gank_meiziLoadingBg
            return height
        }
        
        height = GankConfig.getScreenWidth() / image.size.width * image.size.height
            
        meiziImageView.image = image
        dateBackImageView.image = UIImage.gank_dateBg
        dayLabel.text = detail.publishedAt.toTimeFormat.toDateOfSecond()!.dayToString()
        monthLabel.text = detail.publishedAt.toTimeFormat.toDateOfSecond()!.monthToNameString()
        
        return height
    }
    
    func refresh() {
        meiziImageView.image = UIImage.gank_meiziLoadingBg
        dateBackImageView.image = UIImage.gank_dateLoadingBg
        dayLabel.text = ""
        monthLabel.text = ""
    }
    
    class func instanceFromNib() -> CoverHeaderView {
        return UINib(nibName: "CoverHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CoverHeaderView
        
    }
    
}
