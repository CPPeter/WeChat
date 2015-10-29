//
//  WCInputIVew.h
//  WeChat
//
//  Created by apple on 15/10/19.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCInputIVew : UIView
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
+(instancetype)inputView;
@end
