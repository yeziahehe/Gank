//
//  GankTabBarController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class GankTabBarController: UITabBarController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        gankLog.debug("deinit GankTabBarController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(GankTabBarController.refreshUIWithPush(_:)), name: GankConfig.NotificationName.push, object: nil)
    }
    
    
    @objc fileprivate func refreshUIWithPush(_ notification: Notification) {
        
        selectedIndex = 0
    }
}

// MARK: - UITabBarControllerDelegate

extension GankTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        GankConfig.tabbarSoundEffectAction?()
        
        if let nvc = viewController as? UINavigationController {
            nvc.popToRootViewController(animated: false)
        }
        
        
    }
}
