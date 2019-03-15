//
//  UICollectionView+Gank.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/30.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    enum WayToUpdate {
        
        case none
        case reloadData
        
        var needsLabor: Bool {
            
            switch self {
            case .none:
                return false
            case .reloadData:
                return true
            }
        }
        
        func performWithCollectionView(_ collectionView: UICollectionView) {
            
            switch self {
                
            case .none:
                print("CollectionView WayToUpdate: None")
                break
                
            case .reloadData:
                print("CollectionView WayToUpdate: ReloadData")
                SafeDispatch.async {
                    collectionView.reloadData()
                }
            }
        }
    }
}

extension UICollectionView {
    
    func registerClassOf<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        
        register(T.self, forCellWithReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func registerNibOf<T: UICollectionViewCell>(_: T.Type) where T: Reusable, T: NibLoadable {
        
        let nib = UINib(nibName: T.gank_nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func registerHeaderNibOf<T: UICollectionReusableView>(_: T.Type) where T: Reusable, T: NibLoadable {
        
        let nib = UINib(nibName: T.gank_nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func registerHeaderClassOf<T: UICollectionReusableView>(_: T.Type) where T: Reusable {
        
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func registerFooterClassOf<T: UICollectionReusableView>(_: T.Type) where T: Reusable {
        
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func registerFooterNibOf<T: UICollectionReusableView>(_: T.Type) where T: Reusable, T: NibLoadable {
        
        let nib = UINib(nibName: T.gank_nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.gank_reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.gank_reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.gank_reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        
        guard let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.gank_reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(T.gank_reuseIdentifier), kind: \(kind)")
        }
        
        return view
    }
}

