//
//  WCChatTableViewCell.h
//  WeChat
//
//  Created by apple on 15/10/20.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPvCardTemp.h"

@interface WCChatTableViewCell : UITableViewCell

@property (nonatomic,strong)UIImageView  *messageImg;//图片显示
@property (nonatomic,strong)UIImageView  *headerImg;//头像图片
@property (nonatomic,strong)UILabel      *messageText;//纯文本

/**
 判断是否是自己发出去的,
 */
@property (nonatomic,assign)BOOL         isoutgoing;
@end
