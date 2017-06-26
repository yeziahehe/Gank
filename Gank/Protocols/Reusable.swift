//
//  Reusable.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/24.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol Reusable: class {
    
    static var gank_reuseIdentifier: String { get }
}

extension UITableViewCell: Reusable {
    
    static var gank_reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView: Reusable {
    
    static var gank_reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: Reusable {
    
    static var gank_reuseIdentifier: String {
        return String(describing: self)
    }
}

