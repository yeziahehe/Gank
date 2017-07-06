//
//  NewViewController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import Kingfisher
import FaceAware

final class NewViewController: BaseViewController {
    
    @IBOutlet weak var dailyGankButton: UIBarButtonItem!         
    @IBOutlet weak var calendarButton: UIBarButtonItem!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var newTableView: UITableView! {
        didSet {
            newTableView.tableHeaderView = coverHeaderView
            newTableView.tableFooterView = UIView()
            newTableView.separatorStyle = .none
            newTableView.rowHeight = 158
            
            newTableView.registerNibOf(DailyGankCell.self)
            newTableView.registerNibOf(DailyGankLoadingCell.self)
        }
    }
    
    fileprivate lazy var coverHeaderView: CoverHeaderView = {
        let headerView = CoverHeaderView.instanceFromNib()
        headerView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: 235)
        return headerView
    }()
    
    fileprivate lazy var customFooterView: CustomFooterView = {
        let footerView = CustomFooterView.instanceFromNib()
        footerView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: 73)
        return footerView
    }()
    
    fileprivate var isGankToday: Bool = true
    fileprivate var meiziImageUrl: Gank?
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
        
        navigationItem.setRightBarButtonItems([calendarButton], animated: false)
                
        gankLatest(falureHandler: nil, completion: { (isToday, meizi, categories, lastestGank) in
            SafeDispatch.async { [weak self] in
                // config data
                self?.isGankToday = isToday
                self?.meiziImageUrl = meizi
                self?.gankCategories = categories
                self?.gankDictionary = lastestGank
                // config UI
                self?.configureUI()
            }
        })
        
        #if DEBUG
            view.addSubview(newFPSLabel)
        #endif
        
    }
    
    @IBAction func closeTip(_ sender: UIButton) {
        tipView.isHidden = true
    }
    
    @IBAction func getNewGank(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func showCalendar(_ sender: UIBarButtonItem) {
    }
    
}

extension NewViewController {
    
    fileprivate func configureUI() {
        newTableView.tableFooterView = customFooterView
        newTableView.estimatedRowHeight = 195.5
        newTableView.rowHeight = UITableViewAutomaticDimension
        let height = coverHeaderView.configure(meiziData: meiziImageUrl!)
        coverHeaderView.frame.size = CGSize(width: GankConfig.getScreenWidth(), height: height)
        newTableView.reloadData()
        tipView.isHidden = isGankToday
        
        if isGankToday {
            navigationItem.setRightBarButtonItems([calendarButton], animated: false)
            return
        }
        navigationItem.setRightBarButtonItems([dailyGankButton, calendarButton], animated: false)
    }
    
    fileprivate func refreshUI() {
        
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
        guard gankCategories.isEmpty else {
            return 56
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard gankCategories.isEmpty else {
            let headerView = GankHeaderView.instanceFromNib()
            headerView.configure(titleString: gankCategories[section])
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard gankCategories.isEmpty else {
            let cell: DailyGankCell = tableView.dequeueReusableCell()
            let key: String = gankCategories[indexPath.section]
            let gankDetail: Gank = gankDictionary[key]![indexPath.row]
            cell.configure(withGankDetail: gankDetail)
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            
            return cell
        }
        
        let cell: DailyGankLoadingCell = tableView.dequeueReusableCell()
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
