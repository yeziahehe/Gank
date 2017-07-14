//
//  NotificationHandler.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/11.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import UserNotifications

final class GankNotificationService: NSObject {
    
    static let shared = GankNotificationService()
    var isAskAuthorization: Bool?
    
    fileprivate override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        initAuthorization()
    }
    
    fileprivate func initAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            SafeDispatch.async { [weak self] in
                switch settings.authorizationStatus {
                case .notDetermined:
                    self?.isAskAuthorization = false
                case .authorized:
                    self?.isAskAuthorization = true
                case .denied:
                    self?.isAskAuthorization = true
                }
            }
        })
    }
    
    public func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            SafeDispatch.async { [weak self] in
                switch settings.authorizationStatus {
                case .notDetermined:
                    self?.authorize()
                case .authorized:
                    gankLog.debug("UserNotifications authorized")
                case .denied:
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                }
            }
        })
    }
    
    public func authorize() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            SafeDispatch.async { [weak self] in
                self?.initAuthorization()
                if granted {
                    gankLog.debug("UserNotifications authorized")
                    GankBackgroundFetchService.shared.turnOn()
                } else {
                    gankLog.debug("UserNotifications denied")
                }
            }
        }
    }
        
    public func push() {
        let content = UNMutableNotificationContent()
        content.title = String.titleContentTitle
        content.body = String.messageTodayGank
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let requestIdentifier = "gank update"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension GankNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let options: UNNotificationPresentationOptions = [.alert, .sound]
        completionHandler(options)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // TODO
        completionHandler()
    }
}


