//
//  String+Named.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/8.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit

extension String {
    
    static func titleDailyGankAuthor(_ author: String) -> String{
        return String(format:"via. %@", author)
    }
    
}

extension String {
    
    static var titleDailyGankAuthorBot: String {
        return "via. 机器人"
    }
    
    static var titleKnown: String {
        return "知道了"
    }
    
    static var titleToday: String {
        return "干货更新啦"
    }
    
    static var messageNoDailyGank: String {
        return "今日干货未更新，有新干货会第一时间推送给你~"
    }
    
    static var messageTodayGank: String {
        return "今天的干货很棒，欢迎戳来看预览~ "
    }
    
    static var titleContentTitle: String {
        return "干货更新啦"
    }
    
    static var messageOpenNotification: String {
        return "今日干货未更新，你可以打开推送，这样新干货会第一时间推送给你~"
    }
    
    static var promptConfirmOpenNotification: String {
        return "打开推送"
    }
    
    static var promptCancelOpenNotification: String {
        return "暂时不用"
    }
    
    static var titleSearch: String {
        return "搜索真的好了！不骗你！"
    }
    
    static var titleSorry: String {
        return "无法保存"
    }
    
    static var promptConfirmOpenCameraRoll: String {
        return "现在就改"
    }
    
    static var promptCancelOpenCameraRoll: String {
        return "暂时不用"
    }
    
    static var promptNotification: String {
        return "干货推送"
    }
    
    static var promptThanks: String {
        return "感谢编辑们"
    }
    
    static var promptAbout: String {
        return "关于"
    }
    
    static var promptVersion: String {
        return "版本更新"
    }
    
    static var promptRecommend: String {
        return "推荐给朋友"
    }
    
    static var promptScore: String {
        return "给干货集中营评分"
    }
    
    static var promptStar: String {
        return "给项目 Star"
    }
    
    static var messageSetNotification: String {
        return "【通知】权限为关闭状态，打开后才能正常获取干货推送~"
    }
    
    static var promptConfirmSetNotification: String {
        return "前往设置"
    }
    
    static var promptAboutAuthor: String {
        return "关于作者"
    }
    
    static var promptAuthorGitHub: String {
        return "作者 GitHub"
    }
    
    static var promptGank: String {
        return "致谢干货集中营及代码家"
    }
    
    static var promptPods: String {
        return "开源组件"
    }
    
    static var titleSubmitError: String {
        return "提交干货失败"
    }
    
    static var messageSubmitSuccess: String {
        return "棒呆! 成功了!"
    }
}
