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
    
    #if DEBUG
    private lazy var newFPSLabel: FPSLabel = {
        let label = FPSLabel()
        return label
    }()
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = UIColor.white
        
        #if DEBUG
            view.addSubview(newFPSLabel)
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navigationController = navigationController else {
            return
        }
        
        navigationController.navigationBar.tintColor = UIColor.gankNavgationBarTitleColor()
        navigationController.navigationBar.barTintColor = UIColor.gankNavgationBarTitleColor()
        navigationController.navigationBar.backgroundColor = nil
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.shadowImage = nil
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.setBackgroundImage(UIImage.gank_navBg, for: .default)
        navigationController.navigationBar.backIndicatorImage = UIImage.gank_navBack
        navigationController.navigationBar.backIndicatorTransitionMaskImage = UIImage.gank_navBack
        
        if navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: animatedOnNavigationBar)
        }
    }

}
