//
//  ArticleViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/26.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class ArticleViewController: BaseViewController {
    
    var category: String!
    @IBOutlet weak var articleTableView: UITableView! {
        didSet {
            articleTableView.isScrollEnabled = false
            articleTableView.tableFooterView = UIView()
            articleTableView.separatorStyle = .none
            articleTableView.rowHeight = 94
            
            articleTableView.registerNibOf(DailyGankCell.self)
            articleTableView.registerNibOf(ArticleGankLoadingCell.self)
        }
    }
    
    fileprivate lazy var customFooterView: CustomFooterView = {
        let footerView = CustomFooterView.instanceFromNib()
        footerView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: 73)
        return footerView
    }()
    
    deinit {
        articleTableView?.delegate = nil
        gankLog.debug("deinit ArticleViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = category
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegat

extension ArticleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ArticleGankLoadingCell = tableView.dequeueReusableCell()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
