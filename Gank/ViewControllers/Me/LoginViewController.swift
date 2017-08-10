//
//  LoginViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/9.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    deinit {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        GankHUD.dismiss()
        gankLog.debug("deinit LoginViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.dismissVC(_:)), name: GankConfig.NotificationName.push, object: nil)
        usernameTextField.addTarget(self, action: #selector(LoginViewController.textChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.textChange(_:)), for: .editingChanged)
    }
    
    @objc fileprivate func dismissVC(_ notification: Notification) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func closeLoginAction(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        loginButton.isUserInteractionEnabled = false
        GankHUD.show()
        
        loginWithGitHub(username: usernameTextField.text!, password: passwordTextField.text!, failureHandler: { (reason, error) in
            SafeDispatch.async { [weak self] in
                gankLog.debug(error)
                GankHUD.dismiss()
                self?.loginButton.isUserInteractionEnabled = true
                
                guard let error = error else {
                    GankAlert.alertKnown(title: nil, message: String.titleLoginError, inViewController: self)
                    return
                }
                GankAlert.alertKnown(title: String.titleLoginError, message: error, inViewController: self)
                
            }
        }, completion: { loginUser in
            SafeDispatch.async { [weak self] in
                GankHUD.dismiss()
                self?.loginButton.isUserInteractionEnabled = true
                saveUserInfoOfLoginUser(loginUser)
                NotificationCenter.default.post(name: GankConfig.NotificationName.login, object: nil)
                self?.dismiss(animated: true, completion: nil)
            }
        })
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textChange(_ textField: UITextField) {
        if !usernameTextField.text!.isEmpty && !passwordTextField.text!.isEmpty {
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
        } else {
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
