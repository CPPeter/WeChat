//
//  WCEditProfileViewController.m
//  WeChat
//
//  Created by apple on 15/10/15.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCEditProfileViewController.h"
#import "XMPPvCardTemp.h"

@interface WCEditProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFiled;

@end

@implementation WCEditProfileViewController
- (IBAction)saveBarAction:(id)sender {
    if (self.textFiled.text.length) {
        //1.更改cell的detailTextLabel 的Text
        self.profileCell.detailTextLabel.text = self.textFiled.text;
        [self.profileCell layoutSubviews];
        
        self.editSaveBlack(self.textFiled.text);
        
        //2.当前的控制器消失
        [self.navigationController popViewControllerAnimated:YES];
    
        
    }else
    {
    
    }
    
    
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //这是标题和textFiled的默认值
    self.title = self.profileCell.textLabel.text;
    self.textFiled.text = self.profileCell.detailTextLabel.text;
}
-(void)dealloc
{
    DLOG(@"销毁");
}
@end
