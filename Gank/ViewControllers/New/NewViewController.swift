//
//  NewViewController.swift
//  Gank
//
//  Created by 叶帆 on 2016/10/27.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

final class NewViewController: BaseViewController {
    
    @IBOutlet weak var newTableView: UITableView! {
        didSet {
            newTableView.registerNibOf(DailyGankCell.self)
            newTableView.registerNibOf(DailyGankLoadingCell.self)
            
            newTableView.rowHeight = 158
            newTableView.tableFooterView = UIView()
            newTableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var meiziImageView: UIImageView!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    fileprivate lazy var newFooterView: GankFooter = GankFooter()
    
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

        #if DEBUG
            view.addSubview(newFPSLabel)
        #endif
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegat

extension NewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DailyGankLoadingCell = tableView.dequeueReusableCell()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        contentScrollView.contentSize = CGSize(width: 375, height:(meiziImageView.image?.size.height)! + newTableView.contentSize.height)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
