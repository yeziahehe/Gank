//
//  SegueViewController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class SegueViewController: UIViewController {
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        if let navigationController = navigationController {
            guard navigationController.topViewController == self else {
                return
            }
        }
        
        super.performSegue(withIdentifier: identifier, sender: sender)
    }
}
