//
//  ArticleViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/26.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class ArticleViewController: BaseViewController {
    
    public var category: String!
    fileprivate var gankArray = [Gank]()
    fileprivate var page: Int = 1
    fileprivate var canLoadMore: Bool = false
    fileprivate var isLoading: Bool = false
    fileprivate var isNoData: Bool = false
    
    @IBOutlet weak var articleTableView: UITableView! {
        didSet {
            articleTableView.tableFooterView = UIView()
            articleTableView.refreshControl = refreshControl
            
            articleTableView.registerNibOf(DailyGankCell.self)
            articleTableView.registerNibOf(ArticleGankLoadingCell.self)
            articleTableView.registerNibOf(LoadMoreCell.self)
        }
    }
    
    fileprivate var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl.init()
        refreshControl.layer.zPosition = -1
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    fileprivate lazy var noDataFooterView: NoDataFooterView = {
        let noDataFooterView = NoDataFooterView.instanceFromNib()
        noDataFooterView.reasonAction = { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let networkViewController = storyboard.instantiateViewController(withIdentifier: "NetworkViewController")
            self?.navigationController?.pushViewController(networkViewController , animated: true)
        }
        noDataFooterView.reloadAction = { [weak self] in
            self?.refreshControl.beginRefreshing()
            self?.articleTableView.contentOffset = CGPoint(x:0, y: 0-(self?.refreshControl.frame.size.height)!)
            self?.refresh((self?.refreshControl)!)
        }
        noDataFooterView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: GankConfig.getScreenHeight()-64)
        return noDataFooterView
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
        
        updateArticleView()
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
    
    fileprivate enum UpdateArticleViewMode {
        case first
        case top
        case loadMore
    }
    
    fileprivate func updateArticleView(mode: UpdateArticleViewMode = .first, finish: (() -> Void)? = nil) {
        if isLoading {
            finish?()
            return
        }
        
        isNoData = false
        isLoading = true
        var maxPage = page
        
        switch mode {
        case .first:
            canLoadMore = true
            maxPage = 1
            articleTableView.isScrollEnabled = false
            articleTableView.separatorStyle = .none
            articleTableView.rowHeight = 94
            //noDataFooterView.removeFromSuperview()
        case .top:
            maxPage = 1
            canLoadMore = true
            articleTableView.estimatedRowHeight = 195.5
            articleTableView.rowHeight = UITableViewAutomaticDimension
        case .loadMore:
            maxPage += 1
        }
        
        let failureHandler: FailureHandler = { reason, message in
            
            SafeDispatch.async { [weak self] in
                
                switch mode {
                case .first:
                    //self?.view.addSubview((self?.noDataFooterView)!)
                    self?.isNoData = true
                    self?.articleTableView.isScrollEnabled = true
                    self?.articleTableView.tableFooterView = self?.noDataFooterView
                    self?.articleTableView.reloadData()
                    gankLog.debug("加载失败")
                case .top, .loadMore:
                    GankHUD.error("加载失败")
                    gankLog.debug("加载失败")
                }
                
                self?.isLoading = false
                
                finish?()
            }
        }
        
        gankofCategory(category: category, page: maxPage, failureHandler: failureHandler, completion: { (data) in
            SafeDispatch.async { [weak self] in
                
                self?.isNoData = false
                self?.articleTableView.isScrollEnabled = true
                self?.articleTableView.tableFooterView = UIView()
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.canLoadMore = (data.count == 20)
                strongSelf.page = maxPage
                
                let newGankArray = data
                let oldGankArray = strongSelf.gankArray
                
                var wayToUpdate: UITableView.WayToUpdate = .none
                
                switch mode {
                case .first:
                    strongSelf.gankArray = newGankArray
                    wayToUpdate = .reloadData
                    
                case .top:
                    strongSelf.gankArray = newGankArray
                    
                    if Set(oldGankArray.map({ $0.id })) == Set(newGankArray.map({ $0.id })) {
                        wayToUpdate = .none
                    } else {
                        wayToUpdate = .reloadData
                    }
                    
                case .loadMore:
                    let oldGankArratCount = oldGankArray.count
                    let oldGankArrayIdSet = Set<String>(oldGankArray.map({ $0.id }))
                    var realNewGankArray = [Gank]()
                    for gank in newGankArray {
                        if !oldGankArrayIdSet.contains(gank.id) {
                            realNewGankArray.append(gank)
                        }
                    }
                    
                    strongSelf.gankArray += realNewGankArray
                    
                    let newGankArrayCount = strongSelf.gankArray.count
                    
                    let indexPaths = Array(oldGankArratCount..<newGankArrayCount).map({ IndexPath(row: $0, section: 0) })
                    if !indexPaths.isEmpty {
                        wayToUpdate = .reloadData
                    }
                    
                    if !strongSelf.canLoadMore {
                        strongSelf.articleTableView.tableFooterView = strongSelf.customFooterView
                    }
                }
                
                wayToUpdate.performWithTableView(strongSelf.articleTableView)
                strongSelf.isLoading = false
                
                finish?()
            }
        })
        
    }

}

extension ArticleViewController {
    
    @objc fileprivate func refresh(_ sender: UIRefreshControl) {
        
        if isNoData {
            updateArticleView() {
                SafeDispatch.async {
                    sender.endRefreshing()
                }
            }
        } else {
            updateArticleView(mode: .top) {
                SafeDispatch.async {
                    sender.endRefreshing()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ArticleViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate enum Section: Int {
        case gank
        case loadMore
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard isNoData else {
            return gankArray.isEmpty || !canLoadMore ? 1 : 2
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard !isNoData else {
            return 0
        }
        
        guard !gankArray.isEmpty else {
            return 8
        }
        
        guard let section = Section(rawValue: section) else {
            fatalError("Invalid Section")
        }
        
        switch section {
            
        case .gank:
            return gankArray.count
            
        case .loadMore:
            return canLoadMore ? 1 : 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard gankArray.isEmpty else {
            
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Invalid Section")
            }
            
            switch section {
                
            case .gank:
                let cell: DailyGankCell = tableView.dequeueReusableCell()
                let gankDetail: Gank = gankArray[indexPath.row]
                if category == "all" {
                    cell.configure(withGankDetail: gankDetail, isHiddenTag: false)
                } else {
                    cell.configure(withGankDetail: gankDetail)
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.default
                
                return cell
                
            case .loadMore:
                let cell: LoadMoreCell = tableView.dequeueReusableCell()
                cell.isLoading = true
                return cell
            }
        }
        
        let cell: ArticleGankLoadingCell = tableView.dequeueReusableCell()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid Section")
        }
        
        switch section {
            
        case .gank:
            break
            
        case .loadMore:
            guard let cell = cell as? LoadMoreCell else {
                break
            }
            
            guard canLoadMore else {
                cell.isLoading = false
                break
            }
            
            print("load more gank")
            
            if !cell.isLoading {
                cell.isLoading = true
            }
            
            updateArticleView(mode: .loadMore, finish: { [weak cell] in
                cell?.isLoading = false
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if !gankArray.isEmpty {
        
            let gankDetail: Gank = gankArray[indexPath.row]
            self.performSegue(withIdentifier: "showDetail", sender: gankDetail.url)
        }
    }
}
