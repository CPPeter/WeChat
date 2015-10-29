//
//  Regextool.m
//  WeChat
//
//  Created by apple on 15/10/6.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "Regextool.h"

@implementation Regextool
+(BOOL)isTelphoneNum:(NSString *)telphoneNum
{
    NSString *telRegex = @"^1[3578]\\d{9}$";
    NSPredicate *prediate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telRegex];
    return [prediate evaluateWithObject:telphoneNum];
}
@end
