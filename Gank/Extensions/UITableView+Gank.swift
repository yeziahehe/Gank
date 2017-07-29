//
//  UITableView+Gank.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/24.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension UITableView {
    
    enum WayToUpdate {
        
        case none
        case reloadData
        case reloadIndexPaths([IndexPath])
        
        var needsLabor: Bool {
            
            switch self {
            case .none:
                return false
            case .reloadData:
                return true
            case .reloadIndexPaths:
                return true
            }
        }
        
        func performWithTableView(_ tableView: UITableView) {
            
            switch self {
                
            case .none:
                print("tableView WayToUpdate: None")
                break
                
            case .reloadData:
                print("tableView WayToUpdate: ReloadData")
                SafeDispatch.async {
                    tableView.reloadData()
                }
                
            case .reloadIndexPaths(let indexPaths):
                print("tableView WayToUpdate: ReloadIndexPaths")
                SafeDispatch.async {
                    tableView.reloadRows(at: indexPaths, with: .none)
                }
            }
        }
    }
}

extension UITableView {
    
    func registerClassOf<T: UITableViewCell>(_: T.Type) where T: Reusable {
        
        register(T.self, forCellReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func registerNibOf<T: UITableViewCell>(_: T.Type) where T: Reusable, T: NibLoadable {
        
        let nib = UINib(nibName: T.gank_nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func registerHeaderFooterClassOf<T: UITableViewHeaderFooterView>(_: T.Type) where T: Reusable {
        
        register(T.self, forHeaderFooterViewReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: Reusable {
        
        guard let cell = self.dequeueReusableCell(withIdentifier: T.gank_reuseIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.gank_reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T where T: Reusable {
        
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.gank_reuseIdentifier) as? T else {
            fatalError("Could not dequeue HeaderFooter with identifier: \(T.gank_reuseIdentifier)")
        }
        
        return view
    }
}
