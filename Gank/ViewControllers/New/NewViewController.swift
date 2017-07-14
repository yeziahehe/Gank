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
import UserNotifications

final class NewViewController: BaseViewController {
    
    @IBOutlet var dailyGankButton: UIBarButtonItem!
    @IBOutlet var calendarButton: UIBarButtonItem!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var newTableView: UITableView! {
        didSet {
            newTableView.isScrollEnabled = false
            newTableView.tableHeaderView = coverHeaderView
            newTableView.tableFooterView = UIView()
            newTableView.separatorStyle = .none
            newTableView.rowHeight = 158
            
            newTableView.registerNibOf(DailyGankCell.self)
            newTableView.registerNibOf(DailyGankLoadingCell.self)
        }
    }
    
    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityView.hidesWhenStopped = true
        return activityView
    }()
    
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
    fileprivate var meiziGank: Gank?
    fileprivate var gankCategories: [String] = []
    fileprivate var gankDictionary: [String: Array<Gank>] = [:]
    
    deinit {
        newTableView?.delegate = nil
        gankLog.debug("deinit NewViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRightBarButtonItems(type: .only)
        
        gankLatest(falureHandler: nil, completion: { (isToday, meizi, categories, lastestGank) in
            SafeDispatch.async { [weak self] in
                self?.configureData(isToday, meizi, categories, lastestGank)
                self?.makeUI()
            }
        })
        
    }
    
    @IBAction func closeTip(_ sender: UIButton) {
        tipView.isHidden = true
    }
    
    @IBAction func getNewGank(_ sender: UIBarButtonItem) {
        
        GankConfig.heavyFeedbackEffectAction?()
        activityIndicatorView.startAnimating()
        setRightBarButtonItems(type: .indicator)
        
        gankLatest(falureHandler: nil, completion: { (isToday, meizi, categories, lastestGank) in
            SafeDispatch.async { [weak self] in
                
                self?.activityIndicatorView.stopAnimating()
                
                guard isToday else {
                    self?.makeAlert()
                    return
                }
                
                self?.configureData(isToday, meizi, categories, lastestGank)
                self?.makeUI()
            }
        })
        
    }
    
    @IBAction func showCalendar(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showCalendar", sender: self)
    }
    
}

extension NewViewController {
    
    enum RightBarType {
        case all
        case only
        case indicator
    }
    
    fileprivate func configureData(_ isToday: Bool, _ meizi: Gank, _ categories: Array<String>, _ lastestGank: Dictionary<String, Array<Gank>>) {
        isGankToday = isToday
        meiziGank = meizi
        gankCategories = categories
        gankDictionary = lastestGank
    }
    
    fileprivate func setRightBarButtonItems(type: RightBarType) {
        switch type {
        case .only:
            navigationItem.setRightBarButtonItems([calendarButton], animated: false)
        case .indicator:
            navigationItem.setRightBarButtonItems([calendarButton, UIBarButtonItem(customView: activityIndicatorView)], animated: false)
        default:
            navigationItem.setRightBarButtonItems([calendarButton, dailyGankButton], animated: false)
        }
    }
    
    fileprivate func makeUI() {
        newTableView.isScrollEnabled = true
        newTableView.tableFooterView = customFooterView
        newTableView.estimatedRowHeight = 195.5
        newTableView.rowHeight = UITableViewAutomaticDimension
        let height = coverHeaderView.configure(meiziData: meiziGank!)
        coverHeaderView.frame.size = CGSize(width: GankConfig.getScreenWidth(), height: height)
        newTableView.reloadData()
        tipView.isHidden = isGankToday
        
        if isGankToday {
            setRightBarButtonItems(type: .only)
            return
        }
        setRightBarButtonItems(type: .all)
    }
    
    fileprivate func makeAlert() {
        setRightBarButtonItems(type: .all)
        
        guard GankNotificationService.shared.isAskAuthorization == true else {
            GankAlert.confirmOrCancel(title: nil, message: String.messageOpenNotification, confirmTitle: String.promptConfirmOpenNotification, cancelTitle: String.promptCancelOpenNotification, inViewController: self, withConfirmAction: {
                GankNotificationService.shared.checkAuthorization()
            }, cancelAction: {})
            return
        }
        
        GankAlert.alertKnown(title: nil, message: String.messageNoDailyGank, inViewController: self)
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
