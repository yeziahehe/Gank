![YFMoreViewController](YFMoreViewController.png)

# YFMoreViewController

<p>
<a href="http://cocoadocs.org/docsets/YFMoreViewController"><img src="https://img.shields.io/cocoapods/v/YFMoreViewController.svg?style=flat"></a>
<a href="https://github.com/yeziahehe/YFMoreViewController/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
<a href="http://swift.org"><img src="https://img.shields.io/badge/language-swift%204.0-orange.svg"></a>
<a href="https://developer.apple.com/xcode/"><img src="https://img.shields.io/badge/xcode-8.0-46aae6.svg"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS%209+-lightgray.svg"></a>
</p>

Easy More Operation ViewController in swift.

[中文文档](https://github.com/yeziahehe/YFMoreViewController/blob/master/README_CN.md)

# Introduction

More Operation like share and refresh, inspiration comes from Wechat More Operation. You can use YFMoreViewController just to share something, or to oprate webview.

# Requirements

- iOS 9.0 and later
- Xcode 9.x and later
- Swift 4.x and later(For Swift 3.x, use version 1.0.2)

# Installation

## CocoaPods

- Simply add this line to your `Podfile`:
```
pod 'YFMoreViewController'
```
- Run `pod install`.
- Include with `import YFMoreViewController` to use it wherever you need.

## Manually

- Add sources floder's files `YFMoreItemView`、`YFMoreViewDelegate`、`YFMoreViewController` to your project (3 files total).
- Include with `import YFMoreViewController` to use it wherever you need.

# Usage

## Preparation

![Note](Note.png)

YFMoreViewController consists of three parts: info, item important and item normal. They can all be empty, it will just show cancel button.

- info: if you use YFMoreViewController in WebView, here you can show "Powered By website"

- item important: here always show share platform, just like Wechat etc. If you just use item important, YFMoreViewController may replace your share ViewController

- item normal: here always show normal operation, you can use with WebView or some other you need

## Basic Usage

You just init YFMoreViewController, then add items and show, it will OK.
```
let moreViewController = YFMoreViewController.init()
moreViewController.delegate = self

moreViewController.addInfo("Powered By yeziahehe.com")
moreViewController.addItems(title: "Wechat", image: UIImage(named: "wechat"), type: .important, tag: "wechat")
moreViewController.addItems(title: "Open With Safari", image: UIImage(named: "safari"), type: .normal, tag:"safari")

moreViewController.showFromBottom()
```

Then you need implement protocol.
```
func moreView(_ moreview: YFMoreViewController, didSelectItemAt tag: String, type: YFMoreItemType) {
  switch tag {
  case "wechat":
      return
  case "safari":
      UIApplication.shared.open(URL(string: "http://yeziahehe.com")!, options: [:], completionHandler: nil)
      print("safari")
      return
  }
}
```

# About

- [Blog](http://yeziahehe.com/)
- Gmail: yeziahehe@gmail.com

# License

YFMoreViewController is available under the MIT license. See the [LICENSE file](https://github.com/yeziahehe/YFMoreViewController/blob/master/LICENSE) for more info.
