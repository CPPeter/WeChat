//
//  WCProfileViewController.m
//  WeChat
//
//  Created by apple on 15/10/8.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "WCEditProfileViewController.h"


@interface WCProfileViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    
}
@property (nonatomic,strong) UIImagePickerController *imagePicker;

/**
 头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *herderImg;
/**
 昵称
 */
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
/**
 微信号
 */
@property (weak, nonatomic) IBOutlet UILabel *weixinNumLabel;

/**
 公司名
 */
@property (weak, nonatomic) IBOutlet UILabel *orgnameLabel;
/**
 部门
 */
@property (weak, nonatomic) IBOutlet UILabel *orunitLabel;
/**
 职位
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/**
 电话
 */
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
/**
 邮件
 */
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


@end
@implementation WCProfileViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"个人信息";
    [self loadVCard];
}
#pragma mark 加载电子名片信息
-(void)loadVCard
{
    //xmpp提供了一个方法,直接获取个人信息
    XMPPvCardTemp *myVcTemp = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    //设置头像
    if (myVcTemp.photo) {
        self.herderImg.image = [ UIImage imageWithData:myVcTemp.photo];
    }
    
    //设置昵称
        self.nickNameLabel.text = myVcTemp.nickname;
    //设置微信号
    self.weixinNumLabel.text = [WCUserInfo sharedWCUserInfo].user;
    
        self.orgnameLabel .text = myVcTemp.orgName;
        self.orunitLabel.text = [myVcTemp.orgUnits firstObject];
    self.titleLabel.text = myVcTemp.title;
#warning myVcTemp.telecomsAddresses这个get方法,没有对电子名片的xml数据进行解析
    //使用note字段充当电话
    
        self.telLabel.text = myVcTemp.note;
#warning myVcTemp.emailAddresses这个get方法,没有对电子名片的xml数据进行解析
    //用mailer充当邮件
//        self.emailLabel.text = myVcTemp.mailer;
    
    //自己解析电子邮件
    if (myVcTemp.emailAddresses) {
        self.emailLabel.text = [myVcTemp.emailAddresses lastObject];
    }
    
}
#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 1)
    {
       
        
        //跳到下一个控制器
        [self performSegueWithIdentifier:@"EditVCardSegue" sender:cell];
        
        
    }else if (cell.tag == 2)
    {
      //表示点击的是微信号,不做任何操作
        return ;
    }
    else if(cell.tag == 0)
    {
        //选择图片
        UIActionSheet * sheet = [[UIActionSheet alloc]initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"相册", nil];
        [sheet showInView:self.view];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取编辑个人信息的控制器
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[WCEditProfileViewController class]]) {
        WCEditProfileViewController *editCtl = destVc;
        editCtl.profileCell = sender;
        typeof(self) weakSelf = self;
        //编辑个人信息的保存
        editCtl.editSaveBlack = ^(NSString *string)
        {
            //更新到服务器
            [weakSelf xmppTempUpdate];
        };
    }
}
#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLOG(@"------%d",buttonIndex);
    UIImagePickerController *imagePicer = [[UIImagePickerController alloc]init];
    //要设置代理
    imagePicer.delegate = self;
    //设置允许编辑状态
    imagePicer.allowsEditing = YES;
    DLOG(@"queue=%@",[NSThread currentThread]);
    if (buttonIndex == 0)
    {
        //打开照相
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
        imagePicer.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if (buttonIndex == 1)
    {
        //打开相册
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary ]) {
            imagePicer.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    else
    {
        return ;
    }
    self.imagePicker = imagePicer;
    DLOG(@"queue=%@",[NSThread currentThread]);
    //显示图片选择器
#warning ipod无法弹出相册解决办法(ios在8.0以后更改了UIActionSheet的继承父类,原因在警告里说得比较明白了，因为已经有actionsheet存在了，不能present新的。此时我们选择新的委托方法)
    //方法1
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self presentViewController:imagePicer animated:YES completion:nil];

}];
    
    //方法2
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self presentViewController:imagePicer animated:YES completion:nil];
//    });
    
}
//方法3
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    DLOG(@"buttonIndex=%d",buttonIndex);
//    [self presentViewController:self.imagePicker animated:YES completion:nil];
}
#pragma mark 图片选择器的代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    DLOG(@"info =%@",info);
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.herderImg.image = image;
    //隐藏当前的模态窗口
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //更新到服务器
    [self xmppTempUpdate];

}
-(void)xmppTempUpdate
{
    //获取当前的电子名片信息
    XMPPvCardTemp *vCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    //昵称
    vCard.nickname = self.nickNameLabel.text;
    //公司
    vCard.orgName = self.orgnameLabel.text;
    //头像
    vCard.photo = UIImagePNGRepresentation(self.herderImg.image);
    
    //部门
    if (self.orgnameLabel.text.length > 0) {
        vCard.orgUnits = @[self.orunitLabel.text];
    }
    //职位
    vCard.title = self.titleLabel.text;
    
    //电话
    vCard.note = self.telLabel.text;
    
    //邮件
    if (self.emailLabel.text.length > 0) {
        
    }
    vCard.emailAddresses = @[self.emailLabel.text];
    
    //更新 这个方法内部会实现数据上传的服务器,不需程序自己炒作
    [[WCXMPPTool sharedWCXMPPTool].vCard updateMyvCardTemp:vCard];
}
-(void)dealloc
{
    DLOG(@"销毁");
}

@end
