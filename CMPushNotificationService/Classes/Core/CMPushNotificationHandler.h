//
//  CMPushNotificationHandler.h
//  CMPushNotificationServiceDemo
//
//  Created by on 2017/8/2.
//  Copyright © 2017年. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@protocol CMPushNotificationHandler <NSObject>

@optional

/**
 接受到第三方平台返回的唯一标识

 @param registrationID 第三方平台的唯一标识
 @param statusCode 状态码
 */
- (void)didReceiveRegistrationID:(NSString *)registrationID
                      statusCode:(int)statusCode;

/**
 接收到新的非静默推送消息的回调，iOS8~iOS11支持
 
 @param userInfo 推送内容
 @param completionHandler 完成后的回调
 */
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
                    applicationState:(UIApplicationState)applicationState
              fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 接收到新的静默消息的回调，iOS8～iOS11均支持
 
 @param userInfo 推送内容
 @param completionHandler 完成后的回调
 */
- (void)didReceiveSilentRemoteNotification:(NSDictionary *)userInfo
                    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 点击推送后的处理回调
 
 @param userInfo 推送内容
 @param response 推送的消息，仅iOS10以上有
 */
- (void)didHandleNotification:(NSDictionary *)userInfo
         notificationResponse:(UNNotificationResponse *)response;

#pragma mark - iOS10新增方法

/**
 推送通知显示完毕后的回调
 
 @param notification 通知内容
 @param completionHandler 完成后的回调
 */
- (void)pushWillPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;

@end
