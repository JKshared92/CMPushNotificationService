#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CMPushNotificationHandler.h"
#import "CMPushNotificationService.h"
#import "PushConfig.h"
#import "XGPush.h"

FOUNDATION_EXPORT double CMPushNotificationServiceVersionNumber;
FOUNDATION_EXPORT const unsigned char CMPushNotificationServiceVersionString[];

