//
//  GankSoundEffect.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/9.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import AudioToolbox.AudioServices

final public class GankSoundEffect: NSObject {
    
    var soundID: SystemSoundID?
    
    public init(fileURL: URL) {
        super.init()
        
        var theSoundID: SystemSoundID = 0
        let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &theSoundID)
        if (error == kAudioServicesNoError) {
            soundID = theSoundID
        } else {
            fatalError("YepSoundEffect: init failed!")
        }
    }
    
    deinit {
        if let soundID = soundID {
            AudioServicesDisposeSystemSoundID(soundID)
        }
    }
    
    public func play() {
        if let soundID = soundID {
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
