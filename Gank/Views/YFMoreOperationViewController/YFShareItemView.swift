//
//  YFShareItemView.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/20.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

public class YFShareItemView: UIButton {
    
    var itemType: YFShareItemType!
    var itemTag: String!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.numberOfLines = 0
        imageView?.backgroundColor = UIColor.clear
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel?.numberOfLines = 0
        imageView?.backgroundColor = UIColor.clear
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var size = size
        
        if self.bounds.size == size {
            size = CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }
        
        var resultSize = CGSize.zero
        let contentLimitSize = size
        
        let imageLimitWidth = contentLimitSize.width - imageEdgeInsets.top - imageEdgeInsets.bottom
        let imageSize = imageView!.sizeThatFits(CGSize(width: imageLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.top - titleEdgeInsets.bottom, height: contentLimitSize.height - imageEdgeInsets.top - imageEdgeInsets.bottom - imageSize.height - titleEdgeInsets.top - titleEdgeInsets.bottom)
        var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
        titleSize.height = fmin(titleSize.height, titleLimitSize.height)
        
        resultSize.width = fmax(imageEdgeInsets.left + imageEdgeInsets.right + imageSize.width, titleEdgeInsets.left + titleEdgeInsets.right + titleSize.width)
        resultSize.height = imageEdgeInsets.top + imageEdgeInsets.bottom + imageSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom + titleSize.height
        
        return resultSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.isEmpty {
            return
        }
        
        let contentSize = bounds.size
        
        let imageLimitWidth = contentSize.width - imageEdgeInsets.top - imageEdgeInsets.bottom
        let imageSize = imageView!.sizeThatFits(CGSize(width: imageLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        var imageFrame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        
        
        let titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.left - titleEdgeInsets.right, height: contentSize.height - imageEdgeInsets.top - imageEdgeInsets.bottom - imageSize.height - titleEdgeInsets.top - titleEdgeInsets.bottom)
        var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
        titleSize.height = fmin(titleSize.height, titleLimitSize.height)
        var titleFrame = CGRect(x: 0, y: 0, width: titleSize.width, height: titleSize.height)
        
        imageFrame.origin.x = imageEdgeInsets.left + (imageLimitWidth - imageSize.width)/2
        titleFrame.origin.x = titleEdgeInsets.left + (titleLimitSize.width - titleSize.width)/2
        
        let contentHeight = imageFrame.height + imageEdgeInsets.top + imageEdgeInsets.bottom + titleFrame.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        let minY = (contentSize.height - contentHeight)/2
        imageFrame.origin.y = minY + imageEdgeInsets.top
        titleFrame.origin.y = imageFrame.maxY + imageEdgeInsets.bottom + titleEdgeInsets.top
        
        imageView?.frame = imageFrame
        titleLabel?.frame = titleFrame
    }
    
}

