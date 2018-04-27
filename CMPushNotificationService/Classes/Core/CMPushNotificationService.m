//
//  CMPushNotificationService.m
//  CMPushNotificationServiceDemo
//
//  Created by on 2017/8/2.
//  Copyright © 2017年 . All rights reserved.
//

#import "CMPushNotificationService.h"
#import <JPush/JPUSHService.h>
#import <XGPush.h>

@interface CMPushNotificationService ()<JPUSHRegisterDelegate, XGPushDelegate>

@property (assign, nonatomic) BOOL           appDidLoad;
@property (strong, nonatomic) PushConfig     *pushConfig;
@property (copy  , nonatomic) NSDictionary   *launchedNotification;
@property (strong, nonatomic) NSMutableArray *remoteNotifications;
@property (strong, nonatomic) id <CMPushNotificationHandler> pushNotificationHandler;

@end

@implementation CMPushNotificationService

- (BOOL)isOpenRemoteNotification{
    return [[UIApplication sharedApplication] currentUserNotificationSettings].types != 0;
}

- (NSString *)registrationID{
    if ([self.pushConfig isKindOfClass:[JPushConfig class]]) {
        return [JPUSHService registrationID];
    }
    if ([self.pushConfig isKindOfClass:[XGPushConfig class]]) {
        return [XGPushTokenManager defaultTokenManager].deviceTokenString;
    }
    return nil;
}

+ (instancetype)sharedManager{
    static CMPushNotificationService *manager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:NULL];
        [manager defaultSetting];
    }) ;
    
    return manager ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [CMPushNotificationService sharedManager];
}

- (id)copyWithZone:(struct _NSZone *)zone{
    return [CMPushNotificationService sharedManager];
}

- (void)defaultSetting{
    self.deviceToken             = nil;
    self.launchedNotification    = nil;
    self.appDidLoad              = NO;
    self.pushConfig              = nil;
    self.remoteNotifications     = [[NSMutableArray alloc] init];
    self.clearBadgeAfterHandlerNotification = NO;
}

#pragma mark - 配置服务
- (void)configurePushWithLaunchOptions:(NSDictionary *)launchOptions
                            pushConfig:(PushConfig *)pushConfig
               pushNotificationHandler:(id<CMPushNotificationHandler>)pushNotificationHandler{
    
    self.pushConfig = pushConfig;
    self.pushNotificationHandler = pushNotificationHandler;
    
    if ([pushConfig isKindOfClass:[JPushConfig class]]) {
        JPushConfig *jPush = (JPushConfig *)pushConfig;
        [JPUSHService setupWithOption:launchOptions
                               appKey:jPush.appKey
                              channel:jPush.channel
                     apsForProduction:jPush.isProduction];
        
        if (jPush.isDebug) {
            [JPUSHService setLogOFF];
        }
    }
    
    if ([self isOpenRemoteNotification]) {
        NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotification) {
            self.launchedNotification = remoteNotification;
            [self setApplicationBadge:0];
            if ([self.pushConfig isKindOfClass:[JPushConfig class]]) {
                [JPUSHService handleRemoteNotification:self.launchedNotification];
                return;
            }
            if ([self.pushConfig isKindOfClass:[XGPushConfig class]]) {
                [[XGPush defaultManager] reportXGNotificationInfo:launchOptions];
                return;
            }
        }
    }
}

#pragma mark - 程序结构布局完成
- (void)applicationDidLoad{
    if (!self.appDidLoad) {
        self.appDidLoad = YES;
        if (self.launchedNotification) {
            
            if ([self.pushNotificationHandler respondsToSelector:@selector(didHandleNotification:notificationResponse:)]) {
                [self.pushNotificationHandler didHandleNotification:self.launchedNotification notificationResponse:nil];
            }
            
            [self didHandleNotification:self.launchedNotification];
        }
    }
}

#pragma mark - 注册/关闭推送模块
- (void)registerRemoteNotification{
    
    if ([self.pushConfig isKindOfClass:[JPushConfig class]]) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        
        //iOS 10以后
        if (@available(iOS 10.0, *)) {
            entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        } else {
            entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
        }
        
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
        return;
    }
    if ([self.pushConfig isKindOfClass:[XGPushConfig class]]) {
        XGPushConfig *xgPush = (XGPushConfig *)self.pushConfig;
        [[XGPush defaultManager] startXGWithAppID:xgPush.appID appKey:xgPush.appKey delegate:self];
        [[XGPush defaultManager] setEnableDebug:xgPush.isDebug];
        return;
    }
}

- (void)unregisterRemoteNotifications{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    if ([self.pushConfig isKindOfClass:[XGPushConfig class]]) {
        [[XGPush defaultManager] stopXGNotification];
        return;
    }
}

#pragma mark - 设备注册
- (void)registerDeviceToken:(NSData *)deviceToken{
    self.deviceToken = deviceToken;
    if ([self.pushConfig isKindOfClass:[JPushConfig class]]) {
        __weak __typeof(self)weakSelf = self;
        [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf.pushNotificationHandler && [strongSelf.pushNotificationHandler respondsToSelector:@selector(didReceiveRegistrationID:statusCode:)]) {
                [strongSelf.pushNotificationHandler didReceiveRegistrationID:registrationID statusCode:resCode];
            }
        }];
        
        [JPUSHService registerDeviceToken:deviceToken];
        return;
    }
    
    if ([self.pushConfig isKindOfClass:[XGPushConfig class]]) {
        [[XGPushTokenManager defaultTokenManager] registerDeviceToken:deviceToken];
        
        if (self.pushNotificationHandler && [self.pushNotificationHandler respondsToSelector:@selector(didReceiveRegistrationID:statusCode:)]) {
            [self.pushNotificationHandler didReceiveRegistrationID:[XGPushTokenManager defaultTokenManager].deviceTokenString statusCode:0];
        }
        return;
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"\n 注册推送服务失败，失败原因:\n %@\n",error);
}

#pragma mark - 收到推送通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    if ([self.pushConfig isKindOfClass:[JPushConfig class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    if ([self.pushConfig isKindOfClass:[XGPushConfig class]]) {
        [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
    }
    
    //没有远程推送的响应者就立即退出
    if (!self.pushNotificationHandler || ![self.pushNotificationHandler conformsToProtocol:@protocol(CMPushNotificationHandler)]) {
        completionHandler(UIBackgroundFetchResultNewData);
        return;
    }
    
    
    NSDictionary *aps = userInfo[@"aps"];
    NSString *sound = [aps valueForKey:@"sound"];
    NSNumber *badge = [aps valueForKey:@"badge"];
    
    //静默通知,iOS8~iOS11
    if (!sound && !badge) {
        if ([self.pushNotificationHandler respondsToSelector:@selector(didReceiveSilentRemoteNotification:fetchCompletionHandler:)]) {
            [self.pushNotificationHandler didReceiveSilentRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        }else{
            completionHandler(UIBackgroundFetchResultNewData);
        }
        return;
    }
    
    //在前台及后台收到通知,iOS8以上
    if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
        if ([self.pushNotificationHandler respondsToSelector:@selector(didReceiveRemoteNotification:applicationState:fetchCompletionHandler:)]) {
            [self.pushNotificationHandler didReceiveRemoteNotification:userInfo applicationState:application.applicationState fetchCompletionHandler:completionHandler];
        }else{
            completionHandler(UIBackgroundFetchResultNewData);
        }
        return;
    }
    
    NSString *messgaeSignage = userInfo.description;
    
    //待激活的状态，需要判断是点击调用还是收到新的推送,iOS8以上
    if ([self.remoteNotifications indexOfObject:messgaeSignage] != NSNotFound) {
        /**
         先判断是否是点击通知还是收到通知,
         以前收到过该信息，本次操作是点击通知
         **/
        if ([self.pushNotificationHandler respondsToSelector:@selector(didHandleNotification:notificationResponse:)]) {
            [self.pushNotificationHandler didHandleNotification:userInfo notificationResponse:nil];
        }else{
            completionHandler(UIBackgroundFetchResultNewData);
        }
        
        [self didHandleNotification:userInfo];
        return;
    }
    
    //本次是第一次接受到该消息
    [self.remoteNotifications addObject:messgaeSignage];
    if ([self.pushNotificationHandler respondsToSelector:@selector(didReceiveRemoteNotification:applicationState:fetchCompletionHandler:)]) {
        [self.pushNotificationHandler didReceiveRemoteNotification:userInfo applicationState:application.applicationState fetchCompletionHandler:completionHandler];
    }else{
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

#pragma mark - 设置角标
- (void)setApplicationBadge:(NSInteger)badge{
    if (badge == 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    if ([self.pushConfig isKindOfClass:[JPushConfig class]]) {
        [JPUSHService setBadge:badge];
        return;
    }
    if ([self.pushConfig isKindOfClass:[XGPushConfig class]]) {
        [[XGPush defaultManager] setBadge:badge];
        return;
    }
}

#pragma mark - 点击通知
- (void)didHandleNotification:(NSDictionary *)notification{
    
    if (self.clearBadgeAfterHandlerNotification) {
        [self setApplicationBadge:0];
    }
    
    [self.remoteNotifications removeAllObjects];
    
    if (!self.appDidLoad) {
        self.launchedNotification = notification;
        return;
    }
    
    self.launchedNotification = nil;
}

#pragma mark - XGPushDelegate
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
    
    if (@available(iOS 10.0, *)) {
        if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            //远程通知
            if ([self.pushNotificationHandler respondsToSelector:@selector(didHandleNotification:notificationResponse:)] && self.appDidLoad) {
                [self.pushNotificationHandler didHandleNotification:userInfo notificationResponse:response];
            }
            [self didHandleNotification:userInfo];
        }
    } else {
        // Fallback on earlier versions
    }
    
    completionHandler();
}

- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    [[XGPush defaultManager] reportXGNotificationInfo:notification.request.content.userInfo];
    
    [self.remoteNotifications addObject:notification.request.content.userInfo.description];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (@available(iOS 10.0, *)) {
            completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
        } else {
            // Fallback on earlier versions
        }
    }else{
        if (@available(iOS 10.0, *)) {
            completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge);
        } else {
            // Fallback on earlier versions
        }
    }
    
    if ([self.pushNotificationHandler respondsToSelector:@selector(pushWillPresentNotification:withCompletionHandler:)]) {
        [self.pushNotificationHandler pushWillPresentNotification:notification withCompletionHandler:completionHandler];
        return;
    }
}

#pragma mark - JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger options))completionHandler{
    [JPUSHService handleRemoteNotification:notification.request.content.userInfo];
    
    [self.remoteNotifications addObject:notification.request.content.userInfo.description];
    
    if ([self.pushNotificationHandler respondsToSelector:@selector(pushWillPresentNotification:withCompletionHandler:)]) {
        [self.pushNotificationHandler pushWillPresentNotification:notification withCompletionHandler:^(UNNotificationPresentationOptions notificateOptions) {
            if (completionHandler) {
                completionHandler((NSInteger)notificateOptions);
            }
        }];
        return;
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (@available(iOS 10.0, *)) {
            completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
        } else {
            // Fallback on earlier versions
        }
    }else{
        if (@available(iOS 10.0, *)) {
            completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge);
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            //远程通知
            if ([self.pushNotificationHandler respondsToSelector:@selector(didHandleNotification:notificationResponse:)] && self.appDidLoad) {
                [self.pushNotificationHandler didHandleNotification:userInfo notificationResponse:response];
            }
            [self didHandleNotification:userInfo];
        }
    } else {
        // Fallback on earlier versions
    }
    
    completionHandler();
}

@end
