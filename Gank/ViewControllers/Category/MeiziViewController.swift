//
//  MeiziViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/26.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class MeiziViewController: BaseViewController {
    
    fileprivate var meiziArray = [Gank]()
    fileprivate var page: Int = 1
    fileprivate var canLoadMore: Bool = false
    fileprivate var isLoading: Bool = false
    fileprivate var isNoData: Bool = false

    @IBOutlet weak var meiziCollectionView: UICollectionView! {
        didSet {
            meiziCollectionView.refreshControl = refreshControl
            
            meiziCollectionView.registerNibOf(MeiziCollectionCell.self)
            meiziCollectionView.registerNibOf(MeiziLoadingCollectionCell.self)
            meiziCollectionView.registerNibOf(LoadMoreCollectionCell.self)
            meiziCollectionView.registerHeaderClassOf(UICollectionReusableView.self)
            meiziCollectionView.registerFooterClassOf(UICollectionReusableView.self)
            meiziCollectionView.registerFooterNibOf(CustomFooterCollectionView.self)
            meiziCollectionView.registerFooterNibOf(NoDataFooterCollectionView.self)
        }
    }
    
    fileprivate var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl.init()
        refreshControl.layer.zPosition = -1
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    deinit {
        meiziCollectionView?.delegate = nil
        gankLog.debug("deinit MeiziViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateMeiziView()
    }
    
    fileprivate enum UpdateMeiziViewMode {
        case first
        case top
        case loadMore
    }
    
    fileprivate func updateMeiziView(mode: UpdateMeiziViewMode = .first, finish: (() -> Void)? = nil) {
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
            meiziCollectionView.isScrollEnabled = false
        case .top:
            maxPage = 1
            canLoadMore = true
            meiziCollectionView.isScrollEnabled = true
        case .loadMore:
            maxPage += 1
        }
        
        let failureHandler: FailureHandler = { reason, message in
            
            SafeDispatch.async { [weak self] in
                
                switch mode {
                case .first:
                    self?.isNoData = true
                    self?.meiziCollectionView.isScrollEnabled = true
                    self?.meiziCollectionView.reloadData()
                    gankLog.debug("加载失败")
                case .top, .loadMore:
                    //TODO 加载失败
                    gankLog.debug("加载失败")
                }
                
                self?.isLoading = false
                
                finish?()
            }
        }
        
        gankofCategory(category: "福利", page: maxPage, failureHandler: failureHandler, completion: { (data) in
            SafeDispatch.async { [weak self] in
                
                self?.isNoData = false
                self?.meiziCollectionView.isScrollEnabled = true
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.canLoadMore = (data.count == 20)
                strongSelf.page = maxPage
                
                let newGankArray = data
                let oldGankArray = strongSelf.meiziArray
                
                var wayToUpdate: UICollectionView.WayToUpdate = .none
                
                switch mode {
                case .first:
                    strongSelf.meiziArray = newGankArray
                    wayToUpdate = .reloadData
                    
                case .top:
                    strongSelf.meiziArray = newGankArray
                    
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
                    
                    strongSelf.meiziArray += realNewGankArray
                    
                    let newGankArrayCount = strongSelf.meiziArray.count
                    
                    let indexPaths = Array(oldGankArratCount..<newGankArrayCount).map({ IndexPath(row: $0, section: 0) })
                    if !indexPaths.isEmpty {
                        wayToUpdate = .reloadData
                    }
                    
                }
                
                wayToUpdate.performWithCollectionView(strongSelf.meiziCollectionView)
                strongSelf.isLoading = false
                
                finish?()
            }
        })
    }
    
}

extension MeiziViewController {
    @objc fileprivate func refresh(_ sender: UIRefreshControl) {
        
        if isNoData {
            updateMeiziView() {
                SafeDispatch.async {
                    sender.endRefreshing()
                }
            }
        } else {
            updateMeiziView(mode: .top) {
                SafeDispatch.async {
                    sender.endRefreshing()
                }
            }
        }
    }
}

extension MeiziViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate enum Section: Int {
        case meizi
        case loadMore
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard isNoData else {
            return meiziArray.isEmpty || !canLoadMore ? 1 : 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard !isNoData else {
            return 0
        }
        
        guard !meiziArray.isEmpty else {
            return 8
        }
        
        guard let section = Section(rawValue: section) else {
            fatalError("Invalid Section")
        }
        
        switch section {
            
        case .meizi:
            return meiziArray.count
            
        case .loadMore:
            return canLoadMore ? 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard meiziArray.isEmpty else {
            
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Invalid Section")
            }
            
            switch section {
                
            case .meizi:
                let cell: MeiziCollectionCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                let gankDetail: Gank = meiziArray[indexPath.row]
                cell.configure(withGankDetail: gankDetail)
                
                return cell
                
            case .loadMore:
                let cell: LoadMoreCollectionCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                cell.isLoading = true
                return cell
            }
        }
        
        let cell: MeiziLoadingCollectionCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .meizi:
            break
            
        case .loadMore:
            guard let cell = cell as? LoadMoreCollectionCell else {
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
            
            updateMeiziView(mode: .loadMore, finish: { [weak cell] in
                cell?.isLoading = false
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if !meiziArray.isEmpty {
            
            let gankDetail: Gank = meiziArray[indexPath.row]
            self.performSegue(withIdentifier: "showDetail", sender: gankDetail.url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionFooter {
            if isNoData {
                let noDataFooterView: NoDataFooterCollectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, forIndexPath: indexPath)
                noDataFooterView.reasonAction = { [weak self] in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let networkViewController = storyboard.instantiateViewController(withIdentifier: "NetworkViewController")
                    self?.navigationController?.pushViewController(networkViewController , animated: true)
                }
                noDataFooterView.reloadAction = { [weak self] in
                    self?.refreshControl.beginRefreshing()
                    self?.meiziCollectionView.contentOffset = CGPoint(x:0, y: 0-(self?.refreshControl.frame.size.height)!)
                    self?.refresh((self?.refreshControl)!)
                }
                
                return noDataFooterView
            }
            
            if !canLoadMore {
                let customFooterView: CustomFooterCollectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, forIndexPath: indexPath)

                return customFooterView
            }
            
            let footer: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, forIndexPath: indexPath)
            return footer
        } else {
            let header: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, forIndexPath: indexPath)
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if isNoData {
            return CGSize(width: GankConfig.getScreenWidth(), height: GankConfig.getScreenHeight()-64)
        }
        
        if !canLoadMore {
            return CGSize(width: GankConfig.getScreenWidth(), height: 73)
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard meiziArray.isEmpty else {
        
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError()
            }
            
            switch section {
                
            case .meizi:
                return CGSize(width: (GankConfig.getScreenWidth() - (15 + 15 + 15)) * 0.5, height: 211)
                
            case .loadMore:
                return CGSize(width: GankConfig.getScreenWidth(), height: 44)
            }
            
        }
        
        return CGSize(width: (GankConfig.getScreenWidth() - (15 + 15 + 15)) * 0.5, height: 211)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard meiziArray.isEmpty else {
        
            guard let section = Section(rawValue: section) else {
                fatalError()
            }
            
            switch section {
                
            case .meizi:
                return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
                
            case .loadMore:
                return UIEdgeInsets.zero
            }
        }
        
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
}
