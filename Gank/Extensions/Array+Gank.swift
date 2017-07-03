//
//  Array+Gank.swift
//  Gank
//
//  Created by 叶帆 on 2017/6/28.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension Array {
    
    public func sortByGankOrder(_ gankArray: [String]) -> Array<String> {
        
        let allCategories: [String] = ["福利", "iOS", "Android", "前端", "瞎推荐", "拓展资源", "App", "休息视频"]
        var sortedCategories: [String] = allCategories
        var gankCategories: [String] = gankArray
        
        for category in allCategories {
            var i: Int = 0
            for gankCategory in gankArray {
                guard gankCategory == category else {
                    i += 1
                    continue
                }
                gankCategories.remove(at: gankCategories.index(of: gankCategory)!)
                break
            }
            if i == gankArray.count {
                sortedCategories.remove(at: sortedCategories.index(of: category)!)
            }
        }
        
        // 处理数组中未出现的分类
        if !gankCategories.isEmpty {
            for newCategory in gankCategories {
                sortedCategories.append(newCategory)
            }
        }
        
        sortedCategories.remove(at: sortedCategories.index(of: "福利")!)
        
        return sortedCategories
    }
}
