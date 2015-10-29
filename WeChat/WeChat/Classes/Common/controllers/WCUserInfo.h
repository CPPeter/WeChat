//
//  WCUserInfo.h
//  WeChat
//
//  Created by apple on 15/10/5.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Singleton.h"
static NSString *domain = @"woshisinanzhubo";
@interface WCUserInfo : NSObject

singleton_interface(WCUserInfo);
/**
 用户名
 */
@property (nonatomic,copy)NSString *  user;
/**
 密码
 */
@property (nonatomic,copy)NSString * pwd;
/**
 登录的状态
 */
@property (nonatomic,assign)BOOL loginStaus;

/**
 用户注册的用户名
 */
@property (nonatomic,copy)NSString * registerUser;
/**
 用户注册的密码
 */
@property (nonatomic,copy)NSString * registerPwd;
/**
 jid
 */
@property (nonatomic,copy)NSString * jid;
/**
 登陆成功后保存数据到沙盒
 */
-(void)saveuserInfoToSanBox;

/**
 从沙盒中获取数据
 */
-(void)loadUserInfoFromSanbox;

@end
