//
//  NibLoadable.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/24.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol NibLoadable {
    
    static var gank_nibName: String { get }
}

extension UITableViewCell: NibLoadable {
    
    static var gank_nibName: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: NibLoadable {
    
    static var gank_nibName: String {
        return String(describing: self)
    }
}
