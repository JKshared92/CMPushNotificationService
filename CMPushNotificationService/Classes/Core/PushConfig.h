//
//  JPushConfig.h
//  MTEPushNotificationServiceDemo
//
//  Created by 蒋瞿风 on 2017/8/2.
//  Copyright © 2017年 nightx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushConfig : NSObject

@property (copy  , nonatomic) NSString *appKey;  //应用在第三方平台注册的KEY
@property (assign, nonatomic) BOOL      isDebug; //是否打印Debug信息

@end

/**极光推送*/
@interface JPushConfig : PushConfig

@property (copy  , nonatomic) NSString *channel;        //发布渠道
@property (assign, nonatomic) BOOL     isProduction;    //是否生产环境. 如果为开发状态,设置为 NO; 如果为生产状态,应改为 YES.App 证书环境取决于profile provision的配置，此处建议与证书环境保持一致.

+ (instancetype)configWithAppKey:(NSString *)appKey
                         channel:(NSString *)channel
                apsForProduction:(BOOL)isProduction
                         isDebug:(BOOL)isDebug;

@end

/**信鸽推送*/
@interface XGPushConfig : PushConfig

@property (nonatomic, assign) uint32_t  appID;

+ (instancetype)configWithAppID:(uint32_t)appID
                         appKey:(NSString *)appKey
                        isDebug:(BOOL)isDebug;

@end
