//
//  WCLoginViewController.m
//  WeChat
//
//  Created by apple on 15/10/5.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCLoginViewController.h"
#import "WCNavigationController.h"
#import "WCRegisterViewController.h"

@interface WCLoginViewController ()<WCRegisterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *pwdFiled;
- (IBAction)LoginBtnAction:(id)sender;
- (IBAction)registerBtnAction:(id)sender;

@end

@implementation WCLoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置TextFiled和Btn的样式
    self.pwdFiled.background = [UIImage stretchedImageWithName:@"operationbox_text"];
  
    [self.pwdFiled addLeftViewWithImage:@"Card_Lock"];
    
    //设置用户名为上次登录的用户名
    //从沙盒获取用户名
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
    self.userLabel.text = user;
}    

- (IBAction)LoginBtnAction:(id)sender {
    [WCUserInfo sharedWCUserInfo].user = self.userLabel.text;
    [WCUserInfo sharedWCUserInfo].pwd = self.pwdFiled.text;
    
    [self Login];

}

- (IBAction)registerBtnAction:(id)sender {
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id dVc = segue.destinationViewController;
    if ([dVc isKindOfClass:[WCNavigationController class]]) {
        WCNavigationController *nav = dVc;
        UIViewController *Vc = nav.topViewController;
        if ([Vc isKindOfClass:[WCRegisterViewController class]]) {
            WCRegisterViewController *registerCtl = (WCRegisterViewController *)Vc;
            registerCtl.deleagate = self;
        }
    }
}
-(void)registerViewConrollerSuccess
{
    self.userLabel.text = [WCUserInfo sharedWCUserInfo].registerUser;
}
@end
