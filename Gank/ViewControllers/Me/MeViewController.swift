//
//  MeViewController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import YFMoreViewController
import MonkeyKing

final class MeViewController: BaseViewController {
    
    @IBOutlet weak var meTableView: UITableView! {
        didSet {
            meTableView.tableFooterView = versionFooterView
            
            meTableView.registerNibOf(UserInfoCell.self)
            meTableView.registerNibOf(SettingCell.self)
            meTableView.registerNibOf(LogoutCell.self)
        }
    }
    
    fileprivate lazy var versionFooterView: VersionFooterView = {
        let footerView = VersionFooterView.instanceFromNib()
        footerView.frame = CGRect(x: 0, y: 0, width: GankConfig.getScreenWidth(), height: 44)
        return footerView
    }()
    
    struct Annotation {
        let name: String
        let segue: String
        let url: String?
    }
    
    fileprivate let settingAnnotations: [Annotation] = [
        Annotation(
            name: String.promptNotification,
            segue: "showNotification",
            url: nil
        ),
        Annotation(
            name: String.promptThanks,
            segue: "showDetail",
            url: "http://gank.io/backbone"
        ),
    ]
    
    fileprivate let aboutAnnotations: [Annotation] = [
        Annotation(
            name: String.promptAbout,
            segue: "showAbout",
            url: nil
        ),
        Annotation(
            name: String.promptVersion,
            segue: "showVersion",
            url: nil
        ),
    ]
    
    fileprivate let recommAnnotations: [Annotation] = [
        Annotation(
            name: String.promptRecommend,
            segue: "",
            url: nil
        ),
        Annotation(
            name: String.promptScore,
            segue: "",
            url: nil
        ),
    ]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        meTableView?.delegate = nil
        gankLog.debug("deinit MeViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MeViewController.reloadMeTableView(_:)), name: GankConfig.NotificationName.login, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MeViewController.reloadMeTableView(_:)), name: GankConfig.NotificationName.logout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MeViewController.reloadMeTableView(_:)), name: GankConfig.NotificationName.watchNew, object: nil)
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
    
    @IBAction func showAddGank(_ sender: UIBarButtonItem) {
        if GankUserDefaults.isLogined {
            performSegue(withIdentifier: "showAddGank", sender: nil)
        } else {
            performSegue(withIdentifier: "showLogin", sender: nil)
        }
    }
    
    @objc fileprivate func reloadMeTableView(_ notification: Notification) {
        meTableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MeViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate enum Section: Int {
        case userInfo
        case setting
        case about
        case recomm
        case logout
        
        static let count = 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return GankUserDefaults.isLogined ? Section.count : Section.count - 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError("Invalide section!")
        }
        
        switch section {
        case .userInfo:
            return 1
        case .setting:
            return settingAnnotations.count
        case .about:
            return aboutAnnotations.count
        case .recomm:
            return recommAnnotations.count
        case .logout:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalide section!")
        }
        
        switch section {
        case .userInfo:
            let cell: UserInfoCell = tableView.dequeueReusableCell()
            cell.configure()
            return cell
        case .setting:
            let cell: SettingCell = tableView.dequeueReusableCell()
            let annotation = settingAnnotations[indexPath.row]
            cell.annotationLabel.text = annotation.name
            return cell
        case .about:
            let cell: SettingCell = tableView.dequeueReusableCell()
            let annotation = aboutAnnotations[indexPath.row]
            cell.annotationLabel.text = annotation.name
            if indexPath.row == 1 {
                if let isVersionNew = GankUserDefaults.isVersionNewHidden.value {
                    cell.newTag.isHidden = isVersionNew
                } else {
                    GankUserDefaults.isVersionNewHidden.value = false
                    cell.newTag.isHidden = false
                }
            }
            return cell
        case .recomm:
            let cell: SettingCell = tableView.dequeueReusableCell()
            let annotation = recommAnnotations[indexPath.row]
            cell.annotationLabel.text = annotation.name
            return cell
        case .logout:
            let cell: LogoutCell = tableView.dequeueReusableCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalide section!")
        }
        
        switch section {
            
        case .userInfo:
            return 100
        case .setting, .about, .recomm:
            return 50
        case .logout:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalide section!")
        }
        
        switch section {
        case .userInfo:
            if !GankUserDefaults.isLogined {
                performSegue(withIdentifier: "showLogin", sender: nil)
            }
        case .setting:
            let annotation = settingAnnotations[indexPath.row]
            performSegue(withIdentifier: annotation.segue, sender: annotation.url)
        case .about:
            let annotation = aboutAnnotations[indexPath.row]
            performSegue(withIdentifier: annotation.segue, sender: nil)
        case .recomm:
            if indexPath.row == 0 {
                let moreViewController = YFMoreViewController.init()
                moreViewController.delegate = self
                moreViewController.addInfo(String.promptRecommend)
                if MonkeyKing.SupportedPlatform.weChat.isAppInstalled {
                    moreViewController.addItems(title: "微信", image: #imageLiteral(resourceName: "wechat"), type: .important, tag: "wechat")
                    moreViewController.addItems(title: "朋友圈", image: #imageLiteral(resourceName: "moments"), type: .important, tag: "moments")
                }
                if MonkeyKing.SupportedPlatform.weibo.isAppInstalled {
                    moreViewController.addItems(title: "微博", image: #imageLiteral(resourceName: "weibo"), type: .important, tag: "weibo")
                }
                if MonkeyKing.SupportedPlatform.qq.isAppInstalled {
                    moreViewController.addItems(title: "QQ", image: #imageLiteral(resourceName: "QQ"), type: .important, tag: "QQ")
                    moreViewController.addItems(title: "QQ空间", image: #imageLiteral(resourceName: "QQZone"), type: .important, tag: "QQZone")
                }
                moreViewController.showFromBottom()
            } else if indexPath.row == 1 {
                UIApplication.shared.reviewOnTheAppStore()
            }
            break
        case .logout:
            GankAlert.confirmOrCancel(title: String.titleLogout, message: String.messageLogout, confirmTitle: String.promptConfirmLogout, cancelTitle: String.promptCancelLogout, inViewController: self, withConfirmAction: {
                GankUserDefaults.cleanLoginUserDefaults()
                NotificationCenter.default.post(name: GankConfig.NotificationName.logout, object: nil)
            }, cancelAction: {})
            break
        }
    }
}

extension MeViewController: YFMoreViewDelegate {
    
    func moreView(_ moreview: YFMoreViewController, didSelectItemAt tag: String, type: YFMoreItemType) {
        let gankURL = URL(string: "https://itunes.apple.com/cn/app/id1164948361?mt=8")!
        let info = MonkeyKing.Info(
            title: "干货集中营 - Gank",
            description: String.promptRecommend,
            thumbnail: UIImage.gank_logo,
            media: .url(gankURL)
        )
        switch tag {
        case "wechat":
            MonkeyKing.deliver(.weChat(.session(info: info))) { result in
                //TODO
                print("result: \(result)")
            }
            return
        case "moments":
            MonkeyKing.deliver(.weChat(.timeline(info: info))) { result in
                print("result: \(result)")
            }
            return
        case "weibo":
            MonkeyKing.deliver(.weibo(.default(info: info, accessToken: nil))) { result in
                print("result: \(result)")
            }
            return
        case "QQ":
            MonkeyKing.deliver(.qq(.friends(info: info))) { result in
                print("result: \(result)")
            }
            return
        case "QQZone":
            MonkeyKing.deliver(.qq(.zone(info: info))) { result in
                print("result: \(result)")
            }
            return
        default:
            return
        }
    }
    
}
