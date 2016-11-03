//
//  GankLogger.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/1.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import Foundation
import XCGLogger

let gankLog: XCGLogger = {
    
    let gankLog = XCGLogger(identifier: "gank", includeDefaultDestinations: false)

    // Create a console log destination
    let consoleDestination = ConsoleDestination(identifier: "gank.consoleDestination")
    consoleDestination.haveLoggedAppDetails = true
    
    // Create a file log destination
    let logPath: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("gank.log")
    let fileDestination = FileDestination(writeToFile: logPath, identifier: "gank.fileDestination")
    fileDestination.haveLoggedAppDetails = true
    fileDestination.logQueue = XCGLogger.logQueue
    
    gankLog.add(destination: consoleDestination)
    gankLog.add(destination: fileDestination)
    
    return gankLog
}()




