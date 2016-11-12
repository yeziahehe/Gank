//
//  GankService.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/7.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire

public let gankHost = "gank.io"
public let gankBaseURL = URL(string: "http://gank.io/api")!

// MARK: - 干货历史日期

public struct GankHistoryDate {
    public let date: String
    
//    public var hasGankToday: Bool {
//        
//    }
//    
//    public func hasGank(_ date: Date -> Bool) {
//        
//    }
}


public func allGankHistoryDate(failureHandler: FailureHandler?, completion: @escaping (JSONDictionary) -> Void) {
    
    let parse: (JSONDictionary) -> JSONDictionary? = { data in
        return data
    }
    
    let resource = jsonResource(path: "/day/history", method: .get, requestParameters: [:], parse: parse)
    
    apiRequest({_ in}, baseURL: gankBaseURL, resource: resource, failure: failureHandler, completion: completion)

}
