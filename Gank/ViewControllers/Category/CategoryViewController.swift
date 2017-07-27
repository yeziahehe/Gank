//
//  CategoryViewController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class CategoryViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "showArticle":
            let vc = segue.destination as! ArticleViewController
            let categoryButton = sender as! UIButton
            let categoryEnum: category = category(rawValue: categoryButton.tag)!
            switch categoryEnum {
            case .all:
                vc.category = "all"
                break
            case .ios:
                vc.category = "iOS"
                break
            case .android:
                vc.category = "Android"
                break
            case .frontend:
                vc.category = "前端"
                break
            case .resource:
                vc.category = "拓展资源"
                break
            case .app:
                vc.category = "App"
                break
            case .recomm:
                vc.category = "瞎推荐"
                break
            case .video:
                vc.category = "休息视频"
            }
            
        default:
            break
        }
    }
    
    enum category: Int {
        case all = 0
        case ios
        case android
        case frontend
        case resource
        case app
        case recomm
        case video
    }
    
    @IBAction func showArticle(_ sender: Any?) {
        self.performSegue(withIdentifier: "showArticle", sender: nil)
    }
    
}
