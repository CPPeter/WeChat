//
//  WCAddContactViewController.m
//  WeChat
//
//  Created by apple on 15/10/19.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCAddContactViewController.h"

@interface WCAddContactViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
@implementation WCAddContactViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
}
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //
//    if (![textField isTelphoneNum]) {
//        [self showAlter:@"请输入正确的手机号"];
//        return YES;
//    }
    //不能添加自己为好友
    if ([textField.text isEqualToString:[WCUserInfo sharedWCUserInfo].user]) {
        [self showAlter:@"不能添加自己为好友"];
         return YES;
    }
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",textField.text,domain];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    //检测好友是否已存在
    if([[WCXMPPTool sharedWCXMPPTool].resterStorage userExistsWithJID:jid xmppStream:[WCXMPPTool sharedWCXMPPTool].xmppStream])
    {
        [self showAlter:@"好友已存在"];
         return YES;
    }
    [[WCXMPPTool sharedWCXMPPTool].roster subscribePresenceToUser:jid];
//    [self.navigationController popViewControllerAnimated:YES];
    [self showAlter:@"好友添加成功"];
    return YES;
}
-(void)showAlter:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"谢谢" otherButtonTitles:nil, nil];
    [alter show];
}
@end
