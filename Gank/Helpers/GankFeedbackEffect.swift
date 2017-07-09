//
//  GankFeedbackEffect.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/9.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final public class GankFeedbackEffect: NSObject {
    
    var feedbackGenerator : UIImpactFeedbackGenerator?
    
    public init(style: UIImpactFeedbackStyle) {
        super.init()
        feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        if let feedbackGenerator = feedbackGenerator {
            feedbackGenerator.prepare()
        }
    }
    
    deinit {
        feedbackGenerator = nil
    }
    
    public func play() {
        if let feedbackGenerator = feedbackGenerator {
            feedbackGenerator.impactOccurred()
        }
    }
}
