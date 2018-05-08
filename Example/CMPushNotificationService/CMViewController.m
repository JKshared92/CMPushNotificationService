//
//  CMViewController.m
//  CMPushNotificationService
//
//  Created by comma on 04/19/2018.
//  Copyright (c) 2018 comma. All rights reserved.
//

#import "CMViewController.h"
#import <CMPushNotificationService/CMPushNotificationService.h>

@interface CMViewController ()

@end

@implementation CMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /**注册推送,这个放的位置看个人需求*/
    [[CMPushNotificationService sharedManager] registerRemoteNotification];
    
    /**在视图加载完成开始执行推送*/
    [[CMPushNotificationService sharedManager] applicationDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
