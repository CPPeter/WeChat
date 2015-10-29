//
//  WCMeViewController.m
//  WeChat
//
//  Created by apple on 15/10/5.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCMeViewController.h"

#import "AppDelegate.h"

#import "XMPPvCardTemp.h"

@interface WCMeViewController ()
/**
 头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
/**
 昵称
 */
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
/**
 微信号
 */
@property (weak, nonatomic) IBOutlet UILabel *weixinNumLabel;

@end

@implementation WCMeViewController
-(void)viewDidLoad
{
    [super viewDidLoad];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self upInfo];
}
-(void)upInfo
{
    //显示当前用户的个人信息
    
    //如何使用CoreData获取数据
    //1.上下文[关联到数据];
    //2.FetchRequest
    //3.设置过虐和排序
    //4,执行请求获取数据
    
    //xmpp提供了一个方法,直接获取个人信息
    XMPPvCardTemp *myVcTemp = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    //设置头像
    if (myVcTemp.photo) {
        self.headerImageView.image = [ UIImage imageWithData:myVcTemp.photo];
    }
    //设置昵称
    if (myVcTemp.nickname) {
        self.nickNameLabel.text = myVcTemp.nickname;
    }
    //设置微信号
    
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
    self.weixinNumLabel.text = [NSString stringWithFormat:@"微信号:%@",user];
}
- (IBAction)loginOutBtnAction:(id)sender {
    //直接调用appDelegate里的注销方法
    
    [[WCXMPPTool sharedWCXMPPTool] logout];
}

@end
