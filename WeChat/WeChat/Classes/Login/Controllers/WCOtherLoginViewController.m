//
//  WCOtherLoginViewController.m
//  WeChat
//
//  Created by apple on 15/9/29.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCOtherLoginViewController.h"

#import "AppDelegate.h"

@interface WCOtherLoginViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@end

@implementation WCOtherLoginViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"其他方式登录";
    
    //判断当前设备的类型,来改变左右两边的约束的距离
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.leftConstraint.constant = self.rightConstraint.constant = 10;
    }
    
    //设置Feild的背景
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    //设置登录按钮的图片
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
}
- (IBAction)loginBtnClick {
    //登录
    /*
     官方的登陆实现
     * 1,把用户名和密码放在沙盒
     
     
     
     * 2.调用AppDelegate的一个connect连接服务并登陆

     */
    
   
    WCUserInfo *userinfo = [WCUserInfo sharedWCUserInfo];
    userinfo.user = self.userField.text;
    userinfo.pwd = self.pwdField.text;
    
    [self Login];
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc
{
//    DLog(@"%s",__func__);
//    DLog();
    
}
@end
 