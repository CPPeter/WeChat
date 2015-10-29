//
//  WCInputIVew.m
//  WeChat
//
//  Created by apple on 15/10/19.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCInputIVew.h"

@implementation WCInputIVew
+(instancetype)inputView
{
    return  [[[NSBundle mainBundle]loadNibNamed:@"WCInputVew" owner:nil options:nil] lastObject];
}
@end
