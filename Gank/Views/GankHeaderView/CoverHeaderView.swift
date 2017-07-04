//
//  CoverHeaderView.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/3.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import Kingfisher

class CoverHeaderView: UIView {

    @IBOutlet weak var meiziImageView: UIImageView!
    @IBOutlet weak var dateBackImageView: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(meiziData meiziDetail: Gank) {
        KingfisherManager.shared.retrieveImage(with: URL(string: meiziDetail.url)!, options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            SafeDispatch.async { [weak self] in
                if let image = image {
                    self?.meiziImageView.set(image:image, focusOnFaces:true)
                }
            }
        }
        dateBackImageView.image = UIImage.gank_dateBg
        dayLabel.text = meiziDetail.publishedAt.toTimeFormat.toDateOfSecond()!.dayToString()
        monthLabel.text = meiziDetail.publishedAt.toTimeFormat.toDateOfSecond()!.monthToNameString()
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
