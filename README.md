# CMPushNotificationService

[![CI Status](http://img.shields.io/travis/comma/CMPushNotificationService.svg?style=flat)](https://travis-ci.org/comma/CMPushNotificationService)
[![Version](https://img.shields.io/cocoapods/v/CMPushNotificationService.svg?style=flat)](http://cocoapods.org/pods/CMPushNotificationService)
[![License](https://img.shields.io/cocoapods/l/CMPushNotificationService.svg?style=flat)](http://cocoapods.org/pods/CMPushNotificationService)
[![Platform](https://img.shields.io/cocoapods/p/CMPushNotificationService.svg?style=flat)](http://cocoapods.org/pods/CMPushNotificationService)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CMPushNotificationService is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CMPushNotificationService'
```

## License

CMPushNotificationService is available under the MIT license. See the LICENSE file for more info.

## 使用方法

* 创建一个NSOjbect类，遵循CMPushNotificationHandler协议 (例：CMPushManager，下面均使用这个类)

* 在didFinishLaunchingWithOptions里面注册推送服务

`JPushConfig *config = [JPushConfig configWithAppKey:@"" channel:@"" apsForProduction:YES isDebug:YES];
[[CMPushNotificationService sharedManager] configurePushWithLaunchOptions:launchOptions pushConfig:config pushNotificationHandler:[CMPushManager new]];
`

* 在需要的地方注册推送

`[[CMPushNotificationService sharedManager] registerRemoteNotification];
`

* 在视图加载完成的地方开始推送

`[[CMPushNotificationService sharedManager] applicationDidLoad];
`

* 在CMPushManager.m 实现协议方法即可

* 具体使用方法可参考Example

