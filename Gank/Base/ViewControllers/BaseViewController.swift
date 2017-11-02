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
        navigationController.navigationBar.barTintColor = UIColor.gankNavgationBarTintColor()
        navigationController.navigationBar.backgroundColor = nil
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.shadowImage = nil
        navigationController.navigationBar.barStyle = .default
        
        let gradient = CAGradientLayer()
        let sizeLength = UIScreen.main.bounds.size.height * 2
        let sizeHeight: CGFloat = UIDevice.current.iPhoneX ? 88.0 : 64.0
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: sizeLength, height: sizeHeight)
        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor.gankNavgationBarGradientStartColor().cgColor, UIColor.gankNavgationBarGradientEndColor().cgColor]
        
        navigationController.navigationBar.setBackgroundImage(UIImage.image(fromLayer: gradient) , for: .default)
        navigationController.navigationBar.backIndicatorImage = UIImage.gank_navBack
        navigationController.navigationBar.backIndicatorTransitionMaskImage = UIImage.gank_navBack
        
        if navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: animatedOnNavigationBar)
        }
    }

}
