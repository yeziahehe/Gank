//
//  SearchViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/29.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController {
    
    fileprivate var searchArray: [Gank] = [Gank]()
    fileprivate var page: Int = 1
    fileprivate var canLoadMore: Bool = false
    fileprivate var isLoading: Bool = false
    fileprivate var isNoData: Bool = false
    
    @IBOutlet weak var searchTableView: UITableView! {
        didSet {
            searchTableView.tableHeaderView = searchController.searchBar
            searchTableView.tableFooterView = searchFooterView
            searchTableView.separatorStyle = .none
            searchTableView.estimatedRowHeight = 195.5
            searchTableView.rowHeight = UITableViewAutomaticDimension
            
            searchTableView.registerNibOf(DailyGankCell.self)
            searchTableView.registerNibOf(LoadMoreCell.self)
        }
    }
    
    fileprivate lazy var searchFooterView: SearchFooterView = {
        let footerView = SearchFooterView.instanceFromNib()
        footerView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: 200)
        return footerView
    }()
    
    fileprivate lazy var customFooterView: CustomFooterView = {
        let footerView = CustomFooterView.instanceFromNib()
        footerView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: 73)
        return footerView
    }()
    
    fileprivate var searchController: UISearchController! = {
        let searchController = UISearchController.init(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "搜索真的好了！不骗你！"
        searchController.searchBar.tintColor = UIColor.gankTintColor()
        searchController.searchBar.barTintColor = UIColor.gankLoadingColor()
        searchController.searchBar.backgroundColor = UIColor.white
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = UIColor.gankLoadingColor().cgColor
        searchController.searchBar.sizeToFit()
        return searchController
    }()
    
    deinit {
        searchTableView?.delegate = nil
        searchController?.isActive = false
        searchController?.searchResultsUpdater = nil
        searchController?.delegate = nil
        searchController?.searchBar.delegate = nil
        gankLog.debug("deinit ArticleViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
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
    
    fileprivate enum UpdateSearchViewMode {
        case first
        case loadMore
    }
    
    fileprivate func updateSearchView(_ query: String, mode: UpdateSearchViewMode = .first, finish: (() -> Void)? = nil) {
        
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
            
        case .loadMore:
            maxPage += 1
        }
        
        let failureHandler: FailureHandler = { reason, message in
            
            SafeDispatch.async { [weak self] in
                
                switch mode {
                case .first:
                    self?.isNoData = true
                    self?.searchTableView.tableFooterView = self?.searchFooterView
                    self?.searchTableView.reloadData()
                    gankLog.debug("加载失败")
                case .loadMore:
                    GankHUD.error("加载失败")
                    gankLog.debug("加载失败")
                }
                
                self?.isLoading = false
                
                finish?()
                
            }
        }
        
        gankSearch(query: query, page: maxPage, failureHandler: failureHandler, completion: { (data) in
            SafeDispatch.async { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                if data.count == 0, mode == .first {
                    self?.isNoData = true
                    self?.searchTableView.tableFooterView = self?.searchFooterView
                    self?.searchTableView.reloadData()
                    self?.isLoading = false
                    gankLog.debug("无结果")
                    finish?()
                    
                    return
                }
                
                self?.isNoData = false
                self?.searchTableView.tableFooterView = UIView()
                
                strongSelf.canLoadMore = (data.count == 10)
                strongSelf.page = maxPage
                
                let newGankArray = data
                let oldGankArray = strongSelf.searchArray
                
                var wayToUpdate: UITableView.WayToUpdate = .none
                
                switch mode {
                case .first:
                    strongSelf.searchArray = newGankArray
                    wayToUpdate = .reloadData
                    
                case .loadMore:
                    let oldGankArratCount = oldGankArray.count
                    let oldGankArrayIdSet = Set<String>(oldGankArray.map({ $0.id }))
                    var realNewGankArray = [Gank]()
                    for gank in newGankArray {
                        if !oldGankArrayIdSet.contains(gank.id) {
                            realNewGankArray.append(gank)
                        }
                    }
                    
                    strongSelf.searchArray += realNewGankArray
                    
                    let newGankArrayCount = strongSelf.searchArray.count
                    
                    let indexPaths = Array(oldGankArratCount..<newGankArrayCount).map({ IndexPath(row: $0, section: 0) })
                    if !indexPaths.isEmpty {
                        wayToUpdate = .reloadData
                    }
                    
                    if !strongSelf.canLoadMore {
                        strongSelf.searchTableView.tableFooterView = strongSelf.customFooterView
                    }
                }
                
                wayToUpdate.performWithTableView(strongSelf.searchTableView)
                strongSelf.isLoading = false
                
                finish?()
                
            }
        })
            
            
   }
}

extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.searchBar.text!.characters.count > 0 {
            updateSearchView(searchController.searchBar.text!)
        } else {
            searchArray = [Gank]()
            searchTableView.tableFooterView = searchFooterView
            searchTableView.reloadData()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate enum Section: Int {
        case gank
        case loadMore
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard isNoData else {
            return searchArray.isEmpty || !canLoadMore ? 1 : 2
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard !isNoData else {
            return 0
        }
        
        guard !searchArray.isEmpty else {
            return 0
        }
        
        guard let section = Section(rawValue: section) else {
            fatalError("Invalid Section")
        }
        
        switch section {
            
        case .gank:
            return searchArray.count
            
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
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid Section")
        }
        
        switch section {
            
        case .gank:
            let cell: DailyGankCell = tableView.dequeueReusableCell()
            let gankDetail: Gank = searchArray[indexPath.row]
            cell.configure(withGankDetail: gankDetail, isHiddenTag: false)
            
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            
            return cell
            
        case .loadMore:
            let cell: LoadMoreCell = tableView.dequeueReusableCell()
            cell.isLoading = true
            return cell
        }
        
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
            
            updateSearchView(searchController.searchBar.text!, mode: .loadMore, finish: { [weak cell] in
                cell?.isLoading = false
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let gankDetail: Gank = searchArray[indexPath.row]
        self.performSegue(withIdentifier: "showDetail", sender: gankDetail.url)
    }
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}
