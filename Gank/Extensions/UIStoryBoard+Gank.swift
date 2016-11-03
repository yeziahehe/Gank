//
//  UIStoryBoard+Gank.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/29.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static var gank_main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    struct Scene {
        
        static var new: NewViewController {
            return UIStoryboard(name: "New", bundle: nil).instantiateViewController(withIdentifier: "NewViewController") as! NewViewController
        }
        
        static var category: CategoryViewController {
            return UIStoryboard(name: "Category", bundle: nil).instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
        }
        
        static var me: MeViewController {
            return UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
        }
        
    }
    
}
