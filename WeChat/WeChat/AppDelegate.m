//
//  AppDelegate.m
//  02.XMPP框架的导入
//
//  Created by apple on 14/12/6.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "WCNavigationController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "WCContactsViewController.h"


/*
 * 在AppDelegate实现登录
 
 1. 初始化XMPPStream
 2. 连接到服务器[传一个JID]
 3. 连接到服务成功后，再发送密码授权
 4. 授权成功后，发送"在线" 消息
 */


@implementation AppDelegate

- (void)registerJPushWithOptions:(NSDictionary *)launchOptions
{
    
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //沙盒的路径
     NSString *path =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    DLOG(@"path =%@",path);
    
    //极光推送
    [self registerJPushWithOptions:launchOptions];
    
    //打开XMPP的日志
//    [DDLog addLogger:[DDTTYLogger sharedInstance]]; 
    
    
    //设置导航样式
    [WCNavigationController setupNavTheme];
    
    //从沙盒中加载用户的数据到单例
    [[WCUserInfo sharedWCUserInfo]loadUserInfoFromSanbox];
    
    //判断用户的登陆状态 YES直接来到主界面
    if([WCUserInfo sharedWCUserInfo].loginStaus)
    {
        UIStoryboard *storBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storBoard.instantiateInitialViewController;
        
        //自动登陆服务
        //等待1秒后在连接
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WCXMPPTool sharedWCXMPPTool] xmppUserLogin:nil];
        });
        
    }
    
//    //ios8以后需要应用接收注册通知
//    if([[UIDevice currentDevice].systemVersion doubleValue] > 8.0)
//    {
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
//        [application registerUserNotificationSettings:settings];
//    }
    
    return YES;
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //成功注册本地通知后的回调
    DLOG(@"本地通知注册成功");
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //成功注册远程通知的回调
    if (application.applicationState == UIApplicationStateActive)
    {
        NSLog(@"接收到push的数据:%@", userInfo);
        [self  showJPush:userInfo];
    }
    else
    {
        //极光推送 Required
        [APService handleRemoteNotification:userInfo];
    }
    DLOG(@"未知回调=%@",userInfo);
}
#pragma mark 接受通知,并当前应用程序在前台运行时才会被调用
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DLOG(@"前台接收通知的回调")
}
#pragma mark 本地通知ios8
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    //在非本App界面时收到本地消息，下拉消息会有快捷回复的按钮，点击按钮后调用的方法，根据identifier来判断点击的哪个按钮，notification为消息内容
    NSLog(@"%@---%@",identifier,notification.userInfo);
    if ([identifier isEqualToString:@"action"] && [notification.category isEqualToString:@"category"]) {
        DLOG(@"查看消息");
      
        UITabBarController *tabel = (UITabBarController *)self.window.rootViewController;
        tabel.selectedIndex = 1;
       UINavigationController  *nav = tabel.viewControllers[1];
        [nav popToRootViewControllerAnimated:YES];
        //通知
        [[NSNotificationCenter defaultCenter]postNotificationName:WCCheckMessageNotfication object:notification.userInfo[@"message"] userInfo:nil];
    }
    else if([identifier isEqualToString:@"action2"] && [notification.category isEqualToString:@"category"])
    {
        DLOG(@"自动回复:ok");
        //自动回复消息:ok
       
        [[WCXMPPTool sharedWCXMPPTool]sendMessage:@"ok" bodyType:@"text" friendJid:[XMPPJID jidWithString:notification.userInfo[@"message"]]];
    }
    completionHandler();//处理完消息，最后一定要调用这个代码块
}
#pragma mark 本地推送,ios9的回调方法
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler
{
//    UIUserNotificationTextInputActionButtonTitleKey获取点击的按钮类型
//    当Action为UIUserNotificationActionBehaviorDefault时,responseInfo为nil,通过identifier来区分点击按钮分别是什么来做处理
    DLOG(@"%@---%@",identifier,notification);
    DLOG(@"respinseInfo = %@",responseInfo);
    if ([identifier isEqualToString:@"action"] && [notification.category isEqualToString:@"category"]) {
        DLOG(@"action");
    }
    else if([identifier isEqualToString:@"action2"] && [notification.category isEqualToString:@"category"])
    {
        DLOG(@"action2");
    }
    else
    {//手动回复的按钮
        NSString *msg = responseInfo[UIUserNotificationActionResponseTypedTextKey];
        [[WCXMPPTool sharedWCXMPPTool]sendMessage:msg bodyType:@"text" friendJid:[XMPPJID jidWithString:notification.userInfo[@"message"]]];
    }
    completionHandler();//处理完消息，最后一定要调用这个代码块
}
#pragma mark 远程通知 ios8
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    NSLog(@"%@---%@",identifier,userInfo);
    [APService handleRemoteNotification:userInfo];
    completionHandler();//处理完消息，最后一定要调用这个代码块
}
#pragma mark 远程推送,ios9的回调方法
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler
{
    NSLog(@"%@---%@---%@",identifier,userInfo,responseInfo);
   [APService handleRemoteNotification:userInfo];
    
    completionHandler();//处理完消息，最后一定要调用这个代码块
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //向apns注册成功,收到返回的deviceToken
    DLOG(@"devicetoken=%@",[[NSString alloc]initWithData:deviceToken encoding:NSUTF8StringEncoding]);
    //极光推送 Required
    [APService registerDeviceToken:deviceToken];
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //向apns注册失败,返回错误信息
    DLOG(@"error=%@",error);
}
/**
 *  显示极光推送消息
 */
-(void)showJPush:(NSDictionary *)userInfo
{
    // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个alertView，只是那样稍显aggressive
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSString *alertStr                     = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    localNotification.alertBody            = alertStr;
    NSDate *currentDate                    = [NSDate date];
    localNotification.timeZone             = [NSTimeZone defaultTimeZone];// 使用本地时区
    localNotification.fireDate             = [currentDate dateByAddingTimeInterval:3.0];
    localNotification.alertAction          = NSLocalizedString(@"查看消息", nil);
    [[UIApplication sharedApplication]scheduleLocalNotification:localNotification];
}
-(void)dealloc
{
    DLOG(@"fghjkl;ghjkl;");
}


@end
