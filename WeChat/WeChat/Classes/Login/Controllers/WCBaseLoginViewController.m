//
//  WCBaseLoginViewController.m
//  WeChat
//
//  Created by apple on 15/10/5.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCBaseLoginViewController.h"

#import "AppDelegate.h"

@implementation WCBaseLoginViewController

- (void)Login {
    //登录
    /*
     官方的登陆实现
     * 1,把用户名和密码放在沙盒
     
     
     
     * 2.调用AppDelegate的一个connect连接服务并登陆
     
     */
    
    //隐藏键盘
    [self.view endEditing:YES];
    //登录之前给个提示
    [MBProgressHUD showMessage:@"正在登录中" toView:self.view];
    WCXMPPTool *xmpp = [WCXMPPTool sharedWCXMPPTool];
    xmpp.isRegister = NO;
    __weak typeof(self) blockSelf = self;
    [xmpp xmppUserLogin:^(XMPPResultType type) {
        [blockSelf handleResultType:type];
    }];
    
}
-(void)handleResultType:(XMPPResultType)type
{
    //主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case XMPPResultTypeLoginSuccess:
            {
                //登陆成功
                [self enterMainPage];
                
            }
                break;
            case XMPPResultTypeLoginfailure:
                //登陆失败
                [MBProgressHUD showError:@"用户名或密码不正确"  toView:self.view];
                break;
            case XMPPResultTypeLoginNEtErr:
            {
                //网络错误
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
            }
            default:
                break;
        }
    });
    
}
-(void)enterMainPage
{
    [WCUserInfo sharedWCUserInfo].loginStaus = YES;
    //把用户登陆成功的数据,保存到沙盒
    [[WCUserInfo sharedWCUserInfo]saveuserInfoToSanBox];
    
    
    // 登录成功来到主界面
    // 此方法是在子线程补调用，所以在主线程刷新UI
    
    [self dismissViewControllerAnimated:YES completion:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.view.window.rootViewController = storyboard.instantiateInitialViewController;  
}
@end
