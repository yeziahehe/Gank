//
//  GankShareService.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/8.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import MonkeyKing

final class GankShareService: NSObject {
    
    static let shared = GankShareService()
    var accessToken: String?
    public let pocketBaseURL = URL(string: "https://getpocket.com/v3")!
    
    public func saveUrl(title: String, url: String, failureHandler: FailureHandler?, completion: @escaping (Int) -> Void) {
        guard let accessToken = accessToken else {
            OAuth()
            return
        }
        
        let parameters = [
            "url": url,
            "title": title,
            "consumer_key": GankConfig.Pocket.appID,
            "access_token": accessToken
        ]
        
        let parse: (JSON) -> Int? = { data in
            return data["status"].intValue
        }
        let resource = jsonResource(path: "/add", method: .post, requestParameters: parameters, parse: parse)
        
        apiRequest({_ in}, baseURL: pocketBaseURL, resource: resource, failure: failureHandler , completion: completion)
    }
    
    public func OAuth(){
        
        let parameters: Parameters = [
            "consumer_key": GankConfig.Pocket.appID,
            "redirect_uri": GankConfig.Pocket.redirectURL,
        ]
        
        gankLog.debug("S1: fetch requestToken")
        
        let parse: (JSON) -> JSON? = { data in
            return data
        }
        let resource = jsonResource(path: "/oauth/request", method: .post, requestParameters: parameters, parse: parse)
        
        apiRequest({_ in}, baseURL: pocketBaseURL, resource: resource, failure: { (error, message) in
        }, completion: { info in
            let requestToken = info["code"].stringValue
            
            gankLog.debug("S2: OAuth by requestToken: \(requestToken)")
            
            MonkeyKing.oauth(for: .pocket, requestToken: requestToken) { (dictionary, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                let parameters = [
                    "consumer_key": GankConfig.Pocket.appID,
                    "code": requestToken
                ]
                
                gankLog.debug("S3: fetch OAuth state")
                
                let parse: (JSON) -> JSON? = { data in
                    return data
                }
                let resource = jsonResource(path: "/oauth/authorize", method: .post, requestParameters: parameters, parse: parse)
                
                apiRequest({_ in}, baseURL: self.pocketBaseURL, resource: resource, failure: { (error, message) in
                    }, completion: { info in
                    
                    gankLog.debug("S4: OAuth completion")
                    
                    gankLog.debug("JSON: \(String(describing: info))")
                    gankLog.debug("response: \(String(describing: response))")
                    
                    self.accessToken = info["access_token"].stringValue
                })
            }
        })
    }
}
