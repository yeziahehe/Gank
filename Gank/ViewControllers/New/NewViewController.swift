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
    
    fileprivate var isNoData = false
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
    
    fileprivate lazy var noDataFooterView: NoDataFooterView = {
        let noDataFooterView = NoDataFooterView.instanceFromNib()
        noDataFooterView.reasonAction = { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let networkViewController = storyboard.instantiateViewController(withIdentifier: "NetworkViewController")
            self?.navigationController?.pushViewController(networkViewController , animated: true)
        }
        noDataFooterView.reloadAction = { [weak self] in
            self?.updateNewView()
        }
        
        noDataFooterView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: GankConfig.getScreenHeight()-64)
        return noDataFooterView
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
        NotificationCenter.default.removeObserver(self)
        newTableView?.delegate = nil
        gankLog.debug("deinit NewViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateNewView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewViewController.refreshUIWithNotification(_:)), name: GankConfig.NotificationName.chooseGank, object: nil)
        
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
    
    @IBAction func closeTip(_ sender: UIButton) {
        tipView.isHidden = true
    }
    
    @IBAction func getNewGank(_ sender: UIBarButtonItem) {
        updateNewView(mode: .today)
        
    }
    
    @IBAction func showCalendar(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showCalendar", sender: nil)
    }
    
    @objc fileprivate func refreshUIWithNotification(_ notification: Notification) {
        guard let date = notification.object as? String else {
            return
        }
        
        updateNewView(mode: .date, isChoose: true, date: date)
    }
    
}

extension NewViewController {
    
    fileprivate enum RightBarType {
        case all
        case only
        case indicator
        case none
    }
    
    fileprivate func setRightBarButtonItems(type: RightBarType) {
        switch type {
        case .only:
            navigationItem.setRightBarButtonItems([calendarButton], animated: false)
        case .indicator:
            navigationItem.setRightBarButtonItems([calendarButton, UIBarButtonItem(customView: activityIndicatorView)], animated: false)
        case .all:
            navigationItem.setRightBarButtonItems([calendarButton, dailyGankButton], animated: false)
        case .none:
            navigationItem.setRightBarButtonItems(nil, animated: false)
        }
    }
    
    fileprivate enum UpdateNewViewMode {
        case lastest
        case today
        case date
    }
    
    fileprivate func updateNewView(mode: UpdateNewViewMode = .lastest, isChoose: Bool = false, date: String = "") {
        
        isNoData = false
        
        switch mode {
        case .lastest:
            setRightBarButtonItems(type: .none)
            gankLog.debug("UpdateNewViewMode lastest")
        case .date:
            isGankToday = false
            meiziGank = nil
            gankCategories = []
            gankDictionary = [:]
            
            newTableView.isScrollEnabled = false
            newTableView.separatorColor = .none
            newTableView.tableFooterView = UIView()
            newTableView.rowHeight = 158
            newTableView.reloadData()
            coverHeaderView.refresh()
            tipView.isHidden = true
            setRightBarButtonItems(type: .only)
            gankLog.debug("UpdateNewViewMode date")
        case .today:
            GankConfig.heavyFeedbackEffectAction?()
            activityIndicatorView.startAnimating()
            setRightBarButtonItems(type: .indicator)
            gankLog.debug("UpdateNewViewMode today")
        }
        
        let failureHandler: FailureHandler = { reason, message in
            
            SafeDispatch.async { [weak self] in
                
                self?.isNoData = true
                self?.newTableView.tableHeaderView = UIView()
                self?.newTableView.isScrollEnabled = false
                self?.newTableView.tableFooterView = self?.noDataFooterView
                self?.newTableView.reloadData()
                gankLog.debug("加载失败")
                
            }
        }
        
        switch mode {
        case .lastest:
            gankLatest(failureHandler: failureHandler, completion: { (isToday, meizi, categories, lastestGank) in
                SafeDispatch.async { [weak self] in
                    
                    self?.configureData(isToday, meizi, categories, lastestGank)
                    self?.makeUI()
                }
            })
        case .today:
            gankLatest(failureHandler: failureHandler, completion: { (isToday, meizi, categories, lastestGank) in
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
        case .date:
            gankWithDay(date: date, failureHandler: failureHandler, completion: { (isToday, meizi, categories, lastestGank) in
                SafeDispatch.async { [weak self] in
                    self?.configureData(isToday, meizi, categories, lastestGank)
                    self?.makeUI(isChoose:true)
                }
            })
        }
        
    }
    
    
    fileprivate func configureData(_ isToday: Bool, _ meizi: Gank, _ categories: Array<String>, _ lastestGank: Dictionary<String, Array<Gank>>) {
        isGankToday = isToday
        meiziGank = meizi
        gankCategories = categories
        gankDictionary = lastestGank
    }
    
    fileprivate func makeUI(isChoose: Bool = false) {
        newTableView.isScrollEnabled = true
        newTableView.tableHeaderView = coverHeaderView
        newTableView.tableFooterView = customFooterView
        newTableView.estimatedRowHeight = 195.5
        newTableView.rowHeight = UITableViewAutomaticDimension
        let height = coverHeaderView.configure(meiziData: meiziGank)
        coverHeaderView.frame.size = CGSize(width: GankConfig.getScreenWidth(), height: height)
        newTableView.reloadData()
        if isChoose == false {
            tipView.isHidden = isGankToday
        }
        
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
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension NewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard !isNoData else {
            return 0
        }
        
        return gankCategories.isEmpty ? 1 : gankCategories.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard !isNoData else {
            return 0
        }
        
        guard !gankCategories.isEmpty else {
            return 2
        }
        
        let key: String = gankCategories[section]
        return gankDictionary[key]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard gankCategories.isEmpty || isNoData else {
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
        
        
        if !gankCategories.isEmpty {
            let key: String = gankCategories[indexPath.section]
            let gankDetail: Gank = gankDictionary[key]![indexPath.row]
            self.performSegue(withIdentifier: "showDetail", sender: gankDetail.url)
        }
    }
}
