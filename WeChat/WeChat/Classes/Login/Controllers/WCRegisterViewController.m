//
//  WCRegisterViewController.m
//  WeChat
//
//  Created by apple on 15/10/5.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCRegisterViewController.h"

#import "AppDelegate.h"
@interface WCRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userFiled;
@property (weak, nonatomic) IBOutlet UITextField *pwdFiled;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;

@end
@implementation WCRegisterViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"注册";
    //判断当前设备的类型,来改变左右两边的约束的距离
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.leftConstraint.constant = self.rightConstraint.constant = 10;
    }
    
    //设置Feild的背景
    self.userFiled.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdFiled.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    //设置登录按钮的图片
    [self.registerBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
}
- (IBAction)registerAction:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self.userFiled isTelphoneNum]) {
        [MBProgressHUD showError:@"请输入正确的手机号码" toView:self.view    ];
        return ;
    }
    //1.把用户注册的数据保存到单例
    WCUserInfo *userInfo = [WCUserInfo sharedWCUserInfo];
    userInfo.registerUser = self.userFiled.text;
    userInfo.registerPwd = self.pwdFiled.text;
    
    //2.调用AppDelegate的xmppUserRegister
    WCXMPPTool *xmpp = [WCXMPPTool sharedWCXMPPTool];
    xmpp.isRegister = YES;
    __weak typeof(self)weakSelf = self;
    [xmpp xmppUserRegister:^(XMPPResultType type) {
        
        
    }];
    
}
-(void)handleResultType:(XMPPResultType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type) {
            case XMPPResultTypeLoginNEtErr:
                [ MBProgressHUD  showError:@"网络不太给力" toView:self.view];
                break;
            case XMPPREsultTYpeRegisterFailure:
                [ MBProgressHUD  showError:@"该账号已存在" toView:self.view];
                break;
            case XMPPResultTypeRegisterSuccess:
                [ MBProgressHUD  showError:@"注册成功" toView:self.view];
                //返回登陆界面
                [self dismissViewControllerAnimated:YES completion:nil];
                if ([self.deleagate respondsToSelector:@selector(registerViewConrollerSuccess)]) {
                    [self.deleagate registerViewConrollerSuccess];
                }
                
                break;
                
            default:
                break;
        }
        
    });
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
 
}
- (IBAction)changExt:(id)sender {
    BOOL isUser = [self.userFiled isTelphoneNum];
    BOOL isPwd = (self.pwdFiled.text.length != 0);
    
    self.registerBtn.enabled = (isUser && isPwd);
}


@end
