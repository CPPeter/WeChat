//
//  WCRegisterViewController.h
//  WeChat
//
//  Created by apple on 15/10/5.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCRegisterViewControllerDelegate <NSObject>

-(void)registerViewConrollerSuccess;

@end
@interface WCRegisterViewController : UIViewController
@property (nonatomic,weak) id<WCRegisterViewControllerDelegate> deleagate;
@end