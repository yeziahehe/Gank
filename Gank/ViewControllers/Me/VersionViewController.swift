//
//  VersionViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/4.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class VersionViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GankUserDefaults.isVersionNewHidden.value == false {
            GankUserDefaults.isVersionNewHidden.value = true
            NotificationCenter.default.post(name: GankConfig.NotificationName.watchNew, object: nil)
        }
        
    }

}
