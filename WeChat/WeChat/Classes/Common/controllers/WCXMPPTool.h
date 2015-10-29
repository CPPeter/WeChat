//
//  WCXMPPTool.h
//  WeChat
//
//  Created by apple on 15/10/6.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "Singleton.h"

extern NSString *const WCLoginStatusChangeNotfication;
extern NSString *const WCCheckMessageNotfication;

typedef enum {
    XMPPResultTpyeConnecting,//连接中
    XMPPResultTypeLoginSuccess,//登陆成功
    XMPPResultTypeLoginfailure,//登陆失败
    XMPPResultTypeLoginNEtErr,//网络不给力
    XMPPResultTypeRegisterSuccess,//注册成功
    XMPPREsultTYpeRegisterFailure//注册失败
    
}XMPPResultType;



typedef void (^XMPPResultBlock) (XMPPResultType type);//XMPP请求结果的Block


@interface WCXMPPTool : NSObject
/** 电子名片 */
@property (strong,nonatomic,readonly)XMPPvCardTempModule          *vCard;
/** 电子名牌呢的数据存储*/
@property (strong,nonatomic,readonly)XMPPvCardCoreDataStorage     *vCardStroage;
/** 头像模块 */
@property (strong,nonatomic,readonly)XMPPvCardAvatarModule        *avatar;
/** 是否是注册操作 */
@property (nonatomic,assign) BOOL                        isRegister;
/** 花名册数据存储 */
@property (nonatomic,strong,readonly)XMPPRosterCoreDataStorage    *resterStorage;
/** 花名册模块 */
@property (nonatomic,strong,readonly)XMPPRoster                   *roster;
/** xmppStream */
@property (nonatomic,strong,readonly,readonly)XMPPStream                   *xmppStream;
/** XMPPMessage */
@property (nonatomic,strong)XMPPMessageArchiving         *message;
/** XMPPMessage */
@property (nonatomic,strong,readonly)XMPPMessageArchivingCoreDataStorage   *messageStorage;


singleton_interface(WCXMPPTool);

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
/**
 用户登陆
 */
-(void)xmppUserLogin:(XMPPResultBlock) resultBlock;
/**
 注消登陆
 */
-(void)logout;

/**
 用户注册
 */
-(void)xmppUserRegister:(XMPPResultBlock)resultBlock;

/**
 发送消息
 */
-(void)sendMessage:(NSString *)text bodyType:(NSString *)bodyType friendJid:(XMPPJID *)friendJi;



@end
