//
//  NotificationViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/8/4.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationViewController: BaseViewController {

    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationTextView.setLineHeight(lineHeight: 1.5)
        notificationSwitch.isOn = GankUserDefaults.isBackgroundEnable.value!
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        if sender.isOn {
            checkAuthorization()
        }
        sender.isOn ? GankBackgroundFetchService.shared.turnOn() : GankBackgroundFetchService.shared.turnOff()
    }
    
    private func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            SafeDispatch.async { [weak self] in
                switch settings.authorizationStatus {
                case .notDetermined:
                    GankNotificationService.shared.authorize()
                case .authorized:
                    gankLog.debug("UserNotifications authorized")
                case .denied:
                    GankAlert.confirmOrCancel(title: nil, message: String.messageSetNotification, confirmTitle: String.promptConfirmSetNotification, cancelTitle: String.promptCancelOpenNotification, inViewController: self, withConfirmAction: {
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }, cancelAction: {})
                }
            }
        })
    }
}
