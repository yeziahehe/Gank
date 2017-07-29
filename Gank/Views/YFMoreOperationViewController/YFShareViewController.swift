//
//  YFShareViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/20.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import Foundation

public enum YFShareItemType {
    case important  // 将item放在第一行显示
    case normal     // 将item放在第二行显示
}

public class YFShareViewController: UIViewController {
    
    var importantItems: [YFShareItemView] = []
    var normalItems: [YFShareItemView] = []
    weak var delegate: YFShareViewDelegate?
    
    var previousKeyWindow: UIWindow?
    var containerWindow: UIWindow?
    
    fileprivate var maskView: UIControl = {
        let maskView = UIControl.init()
        maskView.alpha = 0
        maskView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.35)
        maskView.addTarget(self, action: #selector(handleMaskControlEvent), for: .touchUpInside)
        return maskView
    }()
    
    fileprivate var infoView: UILabel = {
        let infoView = UILabel.init()
        infoView.isHidden = true
        infoView.textColor = UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)
        infoView.backgroundColor = UIColor.clear
        infoView.font = UIFont.systemFont(ofSize: 12)
        infoView.textAlignment = .center
        return infoView
    }()
    
    fileprivate var contentView: UIView = {
        let contentView = UIView.init()
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor(colorLiteralRed: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return contentView
    }()
    
    fileprivate var containerView: UIView = {
        let containerView = UIView.init()
        containerView.clipsToBounds = true
        return containerView
    }()
    
    fileprivate var importantItemsScrollView: UIScrollView = {
        let importantItemsScrollView = UIScrollView.init()
        importantItemsScrollView.showsVerticalScrollIndicator = false
        importantItemsScrollView.showsHorizontalScrollIndicator = false
        return importantItemsScrollView
    }()
    
    fileprivate var normalItemsScrollView: UIScrollView = {
        let normalItemsScrollView = UIScrollView.init()
        normalItemsScrollView.showsVerticalScrollIndicator = false
        normalItemsScrollView.showsHorizontalScrollIndicator = false
        normalItemsScrollView.isHidden = true
        return normalItemsScrollView
    }()
    
    fileprivate var scrollViewDividingLayer: CALayer = {
        let scrollViewDividingLayer = CALayer.init()
        scrollViewDividingLayer.isHidden = true
        scrollViewDividingLayer.backgroundColor = UIColor(colorLiteralRed: 229/255, green: 229/255, blue: 229/255, alpha: 1).cgColor
        return scrollViewDividingLayer
    }()
    
    fileprivate var cancelButton: UIButton = {
        let cancelButton = UIButton.init()
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.backgroundColor = UIColor.white
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor(colorLiteralRed: 34/255, green: 34/255, blue: 34/255, alpha: 1), for: .normal)
        cancelButton.setTitleColor(UIColor(colorLiteralRed: 34/255, green: 34/255, blue: 34/255, alpha: 0.5), for: .highlighted)
        cancelButton.addTarget(self, action: #selector(handleCancelButtonEvent), for: .touchUpInside)
        return cancelButton
    }()
    
    fileprivate var cancelButtonDividingLayer: CALayer = {
        let cancelButtonDividingLayer = CALayer.init()
        cancelButtonDividingLayer.backgroundColor = UIColor.clear.cgColor
        return cancelButtonDividingLayer
    }()
    
    deinit {
        print("deinit YFShareViewController")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(maskView)
        view.addSubview(containerView)
        containerView.addSubview(contentView)
        contentView.layer.addSublayer(scrollViewDividingLayer)
        contentView.addSubview(infoView)
        contentView.addSubview(importantItemsScrollView)
        contentView.addSubview(normalItemsScrollView)
        containerView.addSubview(cancelButton)
        containerView.layer.addSublayer(cancelButtonDividingLayer)
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        maskView.frame = view.bounds
        
        var layoutOriginY: CGFloat = 0
        let contentWidth: CGFloat = view.frame.width
        
        if infoView.isHidden == false {
            infoView.frame = CGRect(x: 0, y: layoutOriginY, width: contentWidth, height: 30)
            layoutOriginY = infoView.frame.maxY
        }
        
        let itemWidth: CGFloat = 72
        let scrollViewInsets: UIEdgeInsets = UIEdgeInsetsMake(10, 9, 12, 9)
        var itemMaxHeight: CGFloat = 0
        var itemMaxX: CGFloat = 0
        
        if importantItems.count > 0 {
            importantItemsScrollView.isHidden = false
            for itemView in importantItems {
                itemView.sizeToFit()
                itemView.frame = CGRect(x: itemWidth * CGFloat(importantItems.index(of: itemView)!), y: 0, width: itemWidth, height: itemView.bounds.height)
                itemMaxX = itemView.frame.maxX
                if itemView.bounds.height > itemMaxHeight {
                    itemMaxHeight = itemView.bounds.height
                }
            }
            importantItemsScrollView.contentSize = CGSize(width: itemMaxX, height: itemMaxHeight)
            importantItemsScrollView.contentInset = scrollViewInsets
            importantItemsScrollView.contentOffset = CGPoint(x: -importantItemsScrollView.contentInset.left, y: -importantItemsScrollView.contentInset.top)
            importantItemsScrollView.frame = CGRect(x: 0, y: layoutOriginY, width: contentWidth, height: importantItemsScrollView.contentInset.top + importantItemsScrollView.contentSize.height + importantItemsScrollView.contentInset.bottom)
            layoutOriginY = importantItemsScrollView.frame.maxY
        } else {
            importantItemsScrollView.isHidden = true
        }
        
        itemMaxHeight = 0
        itemMaxX = 0
        
        if normalItems.count > 0 {
            normalItemsScrollView.isHidden = false
            scrollViewDividingLayer.isHidden = importantItems.isEmpty
            scrollViewDividingLayer.frame = CGRect(x: 15, y: layoutOriginY, width: contentWidth, height: 1/UIScreen.main.scale)
            layoutOriginY = scrollViewDividingLayer.frame.maxY
            for itemView in normalItems {
                itemView.sizeToFit()
                itemView.frame = CGRect(x: itemWidth * CGFloat(normalItems.index(of: itemView)!), y: 0, width: itemWidth, height: itemView.bounds.height)
                itemMaxX = itemView.frame.maxX
                if itemView.bounds.height > itemMaxHeight {
                    itemMaxHeight = itemView.bounds.height
                }
            }
            normalItemsScrollView.contentSize = CGSize(width: itemMaxX, height: itemMaxHeight)
            normalItemsScrollView.contentInset = scrollViewInsets
            normalItemsScrollView.contentOffset = CGPoint(x: -normalItemsScrollView.contentInset.left, y: -normalItemsScrollView.contentInset.top)
            normalItemsScrollView.frame = CGRect(x: 0, y: layoutOriginY, width: contentWidth, height: normalItemsScrollView.contentInset.top + normalItemsScrollView.contentSize.height + normalItemsScrollView.contentInset.bottom)
            layoutOriginY = normalItemsScrollView.frame.maxY
        } else {
            normalItemsScrollView.isHidden = true
            scrollViewDividingLayer.isHidden = true
        }
        
        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: layoutOriginY)
        cancelButtonDividingLayer.frame = CGRect(x: 0, y: layoutOriginY, width: contentWidth, height: 1/UIScreen.main.scale)
        cancelButton.frame = CGRect(x: 0, y: cancelButtonDividingLayer.frame.minY, width: contentWidth, height: 50)
        containerView.frame = CGRect(x: (view.bounds.width - contentWidth)/2, y: view.bounds.height - cancelButton.frame.maxY, width: contentWidth, height: cancelButton.frame.maxY)
    }
}

extension YFShareViewController {
    
    @objc fileprivate func handleMaskControlEvent() {
        hideToButtom()
    }
    
    @objc fileprivate func handleCancelButtonEvent() {
        hideToButtom()
    }
    
    @objc fileprivate func handleButtonClickEvent(_ sender: Any) {
        let item: YFShareItemView = sender as! YFShareItemView
        if item.superview == importantItemsScrollView {
            delegate?.shareview(self, didSelectItemAt: importantItems.index(of: item)!, type: .important)
            delegate?.shareView(self, didSelectItemAt: item.itemTag, type: .important)
        } else if item.superview == normalItemsScrollView {
            delegate?.shareview(self, didSelectItemAt: normalItems.index(of: item)!, type: .normal)
            delegate?.shareView(self, didSelectItemAt: item.itemTag, type: .normal)
        }
        hideToButtom()
    }
    
    public func showFromBottom() {
        
        previousKeyWindow = UIApplication.shared.keyWindow
        containerWindow = UIWindow.init()
        containerWindow?.backgroundColor = UIColor.clear
        containerWindow?.rootViewController = self
        containerWindow?.makeKeyAndVisible()
        
        containerView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height - contentView.frame.minY)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.maskView.alpha = 1
            self.containerView.frame.origin.y = self.view.bounds.height - self.containerView.frame.height
            self.containerView.transform = CGAffineTransform.identity
        })
    }
    
    public func hideToButtom() {
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
            self.maskView.alpha = 0
            self.containerView.frame.origin.y = self.view.bounds.height
        }) { (complete) in
            if complete {
                if UIApplication.shared.keyWindow == self.containerWindow {
                    self.previousKeyWindow?.makeKey()
                }
                self.containerWindow?.isHidden = true
                self.containerWindow?.rootViewController = nil
                self.previousKeyWindow = nil
            }
        }
        
    }
    
    public func addInfo(_ info: String) {
        infoView.isHidden = false
        infoView.text = info
    }
    
    public func addItems(title: String, selectedTitle: String, image: UIImage, selectedImage: UIImage, type: YFShareItemType, tag: String) {
        let itemView: YFShareItemView = createItem(title: title, selectedTitle: selectedTitle, image: image, selectedImage: selectedImage, type: type, tag: tag)
        if itemView.itemType == .important {
            insertItem(itemView, at: importantItems.count)
        } else if itemView.itemType == .normal {
            insertItem(itemView, at: normalItems.count)
        }
    }
    
    public func addItems(title: String, image: UIImage, type: YFShareItemType, tag: String) {
        addItems(title: title, selectedTitle: title, image: image, selectedImage: image, type: type, tag: tag)
    }
    
    fileprivate func createItem(title: String, selectedTitle: String, image: UIImage, selectedImage: UIImage, type: YFShareItemType, tag: String) -> YFShareItemView {
        let itemView: YFShareItemView = YFShareItemView.init()
        itemView.itemType = type
        itemView.itemTag = tag
        itemView.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        itemView.titleEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        itemView.setImage(image, for: .normal)
        itemView.setImage(selectedImage, for: .selected)
        itemView.setTitle(title, for: .normal)
        itemView.setTitle(selectedTitle, for: .selected)
        itemView.setTitleColor(UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1), for: .normal)
        itemView.imageView?.backgroundColor = UIColor.clear
        itemView.addTarget(self, action: #selector(handleButtonClickEvent(_:)), for: .touchUpInside)
        return itemView
    }
    
    fileprivate func insertItem(_ itemView: YFShareItemView, at index: Int) {
        if itemView.itemType == .important {
            importantItems.insert(itemView, at: index)
            importantItemsScrollView.addSubview(itemView)
        } else if itemView.itemType == .normal {
            normalItems.insert(itemView, at: index)
            normalItemsScrollView.addSubview(itemView)
        }
    }
    
    public func itemAtTag(_ tag: String) -> YFShareItemView{
        var itemView = viewWithTag(importantItems, tag: tag)
        
        guard itemView != nil else {
            itemView = viewWithTag(normalItems, tag: tag)
            return itemView!
        }
        
        return itemView!
    }
    
    private func viewWithTag(_ array: [YFShareItemView], tag: String) -> YFShareItemView? {
        for item in array {
            if item.itemTag == tag {
                return item
            }
        }
        return nil
    }
}

