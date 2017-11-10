//
//  CategoryViewController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class CategoryViewController: BaseViewController {
    
    var categoryArray: [String] = []
    
    @IBOutlet weak var categoryCollectionView: UICollectionView! {
        didSet {
            categoryCollectionView.registerNibOf(CategoryCollectionCell.self)
        }
    }
    
    deinit {
        categoryCollectionView?.delegate = nil
        gankLog.debug("deinit CategoryViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryArray = GankUserDefaults.version.value! ? ["all", "iOS", "Android", "前端", "瞎推荐", "拓展资源", "App", "休息视频", "福利"] : ["all", "iOS", "前端", "瞎推荐", "拓展资源", "App", "休息视频", "福利"] // 审核，禁止 Android
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "showArticle":
            let vc = segue.destination as! ArticleViewController
            let categoryString = sender as! String
            vc.category = categoryString
            
        default:
            break
        }
    }
    
    @IBAction func showSearch(_ sender: Any) {
        self.performSegue(withIdentifier: "showSearch", sender: nil)
    }
    
}

extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoryCollectionCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(categoryArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if categoryArray[indexPath.row] == "福利" {
            self.performSegue(withIdentifier: "showMeizi", sender: nil)
        } else {
            self.performSegue(withIdentifier: "showArticle", sender: categoryArray[indexPath.row])
        }
    }
}
