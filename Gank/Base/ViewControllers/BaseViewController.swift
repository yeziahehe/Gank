//
//  BaseViewController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class BaseViewController: SegueViewController {
    
    var animatedOnNavigationBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navigationController = navigationController else {
            return
        }
        
        navigationController.navigationBar.barTintColor = UIColor.gankNavgationBarTitleColor()
        navigationController.navigationBar.backgroundColor = nil
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.shadowImage = nil
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.setBackgroundImage(UIImage.gank_navBg, for: .default)
        
        if navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: animatedOnNavigationBar)
        }
    }

}
