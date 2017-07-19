//
//  GankDetailViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/18.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import WebKit

class GankDetailViewController: BaseViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    
    fileprivate lazy var closeButtonItem: UIBarButtonItem = {
        let closeButtonItem = UIBarButtonItem.init(title: "关闭", style: .plain, target: self, action: #selector(closeItemClicked))
        return closeButtonItem
    }()
    
    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
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
        customBackBarItem.imageInsets = UIEdgeInsetsMake(0, -15, 0, 0)
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
        
        let myURL = URL(string: "http://yeziahehe.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    fileprivate func addWKWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: GankConfig.getScreenHeight()-64), configuration: webConfiguration)
        
        webView.allowsBackForwardNavigationGestures = true
        
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        
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
}
