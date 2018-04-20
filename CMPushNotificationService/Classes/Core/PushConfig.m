//
//  JPushConfig.m
//  MTEPushNotificationServiceDemo
//
//  Created by 蒋瞿风 on 2017/8/2.
//  Copyright © 2017年 nightx. All rights reserved.
//

#import "PushConfig.h"

@implementation PushConfig

@end

@implementation JPushConfig

+ (instancetype)configWithAppKey:(NSString *)appKey
                         channel:(NSString *)channel
                apsForProduction:(BOOL)isProduction
                         isDebug:(BOOL)isDebug {
    return [[self alloc] initWithAppKey:appKey
                                channel:channel
                       apsForProduction:isProduction
                                isDebug:isDebug];
}

- (instancetype)initWithAppKey:(NSString *)appKey
                       channel:(NSString *)channel
              apsForProduction:(BOOL)isProduction
                       isDebug:(BOOL)isDebug {
    self = [super init];
    if (self) {
        self.appKey        = appKey;
        self.channel       = channel;
        self.isProduction  = isProduction;
        self.isDebug       = isDebug;
    }
    return self;
}

@end

@implementation XGPushConfig

+ (instancetype)configWithAppID:(uint32_t)appID
                         appKey:(NSString *)appKey
                        isDebug:(BOOL)isDebug {
    return [[self alloc] initWithAppID:appID
                                appKey:appKey
                               isDebug:isDebug];
}

- (instancetype)initWithAppID:(uint32_t)appID
                         appKey:(NSString *)appKey
                        isDebug:(BOOL)isDebug {
    self = [super init];
    if (self) {
        self.appID = appID;
        self.appKey = appKey;
        self.isDebug = isDebug;
    }
    return self;
}

@end
