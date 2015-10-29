
//
//  WCNavigationController.m
//  WeChat
//
//  Created by apple on 15/9/30.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCNavigationController.h"

@implementation WCNavigationController
+(void)initialize
{
    
}
+(void)setupNavTheme
{
    //设置导航样式
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    //1.设置导航条背景
    
    //高度不会拉伸,但是宽度会自动拉伸
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    //2.设置导航栏的字体
    NSMutableDictionary *att = [NSMutableDictionary dictionary];
    att[NSForegroundColorAttributeName] = [UIColor whiteColor];
    att[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    
    [navBar setTitleTextAttributes:att];
    
    //设置状态栏的样好似
    //xcode5以上,创建的项目,默认状态栏的样式是由控制器决定
    //在plist文件里添加View controller-based status bar appearance,设置为NO,取消控制器对状态栏的控制,更改为导航控制器控制
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

//结论:入股哟控制器是由导航控制器管理,设置状态栏的样式时,要在导航控制器里设置
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

@end
