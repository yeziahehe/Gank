//
//  AboutViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/4.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var aboutTableView: UITableView! {
        didSet {
            aboutTableView.registerNibOf(SettingCell.self)
        }
    }
    
    struct Annotation {
        let name: String
        let url: String
    }
    
    fileprivate let aboutAnnotations: [Annotation] = [
        Annotation(
            name: String.promptAboutAuthor,
            url: "http://yeziahehe.com/about/"
        ),
        Annotation(
            name: String.promptAuthorGitHub,
            url: "https://github.com/yeziahehe"
        ),
        Annotation(
            name: String.promptGank,
            url: "http://gank.io/"
        ),
        Annotation(
            name: String.promptPods,
            url: ""
        ),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.text = String(format:"v%@ (%@)", Bundle.releaseVersionNumber!, Bundle.buildVersionNumber!)
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

extension AboutViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate enum Row: Int {
        case author
        case github
        case gank
        case pods
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aboutAnnotations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SettingCell = tableView.dequeueReusableCell()
        let annotation = aboutAnnotations[indexPath.row]
        cell.annotationLabel.text = annotation.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let row = Row(rawValue: indexPath.row) else {
            fatalError("Invalide section!")
        }
        
        switch row {
            
        case .author, .github, .gank:
            performSegue(withIdentifier: "showDetail", sender: aboutAnnotations[indexPath.row].url)
        case .pods:
            performSegue(withIdentifier: "showPods", sender: nil)
        }
        
    }
    
}
