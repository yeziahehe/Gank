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
    var gankArray = [Gank]()
    var page: Int = 1
    
    @IBOutlet weak var articleTableView: UITableView! {
        didSet {
            articleTableView.isScrollEnabled = false
            articleTableView.tableFooterView = UIView()
            articleTableView.separatorStyle = .none
            articleTableView.rowHeight = 94
            articleTableView.refreshControl = refreshControl
            
            articleTableView.registerNibOf(DailyGankCell.self)
            articleTableView.registerNibOf(ArticleGankLoadingCell.self)
        }
    }
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl.init()
        refreshControl.layer.zPosition = -1
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    fileprivate lazy var customFooterView: CustomFooterView = {
        let footerView = CustomFooterView.instanceFromNib()
        footerView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: 73)
        return footerView
    }()
    
    deinit {
        articleTableView?.delegate = nil
        gankLog.debug("deinit ArticleViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = category
        
        gankofCategory(category: category, page: page, failureHandler: nil) { (data) in
            SafeDispatch.async { [weak self] in
                self?.gankArray = data
                self?.makeUI()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "showDetail":
            let vc = segue.destination as! GankDetailViewController
            let url = sender as! String
            vc.gankURL = url
            
        default:
            break
        }
    }

}

extension ArticleViewController {
    fileprivate func makeUI() {
        articleTableView.isScrollEnabled = true
        articleTableView.estimatedRowHeight = 195.5
        articleTableView.rowHeight = UITableViewAutomaticDimension
        articleTableView.reloadData()
    }
    
    @objc fileprivate func refresh(_ sender: UIRefreshControl) {
        gankofCategory(category: category, page: 1, failureHandler: nil) { (data) in
            SafeDispatch.async { [weak self] in
                self?.articleTableView.refreshControl?.endRefreshing()
                self?.gankArray = data
                self?.makeUI()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ArticleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gankArray.isEmpty && page == 1 ? 8 : gankArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard gankArray.isEmpty && page == 1 else {
            let cell: DailyGankCell = tableView.dequeueReusableCell()
            let gankDetail: Gank = gankArray[indexPath.row]
            if category == "all" {
                cell.configure(withGankDetail: gankDetail, isHiddenTag: false)
            } else {
                cell.configure(withGankDetail: gankDetail)
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            
            return cell
        }
        
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
        
        let gankDetail: Gank = gankArray[indexPath.row]
        self.performSegue(withIdentifier: "showDetail", sender: gankDetail.url)
    }
}
