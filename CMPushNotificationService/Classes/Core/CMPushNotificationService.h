//
//  CMPushNotificationService.h
//  CMPushNotificationServiceDemo
//
//  Created by on 2017/8/2.
//  Copyright © 2017年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushConfig.h"
#import "CMPushNotificationHandler.h"

@interface CMPushNotificationService : NSObject

@property (copy  , nonatomic) NSData *deviceToken;
@property (assign, nonatomic) BOOL   clearBadgeAfterHandlerNotification;

/**
 单例对象
 
 @return 返回单例
 */
+ (instancetype)sharedManager;

/**
 判断是否开启推送
 
 @return 推送是否开启
 */
- (BOOL)isOpenRemoteNotification;


/**
 返回第三方平台的设备标识

 @return 第三方平台的设备标识
 */
- (NSString *)registrationID;

/**
 初始化
 
 @param launchOptions 启动的参数
 @param pushConfig JPush的参数
 @param pushNotificationHandler 代理协议的执行者
 */
- (void)configurePushWithLaunchOptions:(NSDictionary *)launchOptions
                            pushConfig:(PushConfig  *)pushConfig
               pushNotificationHandler:(id <CMPushNotificationHandler>)pushNotificationHandler;

/**
 设置角标
 */
- (void)setApplicationBadge:(NSInteger)badge;

/**
 注册推送服务
 */
- (void)registerRemoteNotification;

/**
 关闭推送服务
 */
- (void)unregisterRemoteNotifications;

#pragma mark - Application Life Cycle

/**
 向第三方平台注册设备

 @param deviceToken 设备标识
 */
- (void)registerDeviceToken:(NSData *)deviceToken;

/**
 收到推送消息
 
 @param application 当前的应用
 @param userInfo 推送的内容
 @param completionHandler 完成后的处理结果
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 注册推送服务失败
 
 @param application 当前的应用
 @param error 失败的原因
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 视图结构初始化完成，可以进行推送跳转
 */
- (void)applicationDidLoad;

@end
