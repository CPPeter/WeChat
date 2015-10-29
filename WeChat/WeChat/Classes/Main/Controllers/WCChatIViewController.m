//
//  WCChatIViewController.m
//  WeChat
//
//  Created by apple on 15/10/19.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCChatIViewController.h"
#import "WCInputIVew.h"
#import "JKUploadLoad.h"
#import "UIImageView+WebCache.h"
#import "WCChatTableViewCell.h"



//资源服务器 上传 版本V1
#define ResourcesServerUrl_Upload @"http://resources.sibu.cn/v1/upload/file/save"
///*资源服务器 获取验证码 版本V1*/
#define ResourcesServerUrl_Auth @"http://resources.sibu.cn/v1/auth"
#define ImageKey @"imageKey"

@interface WCChatIViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    NSFetchedResultsController *_resultsContr;
    UITableView                *_tableView;
    NSArray                    *_constraints;
}
@property (nonatomic,strong)NSLayoutConstraint *inputviewHeghtConstraint;//inputView高度约束
@property (nonatomic,strong)NSLayoutConstraint *inputViewButtomConstraint;//inputView底部约束
@property (nonatomic,strong)WCInputIVew *inputView;
@end
@implementation WCChatIViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //代码实现布局
    [self setupView];
    //加载数据
    [self loadMsgs];
    
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //添加键盘回收手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tap];
    //表格滚动到底部
    [self scrollTotabelBottom];
}
-(void)tapGesture:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}
//-(void)kbFrmWillhide:(NSNotification *)noti{
//
//    self.inputViewConstraint.constant = 0;
//    [self.inputView.textView canBecomeFirstResponder];
//}

-(void)kbFrmWillChange:(NSNotification *)noti{
    NSLog(@"%@",noti.userInfo);
    
    // 获取窗口的高度  
    CGFloat windowH = [UIScreen mainScreen].bounds.size.height;

    // 键盘结束的Frm
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘结束的y值
    CGFloat kbEndY = kbEndFrm.origin.y;
   CGRect frame = _tableView.frame;
    if (kbEndY == windowH) {
        frame.size.height = windowH - 50;
    }
    else
    {
        frame.size.height = windowH - kbEndY - 50;
    }
//    _tableView.frame = frame;
    self.inputViewButtomConstraint.constant = windowH - kbEndY;
    DLOG(@"rect = %@",NSStringFromCGRect(_tableView.frame));
    DLOG(@"size = %@",NSStringFromCGSize(_tableView.contentSize));
    //表格滚动到底部
    [self scrollTotabelBottom];
}
-(void)setupView
{
    //代码实现布局 VFL
    //创建爱你一个tableIVew;
    UITableView *tableView = [[UITableView alloc]init];
#warning    //代码实现自动布局,要设置下面的属性为NO
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //创建输入框
    WCInputIVew *inputView = [WCInputIVew inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.textView.delegate = self;
    [self.view addSubview:inputView];
    self.inputView  = inputView;
    //添加按钮事件
    [self.inputView.addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //自动布局
    
    //水平方向的约束
    //1.tablView 水平方向的约束
    NSDictionary *views = @{@"tableview":tableView,@"inputView":inputView};
    
    NSArray *tableviewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableview]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableviewHConstraints];
    
    //2.inputView 水平方向的约束
    NSArray *inputViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHConstraints];
    //垂直方向的约束
    
    NSArray *vContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableview]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:vContraints];
    //inputview相对于底部的距离约束
    self.inputViewButtomConstraint = [vContraints lastObject];
    //添加inputview 的高度约束
    self.inputviewHeghtConstraint = vContraints[2];
    DLOG(@"vcontraints =%@",vContraints);
    _constraints = vContraints;
}
#pragma mark 加载XMPPMessageArchiving数据库的数据显示在表格
-(void)loadMsgs
{
    //上下文
    NSManagedObjectContext *context = [WCXMPPTool sharedWCXMPPTool].messageStorage.mainThreadManagedObjectContext;
    //请求对象
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //过滤,排序
    //1.当前登录用户的jid的消息
    //2.好友的jidde 消息
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[WCUserInfo sharedWCUserInfo].jid,self.friendData.jidStr];
    //时间升序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    request.predicate = pre;

    //查询
    _resultsContr = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultsContr.delegate = self;
    
    NSError *error = nil;
    [_resultsContr performFetch:&error];
    if (error) {
        DLOG(@"error=%@",error);
    }
}
#pragma mark NSFetchedResultsControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DLOG(@"有新的消息controller=%@",controller);
    [_tableView reloadData];
    [self scrollTotabelBottom];
}

#pragma mark UITableViewDAtaSource和UITableViewDatagate的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _resultsContr.fetchedObjects.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"chatCell";
    WCChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[WCChatTableViewCell alloc]initWithStyle:0 reuseIdentifier:ID];
        cell.selectionStyle = 0;
    }
    XMPPMessageArchiving_Message_CoreDataObject *msg = _resultsContr.fetchedObjects[indexPath.row];
    //判断是图片还是纯文本
   NSString *chatType = [msg.message attributeStringValueForName:@"bodyType"];
    if ([chatType isEqualToString:@"image"]) {
        //下载图片
        [cell.messageImg sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"DefaultProfileHead_qq"]];
        cell.messageImg.hidden = NO;
        cell.messageText.hidden = YES;
    }
    else //if ([chatType isEqualToString:@"text"])
    {//纯文本
        cell.messageText.text = msg.body;
        cell.messageImg.hidden = YES;
        cell.messageText.hidden = NO;
         DLOG(@"body=%@",msg.body);
    }
    cell.isoutgoing = [msg.outgoing boolValue];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}
-(CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    //获取contensize
    CGFloat contentH = textView.contentSize.height;
    DLOG(@"textview=%f",contentH);
    //大于33就是操过一行的高度
    if(contentH > 33 && contentH < 68)
    {
        self.inputviewHeghtConstraint.constant = contentH + 18;
    }
    
    
    NSString *text = textView.text;
    //换行就等于点击了send
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        DLOG(@"发送数据");
        
        //去除换行字符
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //发送数据
        [self sendMsgWithText:text messageType:@"text"];

        //清空数据
        textView.text = @"";
        self.inputviewHeghtConstraint.constant = 50;
    }
    else
    {
        DLOG(@"textview=%@",text);
    }
}
#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    if (buttonIndex == 0) {
        //打开相册
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if (buttonIndex == 1)
    {
        //照相
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        return ;
    }
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    //获取上传图片的token
    [AFNetClient POST_Path:ResourcesServerUrl_Auth params:@{@"type":@0} completed:^(NSData *stringData, id JSONDict) {
        if ([JSONDict[@"success"] isEqualToNumber:@1]) {
            //保存token success
            [[NSUserDefaults standardUserDefaults] setObject:JSONDict[@"key"] forKey:ImageKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    } failed:^(NSError *error) {
        DLOG(@"error==%@",error);
    }];
}
-(NSString *)saveImage:(UIImage *)image withName:(NSString *)imageName
{
    __block NSData *imageData = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *fullPathToFile = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",imageName]];
    BOOL result = [fileManager fileExistsAtPath:fullPathToFile];
    if (!result) {
        [imageData writeToFile:fullPathToFile atomically:NO];
    }
    return fullPathToFile;
}
#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker photoFromImagePickerView:(UIImage *)photo imagePath:(NSString *)imagePath
{
//    NSString *imagePath = @"/var/mobile/Containers/Data/Application/669DD781-72AA-4A29-8E7A-C08809B711E4/Documents/IMG_1539.JPG";
#warning //这个key去手思的健康里面去上传头像的时候取
    NSString *headKey = [[NSUserDefaults standardUserDefaults]objectForKey:ImageKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (headKey.length != 0 || headKey != nil) {
        NSDictionary *dc = @{@"uptype":@0,@"level":@1,@"key":headKey};
        [JKUploadLoad uploadDict:dc postURL:ResourcesServerUrl_Upload imgPath:imagePath OK:^(NSData *stringData, id JSONDict) {
            NSLog(@"---%@",JSONDict);
            if ([JSONDict[@"success"] isEqualToNumber:@1]) {
                DLOG(@"上传成功");
                //图片发送成功,把图片的URL传给Openfire的服务
                NSString *localImgPath = JSONDict[@"data"][@"path"];
                [self sendMsgWithText:localImgPath messageType:@"image"];
            }
        } Failure:^(NSError *error) {
            NSLog(@"error=%@",error);
        }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    DLOG(@"info= %@",info);
    //获取图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    //把图片发送到文件服务器
    //http post put
    /**
        *put实现文件上传没有post那么繁琐,而且比Post块
     *put的上传路劲就是下载路径
     */
    //文件上传路径 http:localHost:8080/imfileserver/Upload/Image/ +"图片名[程序员自己定义]"
    //文件名 用户名 + 时间(年月日时分秒)
    
//    NSString *user = [WCUserInfo sharedWCUserInfo].user;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
//    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
//    NSString *imagePath = [user stringByAppendingString:timeStr];
//    image = [self fixOrientation:[info objectForKey:UIImagePickerControllerEditedImage]];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    __block UIImage *image = nil;
    __block NSData *imgData = nil;
    imgData = UIImageJPEGRepresentation(image, 1.0f);
    [library writeImageDataToSavedPhotosAlbum:imgData metadata:[info valueForKey:UIImagePickerControllerMediaMetadata] completionBlock:^(NSURL *assetURL, NSError *error) {
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset){
//            UIImage *nowImg = [self sizeImage:image toSize:CGSizeMake(50, 50)];
            NSString *path = [self saveImage:image withName:asset.defaultRepresentation.filename];
            [self imagePickerController:picker photoFromImagePickerView:image imagePath:path];
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self removeFromSuperview];
            });
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }failureBlock:^(NSError *error){
            NSLog(@"error:%@",error);
        }];
    }];
    
}
#pragma mark 发送聊天消息
-(void)sendMsgWithText:(NSString *)text messageType:(NSString *)bodyType
{
    //发送消息
    [[WCXMPPTool sharedWCXMPPTool]sendMessage:text bodyType:bodyType friendJid:self.friendData.jid];
}
#pragma mark 滚动到底部
-(void)scrollTotabelBottom
{
    NSInteger lastRow = _resultsContr.fetchedObjects.count - 1;
    if(lastRow>0)
    {
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
        [_tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}
#pragma mark 选择图片
-(void)addBtnAction:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"照相", nil];
    [sheet showInView:self.view];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    DLOG(@"销毁");
}
@end
