//
//  NetworkViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/27.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class NetworkViewController: BaseViewController {

    @IBOutlet weak var reasonTextView: UITextView!
    
    deinit {
        gankLog.debug("deinit NetworkViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reasonTextView.setLineHeight(lineHeight: 1.2)
    }
    
}
