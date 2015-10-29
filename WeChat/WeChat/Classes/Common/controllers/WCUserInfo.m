//
//  WCUserInfo.m
//  WeChat
//
//  Created by apple on 15/10/5.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCUserInfo.h"

#define UserKey @"user"
#define LoginStatusKey @"loginStatus"
#define PwdKey @"pwd"


@implementation WCUserInfo


singleton_implementation(WCUserInfo);
-(void)saveuserInfoToSanBox
{
    NSUserDefaults *dataults = [NSUserDefaults standardUserDefaults];
    [dataults setObject:self.user forKey:UserKey];
    [dataults setBool:self.loginStaus forKey:LoginStatusKey];
    [dataults setObject:self.pwd forKey:PwdKey];
    [dataults synchronize];
}
-(void)loadUserInfoFromSanbox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.user = [defaults objectForKey:UserKey];
    self.loginStaus = [defaults boolForKey:LoginStatusKey];
    self.pwd = [defaults objectForKey:PwdKey];
}
-(NSString *)jid
{
    return [NSString stringWithFormat:@"%@@%@",self.user,domain];
}
@end
