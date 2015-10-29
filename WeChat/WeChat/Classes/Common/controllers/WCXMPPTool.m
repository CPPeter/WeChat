//
//  WCXMPPTool.m
//  WeChat
//
//  Created by apple on 15/10/6.
//  Copyright © 2015年 PengC. All rights reserved.
//


/*
    XMPP总结
 XMPP是一个即时通讯的传输协议 传输入的数据都是XML格式
 基于模块开发
 
 自动连接模块  网络不稳定,离线的时候,自动连接服务器
 电子名片模块  获取个人信息,保存到数据库
 头像模块     获取头像模块
 花名册模块   获取好友列表, 保存到数据库
 消息模块     接收到聊天消息,保存到数据库
 
 XMPP是基于Socket开发,也是基于TCP协议
 XMPP 服务交互的核心类是XMPPStream
 XMPPStream 里面有个CGDAsynSocket对象
 
 CGDAsynSocket 也有c语言的CFReadStreamRef CFWriteStream 输入输出流
 
 
 //辛辛苦苦搭建XMPP环境
 //删除XMPP环境
 查看有道云笔记

 */

#import "WCXMPPTool.h"

NSString *const WCLoginStatusChangeNotfication = @"WCLoginStatusChangeNotfication";
NSString *const WCCheckMessageNotfication = @"WCCheckMessageNotfication";
@interface WCXMPPTool ()<XMPPStreamDelegate>{
    
    XMPPResultBlock              _resultBlock;
    XMPPReconnect                *_reconnect;//自动连接模块
//    XMPPMessageArchiving         *_message;
//    XMPPMessageArchivingCoreDataStorage   *_messageStorage;
}


// 1. 初始化XMPPStream
-(void)setupXMPPStream;


// 2.连接到服务器
-(void)connectToHost;

// 3.连接到服务成功后，再发送密码授权
-(void)sendPwdToHost;


// 4.授权成功后，发送"在线" 消息
-(void)sendOnlineToHost;
@end
@implementation WCXMPPTool

singleton_implementation(WCXMPPTool);
#pragma mark  -私有方法

#pragma mark 释放XMPPStream相关的资源
-(void)teardownXmpp
{
    //移除代理
    [_xmppStream removeDelegate:self];
    //停止模块
    [_reconnect deactivate];
    [_vCard deactivate];
    [_avatar deactivate];
    [_roster deactivate];
    [_message deactivate];
    
    //断开连接
    [_xmppStream disconnect];
    
    //清空资源
    _reconnect = nil;
    _vCard = nil;
    _vCardStroage = nil;
    _avatar = nil;
    _xmppStream = nil;
    _roster = nil;
    _resterStorage = nil;
    _message = nil;
    _messageStorage = nil;
}
#pragma mark 初始化XMPPStream
-(void)setupXMPPStream{
     
    _xmppStream = [[XMPPStream alloc] init];
    
    //消息模块
    _messageStorage = [[XMPPMessageArchivingCoreDataStorage alloc]init];
    _message = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:_messageStorage];
    
    [_message activate:_xmppStream];
    
    
    //添加花名册,获取好友用的
    _resterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    _roster = [[XMPPRoster alloc]initWithRosterStorage:_resterStorage];
    
    [_roster activate:_xmppStream];
    
    //添加自动连接模块
    _reconnect = [[XMPPReconnect alloc]init];
    [_reconnect activate:_xmppStream];
#warning 每一个模块添加后都要激活
    //添加电子名片模块
    _vCardStroage = [XMPPvCardCoreDataStorage sharedInstance];
    
    _vCard = [[XMPPvCardTempModule alloc]initWithvCardStorage:_vCardStroage];
    
    
    //激活
    [_vCard activate:_xmppStream];
    
    //添加头像模块
    _avatar = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_vCard];
    //激活
    [_avatar activate:_xmppStream];
    
    
    //在ios7的需要开启后台运行Socket的设置(真机上才有本地通知的效果)
    if([[UIDevice currentDevice].systemVersion doubleValue] < 8.0)
    {
        _xmppStream.enableBackgroundingOnSocket = YES;
    }
    
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

#pragma mark 连接到服务器
-(void)connectToHost{
    DLOG(@"开始连接到服务器");
    if (!_xmppStream) {
        [self setupXMPPStream];
    }
    //发送通知
    [self postNotification:XMPPResultTpyeConnecting];
    
    // 设置登录用户JID
    //resource 标识用户登录的客户端 iphone android
    
    // 从沙盒获取用户名
    NSString *user ;
    if(self.isRegister)
    {
        user = [WCUserInfo sharedWCUserInfo].registerUser;
    }
    else
    {
        user = [WCUserInfo sharedWCUserInfo].user;
    }
    
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:@"woshisinanzhubo" resource:@"iphone" ];
    _xmppStream.myJID = myJID;
    
    // 设置服务器域名
    _xmppStream.hostName = @"woshisinanzhubo";//不仅可以是域名，还可是IP地址
    
    // 设置端口 如果服务器端口是5222，可以省略
    _xmppStream.hostPort = 5222;
    
    // 连接
    NSError *err = nil;
    if(![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]){
        DLOG(@"%@",err);
    }
    
}

#pragma mark 连接到服务成功后，再发送密码授权
-(void)sendPwdToHost{
    DLOG(@"再发送密码授权");
    NSError *err = nil;
    NSString *pwd;
    if (self.isRegister) {
    //注册
        pwd = [WCUserInfo sharedWCUserInfo].registerPwd;
        [_xmppStream registerWithPassword:pwd error:&err];
    }
    else
    {//登陆
        pwd = [WCUserInfo sharedWCUserInfo].pwd;
        // 从沙盒里获取密码
        [_xmppStream authenticateWithPassword:pwd error:&err];
    }
    
    if (err) {
        DLOG(@"%@",err);
    }
}

#pragma mark  授权成功后，发送"在线" 消息
-(void)sendOnlineToHost{
    
    DLOG(@"发送 在线 消息");
    XMPPPresence *presence = [XMPPPresence presence];
    DLOG(@"%@",presence);
    
    [_xmppStream sendElement:presence];
    
    
}
#pragma mark 通知WCHisotoryViewController的登陆状态
-(void)postNotification:(XMPPResultType )resulType
{
    NSDictionary *userInfo = @{@"loginStatus":@(resulType)};
  
    [[NSNotificationCenter defaultCenter]postNotificationName:WCLoginStatusChangeNotfication object:@(resulType) userInfo:userInfo];
}
#pragma mark -XMPPStream的代理
#pragma mark 与主机连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    DLOG(@"与主机连接成功");
    
    // 主机连接成功后，发送密码进行授权
    [self sendPwdToHost];
}
#pragma mark  与主机断开连接
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    // 如果有错误，代表连接失败
    
    //如果没有错误,标识正常的断开连接(认为断开连接)
    DLOG(@"与主机断开连接 %@",error);
    
    if(error && _resultBlock)
    {
        _resultBlock(XMPPResultTypeLoginNEtErr);
    }
    //通知WCHisotoryViewController[网络不稳定]
    if (error) {
        [self postNotification:XMPPResultTypeLoginNEtErr];
    }
}


#pragma mark 授权成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    DLOG(@"授权成功");
    
    [self sendOnlineToHost];
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
    }
//    通知WCHisotoryViewController
    [self postNotification:XMPPResultTypeLoginSuccess];
    // 登录成功来到主界面
    // 此方法是在子线程补调用，所以在主线程刷新UI
    
}


#pragma mark 授权失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    DLOG(@"授权失败 %@",error);
    //判断block有无值,在回调给登陆控制器
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginfailure);
    }
//    通知WCHisotoryViewController
    [self postNotification:XMPPResultTypeLoginSuccess];
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    DLOG(@"注册成功");
    if(_resultBlock)
    {
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
}
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    DLOG(@"注册失败");
    if(_resultBlock)
    {
        _resultBlock(XMPPREsultTYpeRegisterFailure);
    }
    if (error) {
        DLOG(@"error=%@",error);
    }
}
#pragma mark 接收到好友消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DLOG(@"message=%@",message);
    
    //在ios8以前,不包括ios8,Socket是不支持后台运行
    //在ios需要做配置,info.plist文件
//    添加 Required background modes = voip;//使用Socket在后台运行
    
    NSString *body = [NSString stringWithFormat:@"%@\n%@",message.fromStr,message.body];
    //添加本地推送
    [self localNotification:body message:message];
    //如果当前程序不在前台,发出一个本地通知
}
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    //XMPPPresence 在线,离线
    
    //presence.frome 消息是谁发送过来的
    
    DLOG(@"presence=%@",presence);
    NSString *body = [NSString stringWithFormat:@"%@\n%@",presence.fromStr,presence.status];
//    [self localNotification:body message:];
    
}
#pragma mark 注册失败

#pragma mark -公共方法
-(void)logout{
    // 1." 发送 "离线" 消息"
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    // 2. 与服务器断开连接
    [_xmppStream disconnect];
    [WCUserInfo sharedWCUserInfo].loginStaus = NO;
    [[WCUserInfo sharedWCUserInfo] saveuserInfoToSanBox ];
    
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//    
//    self.window.rootViewController = story.instantiateInitialViewController;
    [UIStoryboard showInitialVCWithName:@"Login"];
}

-(void)xmppUserLogin:(XMPPResultBlock)resultBlock{
    //先把block存起来
    _resultBlock = [resultBlock copy];
    //断开以前的连接
    [_xmppStream disconnect];
    
    // 连接主机 成功后发送密码
    [self connectToHost];
}
-(void)xmppUserRegister:(XMPPResultBlock)resultBlock{
    
    //先把block存起来
    _resultBlock = [resultBlock copy];
    //断开以前的连接
    [_xmppStream disconnect];
    
    // 连接主机 成功后发送密码
    [self connectToHost];
    
}
-(void)localNotification:(NSString *)body message:(XMPPMessage *)message
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        DLOG(@"在后台");
       //IOS 8以后需要注册通知
        if([[UIDevice currentDevice].systemVersion doubleValue] > 8.0)
        {
            
            //1.创建消息上面添加的动作(以按钮的形式显示出来s)
            UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction  alloc]init];
            action.identifier = @"action";//按钮的标识
            action.title = @"查看消息";//按钮的标题
            action.activationMode = UIUserNotificationActivationModeForeground;//当点击时启动程序
            
//            action.authenticationRequired = YES;  action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
//            action.destructive = YES;
            
//            UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc]init];//第一个按钮
//            action2.identifier = @"action2";
//            action2.title = @"ok";
//            
//            action2.activationMode = UIUserNotificationActivationModeBackground;//当点击时不启动程序,后台处理
//            action2.authenticationRequired = YES;
//            action2.destructive = YES;
            
            UIMutableUserNotificationAction *action3 = [[UIMutableUserNotificationAction alloc]init];
            action3.identifier = @"action3";
            action3.title = @"回复";
            [action3 setBehavior:UIUserNotificationActionBehaviorTextInput];
            action3.activationMode = UIUserNotificationActivationModeBackground;
            action3.authenticationRequired = YES;
            action3.destructive = YES;
            
            //2.创建动作(按钮)的类别集合
            UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc]init];
            category.identifier = @"category";//这组动作的唯一标识,推送的时候也是根据这个来区分
            [category setActions:@[action,action3] forContext:UIUserNotificationActionContextMinimal];
            
            //3.创建UIUserNotificationSettings,并设置消息的显示类型
            UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound |UIUserNotificationTypeAlert) categories:[NSSet setWithObject:category]];
            //注册远程通知
//            [[UIApplication sharedApplication]registerForRemoteNotifications];
            //注册本地通知
            [[UIApplication sharedApplication]registerUserNotificationSettings:notiSettings];
            
        }
        
        //创建一个本地通知
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        //设置通知的触发时间
        notification.fireDate = [NSDate date];
        //设置通知的时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        //设置通知重复发送的时间间隔
//        notification.repeatInterval = kCFCalendarUnitMinute;//每分钟发一次
        //设置通知的声音
        notification.soundName = @"gu.mp3";
        //设置当设备处于锁屏状态是,显示通知的警告框下方的title
        notification.alertAction = @"打开";
        //设置通知是否显示Action
        notification.hasAction = YES;
        //设置通过通知加载应用时的显示的图片
        notification.alertLaunchImage = @"log.png";
        //设置通知内容
        notification.alertBody = body;
        //设置显示应用程序上红色微标中的数字
        notification.applicationIconBadgeNumber = 1;
        //设置userInfo,用于携带额外的附加信息
        NSDictionary *info = @{@"key":@"kfjava.org",@"message":message.fromStr};
        notification.userInfo = info;
        notification.category = @"category";
        //调度通知
        [[UIApplication sharedApplication]scheduleLocalNotification:notification];
        //用下面两个方法判断是否注册成功
        DLOG(@" 本地注册成功?= %@",[[UIApplication sharedApplication]currentUserNotificationSettings]);
        //判断远程通知注册成功
        if ([[UIApplication sharedApplication]isRegisteredForRemoteNotifications]) {
            DLOG(@"远程注册成功");
        }
        
    }
    
}
-(void)sendMessage:(NSString *)text bodyType:(NSString *)bodyType friendJid:(XMPPJID *)friendJid
{
        XMPPMessage *mag = [XMPPMessage messageWithType:@"chat" to:friendJid];
        //text 纯文本
        //imag 图片
        [mag addAttributeWithName:@"bodyType" stringValue:bodyType];
        
        //设置内容
        [mag addBody:text];
        DLOG(@"mag=%@",mag);
        [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:mag];

}
-(void)dealloc
{
    //清空资源
    [self teardownXmpp];
}
@end
