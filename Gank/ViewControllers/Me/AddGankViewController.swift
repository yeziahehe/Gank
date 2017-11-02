//
//  AddGankViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/5.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import IQDropDownTextField

class AddGankViewController: BaseViewController {
    @IBOutlet weak var step0Content: UITextView!
    @IBOutlet weak var step1Content: UILabel!
    @IBOutlet weak var categoryTextField: IQDropDownTextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    deinit {
        categoryTextField.resignFirstResponder()
        urlTextField.resignFirstResponder()
        descTextField.resignFirstResponder()
        gankLog.debug("deinit AddGankViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        step0Content.setLineHeight(lineHeight: 1.5)
        step1Content.setLineHeight(lineHeight: 1.5)
        
        categoryTextField.isOptionalDropDown = false
        categoryTextField.itemList = ["Android", "iOS", "前端", "瞎推荐", "休息视频", "拓展资源", "福利", "App"]
        categoryTextField.addTarget(self, action: #selector(AddGankViewController.textChange(_:)), for: .editingChanged)
        urlTextField.addTarget(self, action: #selector(AddGankViewController.textChange(_:)), for: .editingChanged)
        descTextField.addTarget(self, action: #selector(AddGankViewController.textChange(_:)), for: .editingChanged)
    }
    
    @IBAction func submitClicked(_ sender: UIButton) {
        submitButton.isUserInteractionEnabled = false
        addToGank(url: urlTextField.text!, desc: descTextField.text!, who: GankUserDefaults.name.value!, type: categoryTextField.selectedItem!, failureHandler: { (reason, error) in
            
            SafeDispatch.async { [weak self] in
                self?.submitButton.isUserInteractionEnabled = true
                gankLog.debug(error)
                
                guard let error = error else {
                    GankAlert.alertKnown(title: nil, message: String.titleSubmitError, inViewController: self)
                    return
                }
                GankAlert.alertKnown(title: String.titleSubmitError, message: error, inViewController: self)
            }
            
        }, completion: {
            
            SafeDispatch.async { [weak self] in
                self?.submitButton.isUserInteractionEnabled = true
                GankAlert.alertKnown(title: nil, message: String.messageSubmitSuccess, inViewController: self)
                self?.categoryTextField.setSelectedRow(0, animated: false)
                self?.urlTextField.text = ""
                self?.descTextField.text = ""
                self?.textChange((self?.urlTextField)!)
            }
        })
    }
    
}

extension AddGankViewController: UITextFieldDelegate {
    
    @objc func textChange(_ textField: UITextField) {
        if categoryTextField.selectedItem != nil && !urlTextField.text!.isEmpty && !descTextField.text!.isEmpty {
            submitButton.isEnabled = true
            submitButton.backgroundColor = UIColor.gankTintColor()
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = UIColor.gankFooterColor()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == urlTextField {
            descTextField.becomeFirstResponder()
        } else if textField == descTextField {
            descTextField.resignFirstResponder()
        }
        return true
    }
}
