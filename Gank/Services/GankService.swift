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
public let githubBaseURL = URL(string: "https://api.github.com")!

// MARK: - 干货历史日期
public func allGankHistoryDate(failureHandler: FailureHandler?, completion: @escaping (Array<String>) -> Void) {
    
    let parse: (JSON) -> Array<String>? = { data in
        let historyDateArray = data["results"].arrayValue.map({$0.stringValue})
        GankUserDefaults.historyDate.value = historyDateArray
        return historyDateArray
    }
    
    let resource = urlResource(path: "/day/history", method: .get, requestParameters: nil, parse: parse)
    
    apiRequest({_ in}, baseURL: gankBaseURL, resource: resource, failure: failureHandler, completion: completion)

}

// MARK: - 最近一次有干货的日期并判断是否是今天
public func lastestGankDate(failureHandler: FailureHandler?, completion: @escaping (Bool, String) -> Void) {
    let parse: (JSON) -> (Bool, String)? = { data in
        GankUserDefaults.historyDate.value = data["results"].arrayValue.map({$0.stringValue})
        let lastestDate = data["results"][0].stringValue
        let now = Date()
        return (lastestDate == now.toString(), lastestDate)
    }
    
    let resource = urlResource(path: "/day/history", method: .get, requestParameters: nil, parse: parse)
    
    apiRequest({_ in}, baseURL: gankBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// MARK: - Ganks Model

public struct Gank {
    public let id: String
    public let createdAt: String?
    public let desc: String
    public let images: String?
    public let publishedAt: String
    public let source: String?
    public let type: String
    public let url: String
    public let used: Bool?
    public let who: String?
        
    public init(id: String, createdAt: String?, desc: String, images: String?, publishedAt: String, source: String?, type: String, url: String, used: Bool?, who: String?) {
        self.id = id;
        self.createdAt = createdAt;
        self.desc = desc;
        self.images = images;
        self.publishedAt = publishedAt;
        self.source = source;
        self.type = type;
        self.url = url;
        self.used = used;
        self.who = who;
    }
    
    public var hashValue: Int {
        return id.hashValue
    }
    
    public static func fromJSON(_ gankInfo: JSON) -> Gank? {
        guard let
            desc = gankInfo["desc"].string,
            let publishedAt = gankInfo["publishedAt"].string,
            let type = gankInfo["type"].string,
            let url = gankInfo["url"].string else {
            return nil
        }
        
        var gankID: String = ""
        if gankInfo["_id"].string != nil {
            gankID = gankInfo["_id"].string!
        } else if gankInfo["ganhuo_id"].string != nil {
            gankID = gankInfo["ganhuo_id"].string!
        } else {
            return nil
        }
        
        let createdAt = gankInfo["createdAt"].string
        let source = gankInfo["source"].string
        let images = gankInfo["images"].string
        let used = gankInfo["used"].bool
        let who = gankInfo["who"].string
        
        return Gank(id: gankID, createdAt:createdAt, desc: desc, images: images, publishedAt: publishedAt, source: source, type: type, url: url, used: used, who: who)
    }
}

// MARK: - 某日干货
public func gankWithDay(date: String, failureHandler: FailureHandler?, completion: @escaping (Bool, Gank, Array<String>, Dictionary<String, Array<Gank>>) -> Void) {
    
    
    let parse: (JSON) -> (Bool, Gank, Array<String>, Dictionary<String, Array<Gank>>)? = { data in
        
        let categoryArray: [String] = data["category"].arrayValue.map({$0.stringValue})
        let categories = GankUserDefaults.version.value! ?  Array<String>().sortByGankOrder(categoryArray) : Array<String>().sortByGankOrder(categoryArray).filter({$0 != "Android"}) // 审核，禁止 Android
        let now = Date()
        var gank: [String: Array<Gank>] = [:]
        var meiziGank: Gank!
        
        for (key, gankArrayJSON):(String, JSON) in data["results"] {
            var gankArray = [Gank]()
            for (_, gankJSON):(String, JSON) in gankArrayJSON {
                let gankInfo = Gank.fromJSON(gankJSON)
                gankArray.append(gankInfo!)
            }
            
            if key == "福利" {
                meiziGank = gankArray[0]
            }
            
            gank[key] = gankArray
        }
        
        return (date == now.toString(), meiziGank, categories, gank)
    }
    
    let dateFormat = date.replacingOccurrences(of: "-", with: "/")
    let resource = urlResource(path: "/day/\(dateFormat)", method: .get, requestParameters: nil, parse: parse)
    
    apiRequest({_ in}, baseURL: gankBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// MARK: - 最近一天干货
public func gankLatest(failureHandler: FailureHandler?, completion: @escaping (Bool, Gank, Array<String>, Dictionary<String, Array<Gank>>) -> Void) {
    
    lastestGankDate(failureHandler: failureHandler, completion:{ (_, date) in
        gankWithDay(date: date, failureHandler: failureHandler, completion: completion)
    })
    
}

// MARK: - 今日干货
public func gankInToday(failureHandler: FailureHandler?, completion: @escaping (Bool, Gank, Array<String>, Dictionary<String, Array<Gank>>) -> Void) {
    
    gankWithDay(date: Date().toString(), failureHandler: failureHandler, completion: completion)
    
}

// MARK: - 干货分类
public func gankofCategory(category: String, count: Int = 20, page: Int, failureHandler: FailureHandler?, completion: @escaping (Array<Gank>) -> Void) {
    
    // 审核，禁止 Android
    var newCategory = category
    if !GankUserDefaults.version.value! && category == "all" {
        newCategory = "iOS"
    }
    
    let parse: (JSON) -> (Array<Gank>)? = { data in
        var gankArray = [Gank]()
        for (_, gankJSON):(String, JSON) in data["results"] {
            let gankInfo = Gank.fromJSON(gankJSON)
            gankArray.append(gankInfo!)
        }
        return gankArray
    }
    let resource = urlResource(path: String(format:"/data/%@/%d/%d", newCategory, count, page), method: .get, requestParameters: nil, parse: parse)
    
    apiRequest({_ in}, baseURL: gankBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// MARK: - 搜索
public func gankSearch(query: String, category: String = "all", count: Int = 10, page: Int, failureHandler: FailureHandler?, completion: @escaping (Array<Gank>) -> Void) {
    let parse: (JSON) -> (Array<Gank>)? = { data in
        var gankArray = [Gank]()
        for (_, gankJSON):(String, JSON) in data["results"] {
            let gankInfo = Gank.fromJSON(gankJSON)
            if !GankUserDefaults.version.value! && gankInfo?.type == "Android" {
                continue
            }
            gankArray.append(gankInfo!)
        }
        return gankArray
    }
    let resource = urlResource(path: String(format:"/search/query/%@/category/%@/count/%d/page/%d", query, category, count, page), method: .get, requestParameters: nil, parse: parse)
    
    apiRequest({_ in}, baseURL: gankBaseURL, resource: resource, failure: failureHandler, completion: completion)
}

// MARK: - 提交干货
public func addToGank(url: String, desc: String, who: String, type: String, failureHandler: FailureHandler?, completion: @escaping () -> Void) {
    var debug: String = "false"
    #if DEBUG
        debug = "true"
    #endif
    let requestParameters: Parameters = [
        "url": url,
        "desc": desc,
        "who": who,
        "type": type,
        "debug": debug,
    ]
    
    let parse: (JSON) -> Void? = { data in
        return
    }
    let resource = urlResource(path: "/add2gank", method: .post, requestParameters: requestParameters, parse: parse)
    
    apiRequest({_ in}, baseURL: URL(string: "https://gank.io/api")!, resource: resource, failure: failureHandler, completion: completion)
}

// MARK: - GitHub User Model
public struct LoginUser: CustomStringConvertible {
    
    public let login: String
    public let avatarUrl: String
    public let name: String
    
    public var description: String {
        return "LoginUser(login: \(login), avatarUrl: \(avatarUrl), name: \(name))"
    }
    
    public static func fromJSON(_ data: JSON) -> LoginUser? {
        guard let login = data["login"].string,
              let avatarUrl = data["avatar_url"].string,
              let name = data["name"].string else {
                return nil
        }
        
        return LoginUser(login: login, avatarUrl: avatarUrl, name: name)
    }
}

public func saveUserInfoOfLoginUser(_ loginUser: LoginUser) {
    GankUserDefaults.login.value = loginUser.login
    GankUserDefaults.avatarUrl.value = loginUser.avatarUrl
    GankUserDefaults.name.value = loginUser.name
}

// GitHub 登录
public func loginWithGitHub(username: String, password: String, failureHandler: FailureHandler?, completion: @escaping (LoginUser) -> Void) {
    let parse: (JSON) -> (LoginUser)? = { data in
        return LoginUser.fromJSON(data)
    }
    
    let resource = authJsonResource(username: username, password: password, path: "/user", method: .get, parse: parse)
    
    apiRequest({_ in}, baseURL: githubBaseURL, resource: resource, failure: failureHandler, completion: completion)
}
