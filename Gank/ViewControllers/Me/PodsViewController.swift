//
//  PodsViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/4.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class PodsViewController: BaseViewController {

    @IBOutlet weak var podsTableView: UITableView!
    
    struct Pod {
        let name: String
        let url: String
    }
    
    fileprivate let pods: [Pod] = [
        Pod(
            name: "Alamofire",
            url: "https://github.com/Alamofire/Alamofire"
        ),
        Pod(
            name: "AlamofireNetworkActivityIndicator",
            url: "https://github.com/Alamofire/AlamofireNetworkActivityIndicator"
        ),
        Pod(
            name: "IQDropDownTextField",
            url: "https://github.com/hackiftekhar/IQDropDownTextField"
        ),
        Pod(
            name: "IQKeyboardManager",
            url: "https://github.com/hackiftekhar/IQKeyboardManager"
        ),
        Pod(
            name: "JJHUD",
            url: "https://github.com/Jinxiansen/JJHUD"
        ),
        Pod(
            name: "JTAppleCalendar",
            url: "https://github.com/patchthecode/JTAppleCalendar"
        ),
        Pod(
            name: "Kingfisher",
            url: "https://github.com/onevcat/Kingfisher"
        ),
        Pod(
            name: "MonkeyKing",
            url: "https://github.com/nixzhu/MonkeyKing"
        ),
        Pod(
            name: "Proposer",
            url: "https://github.com/nixzhu/Proposer"
        ),
        Pod(
            name: "Reachability.swift",
            url: "https://github.com/ashleymills/Reachability.swift"
        ),
        Pod(
            name: "SKPhotoBrowser",
            url: "https://github.com/suzuki-0000/SKPhotoBrowser"
        ),
        Pod(
            name: "SwiftyJSON",
            url: "https://github.com/SwiftyJSON/SwiftyJSON"
        ),
        Pod(
            name: "XCGLogger",
            url: "https://github.com/DaveWoodCom/XCGLogger"
        ),
        Pod(
            name: "YFMoreViewController",
            url: "https://github.com/yeziahehe/YFMoreViewController"
        ),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension PodsViewController: UITableViewDelegate, UITableViewDataSource {
    enum Section: Int {
        case gank
        case pods
        
        var headerTitle: String {
            switch self {
            case .gank:
                return "干货集中营 - Gank"
            case .pods:
                return "第三方"
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .gank:
            return 1
        case .pods:
            return pods.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        return section.headerTitle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .gank:
            return 65
        case .pods:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .gank:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GankCell", for: indexPath)
            cell.textLabel?.text = "Gank 的 GitHub 仓库"
            cell.detailTextLabel?.text = "欢迎 Star！"
            return cell
            
        case .pods:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PodCell", for: indexPath)
            let pod = pods[indexPath.row]
            cell.textLabel?.text = pod.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .gank:
            performSegue(withIdentifier: "showDetail", sender: "https://github.com/yeziahehe/Gank")
            
        case .pods:
            performSegue(withIdentifier: "showDetail", sender: pods[indexPath.row].url)
        }
    }
}
