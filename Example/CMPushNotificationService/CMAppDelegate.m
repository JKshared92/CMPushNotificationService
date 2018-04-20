//
//  CMAppDelegate.m
//  CMPushNotificationService
//
//  Created by comma on 04/19/2018.
//  Copyright (c) 2018 comma. All rights reserved.
//

#import "CMAppDelegate.h"
#import <CMPushNotificationService/CMPushNotificationService.h>
#import "CMPushManager.h"

@implementation CMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    /**极光*/
    JPushConfig *config = [JPushConfig configWithAppKey:@"" channel:@"" apsForProduction:YES isDebug:YES];
    
    /**信鸽*/
//    XGPushConfig *config = [XGPushConfig configWithAppID:123 appKey:@"" isDebug:YES];
    
    [[CMPushNotificationService sharedManager] configurePushWithLaunchOptions:launchOptions pushConfig:config pushNotificationHandler:[CMPushManager new]];
    
    return YES;
}

@end
