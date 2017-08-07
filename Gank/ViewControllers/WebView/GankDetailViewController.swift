//
//  GankDetailViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/18.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import WebKit
import YFMoreViewController
import MonkeyKing

class GankDetailViewController: BaseViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    public var gankURL: String!
    
    fileprivate lazy var closeButtonItem: UIBarButtonItem = {
        let closeButtonItem = UIBarButtonItem.init(title: "关闭", style: .plain, target: self, action: #selector(closeItemClicked))
        return closeButtonItem
    }()
    
    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        closeButton.frame = CGRect(x: 0, y: 0, width: 35, height: 44)
        closeButton.setTitle("关闭", for: UIControlState())
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        closeButton.contentHorizontalAlignment = .left
        closeButton.setTitleColor(UIColor.white, for: UIControlState())
        closeButton.addTarget(self, action: #selector(closeItemClicked), for: .touchUpInside)
        return closeButton
    }()
    
    fileprivate lazy var customBackBarItem: UIBarButtonItem = {
        let customBackBarItem = UIBarButtonItem.init(image: UIImage.gank_navBack, style: .plain, target: self, action: #selector(customBackItemClicked))
        customBackBarItem.imageInsets = UIEdgeInsetsMake(0, -8, 0, 0)
        return customBackBarItem
    }()
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
        gankLog.debug("deinit GankDetailViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addWKWebView()
        addProgressView()
        
        webView.load(URLRequest(url: URL(string: gankURL)!))
    }
    
    fileprivate func addWKWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: GankConfig.getScreenHeight()-64), configuration: webConfiguration)
        
        webView.allowsBackForwardNavigationGestures = true
        
        webView?.navigationDelegate = self
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        webView.sizeToFit()
        
        view.addSubview(webView)
    }
    
    fileprivate func addProgressView() {
        
        progressView = UIProgressView.init(frame: CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: 2))
        view.addSubview(progressView)
        progressView?.trackTintColor = UIColor.clear
        progressView?.progressTintColor = UIColor.gankTintColor()
        
        view.addSubview(progressView!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "estimatedProgress"){
            progressView.alpha = 1.0
            let animated = Float(webView.estimatedProgress) > progressView.progress;
            progressView.setProgress(Float(webView.estimatedProgress), animated: animated)
            
            if Float(webView.estimatedProgress) >= 1.0{
                UIView.animate(withDuration: 1, delay:0.01,options:UIViewAnimationOptions.curveEaseOut, animations:{()-> Void in
                    self.progressView.alpha = 0.0
                },completion:{(finished:Bool) -> Void in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        } else if (keyPath == "title") {
            title = webView.title;
        }
        
        updateNavigationItems()
    }
}

extension GankDetailViewController {
    
    @objc fileprivate func customBackItemClicked() {
        if (webView.goBack() != nil) {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func closeItemClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func updateNavigationItems(){
        if webView.canGoBack {
            navigationItem.setLeftBarButtonItems([customBackBarItem, UIBarButtonItem(customView:closeButton)], animated: false)
        } else {
            navigationItem.setLeftBarButtonItems([customBackBarItem],animated: false)
        }
        
    }
    
    @IBAction func showMore(_ sender: UIBarButtonItem) {
        let moreViewController = YFMoreViewController.init()
        moreViewController.delegate = self
                
        moreViewController.addInfo(gankURL.toGankUrl())
        if MonkeyKing.SupportedPlatform.weChat.isAppInstalled {
            moreViewController.addItems(title: "微信", image: #imageLiteral(resourceName: "wechat"), type: .important, tag: "wechat")
            moreViewController.addItems(title: "朋友圈", image: #imageLiteral(resourceName: "moments"), type: .important, tag: "moments")
        }
        if MonkeyKing.SupportedPlatform.weibo.isAppInstalled {
            moreViewController.addItems(title: "微博", image: #imageLiteral(resourceName: "weibo"), type: .important, tag: "weibo")
        }
        if MonkeyKing.SupportedPlatform.qq.isAppInstalled {
            moreViewController.addItems(title: "QQ", image: #imageLiteral(resourceName: "QQ"), type: .important, tag: "QQ")
            moreViewController.addItems(title: "QQ空间", image: #imageLiteral(resourceName: "QQZone"), type: .important, tag: "QQZone")
        }
        if MonkeyKing.SupportedPlatform.pocket.isAppInstalled {
            moreViewController.addItems(title: "Pocket", image: #imageLiteral(resourceName: "Pocket"), type: .important, tag: "Pocket")
        }
        //moreViewController.addItems(title: "印象笔记", image: #imageLiteral(resourceName: "evernote"), type: .important, tag: "evernote")
        //moreViewController.addItems(title: "有道云笔记", image: #imageLiteral(resourceName: "youdao"), type: .important, tag:"youdao")
        moreViewController.addItems(title: "系统", image: #imageLiteral(resourceName: "more"), type: .important, tag: "Activity")
        moreViewController.addItems(title: "Safari打开", image: #imageLiteral(resourceName: "safari"), type: .normal, tag:"safari")
        moreViewController.addItems(title: "复制链接", image: #imageLiteral(resourceName: "copylink"), type: .normal, tag:"copylink")
        moreViewController.addItems(title: "刷新", image: #imageLiteral(resourceName: "refresh"), type: .normal, tag:"refresh")
        //moreViewController.addItems(title: "搜索页面内容", image: #imageLiteral(resourceName: "search"), type: .normal, tag:"search")
        
        moreViewController.showFromBottom()
    }
    
}

extension GankDetailViewController: YFMoreViewDelegate {
    
    func moreView(_ moreview: YFMoreViewController, didSelectItemAt tag: String, type: YFMoreItemType) {
        let url = URL(string: gankURL)!
        let title = self.title!
        let info = MonkeyKing.Info(
            title: title,
            description: gankURL,
            thumbnail: UIImage.gank_logo,
            media: .url(url)
        )
        switch tag {
        case "wechat":
            MonkeyKing.deliver(.weChat(.session(info: info))) { result in
                print("result: \(result)")
            }
            return
        case "moments":
            MonkeyKing.deliver(.weChat(.timeline(info: info))) { result in
                print("result: \(result)")
            }
            return
        case "weibo":
            MonkeyKing.deliver(.weibo(.default(info: info, accessToken: nil))) { result in
                print("result: \(result)")
            }
            return
        case "QQ":
            MonkeyKing.deliver(.qq(.friends(info: info))) { result in
                print("result: \(result)")
            }
            return
        case "QQZone":
            MonkeyKing.deliver(.qq(.zone(info: info))) { result in
                print("result: \(result)")
            }
            return
        case "Pocket":
            
            return
        case "Activity":
            let activityViewController = UIActivityViewController(activityItems: [title, UIImage.gank_logo, url], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
            return
        case "safari":
            UIApplication.shared.open(URL(string: gankURL)!, options: [:], completionHandler: nil)
            return
        case "copylink":
            let paste = UIPasteboard.general
            paste.string = gankURL
            GankHUD.success("已复制到剪贴板")
            return
        case "refresh":
            webView.load(URLRequest(url: URL(string: gankURL)!))
            return
        default:
            return
        }
    }
    
}
