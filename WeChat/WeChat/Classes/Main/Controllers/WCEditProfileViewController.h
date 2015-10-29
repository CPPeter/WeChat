//
//  WCEditProfileViewController.h
//  WeChat
//
//  Created by apple on 15/10/15.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^editProfileSaveBlack)(NSString *string);

@interface WCEditProfileViewController : UITableViewController


@property (nonatomic,strong)UITableViewCell *profileCell;

@property (nonatomic,strong) editProfileSaveBlack editSaveBlack;
@end
