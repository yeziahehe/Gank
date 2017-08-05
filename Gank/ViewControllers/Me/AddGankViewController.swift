//
//  AddGankViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/5.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class AddGankViewController: BaseViewController {
    @IBOutlet weak var step0Content: UITextView!
    @IBOutlet weak var step1Content: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        step0Content.setLineHeight(lineHeight: 1.5)
        step1Content.setLineHeight(lineHeight: 1.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
