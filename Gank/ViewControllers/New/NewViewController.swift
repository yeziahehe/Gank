//
//  NewViewController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import Kingfisher

final class NewViewController: BaseViewController {
    
    @IBOutlet weak var newTableView: UITableView! {
        didSet {
            newTableView.registerNibOf(DailyGankCell.self)
            newTableView.registerNibOf(DailyGankLoadingCell.self)
        }
    }
    
    @IBOutlet weak var meiziImageView: UIImageView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var meiziImageViewConstraint: NSLayoutConstraint!
    
    fileprivate lazy var newFooterView: GankFooter = GankFooter()
    fileprivate var isGankToday: Bool = false
    fileprivate var meiziUrl: String = ""
    fileprivate var gankCategories: [String] = []
    fileprivate var gankDictionary: [String: Array<Gank>] = [:]
    
    #if DEBUG
    private lazy var newFPSLabel: FPSLabel = {
        let label = FPSLabel()
        return label
    }()
    #endif
    
    deinit {
        newTableView?.delegate = nil
        gankLog.debug("deinit NewViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newTableView.tableFooterView = UIView()
        newTableView.separatorStyle = .none
        newTableView.rowHeight = 158
        
        gankLastest(falureHandler: nil, completion: { (isToday, meizi, categories, lastestGank) in
            self.isGankToday = isToday
            self.meiziUrl = meizi
            self.gankCategories = categories
            self.gankDictionary = lastestGank
            self.newTableView.estimatedRowHeight = 195.5
            self.newTableView.rowHeight = UITableViewAutomaticDimension
            self.configUI()
        })
        
        #if DEBUG
            view.addSubview(newFPSLabel)
        #endif
        
    }
    
    fileprivate func configUI() {
        meiziImageView.kf.setImage(with: URL(string: meiziUrl)) {
            (image, error, cacheType, imageURL) in
            SafeDispatch.async { [weak self] in
                if let image = image {
                    self?.meiziImageViewConstraint.constant = GankConfig.getScreenWidth()/image.size.width * image.size.height
                }
            }
            self.newTableView.reloadData()
            self.newTableView.setNeedsLayout()
            self.newTableView.layoutIfNeeded()
            self.newTableView.reloadData()
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegat

extension NewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return gankCategories.isEmpty ? 1 : gankCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard gankCategories.isEmpty else {
            let key: String = gankCategories[section]
            return gankDictionary[key]!.count
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard gankCategories.isEmpty else {
            let cell: DailyGankCell = tableView.dequeueReusableCell()
            let key: String = gankCategories[indexPath.section]
            let gankDetail: Gank = gankDictionary[key]![indexPath.row]
            
            cell.timeLabel.text = gankDetail.publishedAt
            cell.authorLabel.text = gankDetail.who
            cell.titleLabel.text = gankDetail.desc
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            newTableView.frame.size.height = newTableView.contentSize.height
            contentScrollView.contentSize = CGSize(width: GankConfig.getScreenWidth(), height:meiziImageView.frame.size.height + newTableView.contentSize.height)
            return cell
        }
        
        let cell: DailyGankLoadingCell = tableView.dequeueReusableCell()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        newTableView.frame.size.height = newTableView.contentSize.height
        contentScrollView.contentSize = CGSize(width: GankConfig.getScreenWidth(), height:meiziImageView.frame.size.height + newTableView.contentSize.height)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
