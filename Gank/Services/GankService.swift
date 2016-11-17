//
//  GankService.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/7.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public let gankHost = "gank.io"
public let gankBaseURL = URL(string: "http://gank.io/api")!

// MARK: - 干货历史日期
public func allGankHistoryDate(failureHandler: FailureHandler?, completion: @escaping (Array<String>) -> Void) {
    
    let parse: (JSON) -> Array<String>? = { data in
        let historyDateArray = data["results"].arrayValue.map({$0.stringValue})
        return historyDateArray
    }
    
    let resource = Resource(path: "/day/history", method: .get, requestParamters: nil, parse: parse)
    
    apiRequest({_ in}, baseURL: gankBaseURL, resource: resource, failure: failureHandler, completion: completion)

}

// MARK: - 今日是否有干货
public func hasGankToday(failureHandler: FailureHandler?, completion: @escaping (Bool) -> Void) {
    let parse: (JSON) -> Bool? = { data in
        let lastestDate = data["results"][0].stringValue
        let now = Date()
        return lastestDate == now.toString()
    }
    
    let resource = Resource(path: "/day/history", method: .get, requestParamters: nil, parse: parse)
    
    apiRequest({_ in}, baseURL: gankBaseURL, resource: resource, failure: failureHandler, completion: completion)
}
