//
//  WCContactsViewController.m
//  WeChat
//
//  Created by apple on 15/10/16.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCContactsViewController.h"
#import "WCChatIViewController.h"

@interface WCContactsViewController ()<NSFetchedResultsControllerDelegate>
{
    NSManagedObjectContext              *_context;//上下文
    NSFetchedResultsController          *_resultsCtl;
    
}
@property (nonatomic,strong)NSArray *friends;
@end
@implementation WCContactsViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //从数据库里加载好友列表显示
    [self loadFriends2];
    
    //添加监听查看消息的监听者,一旦有消息就进入响应的好友的聊天界面
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(chackMessage:) name:WCCheckMessageNotfication object:nil];
    
}
-(void)loadFriends2
{
    //如何使用CoreData获取数据
    //1.上下文[关联到数据XMPPRoster];
    _context = [WCXMPPTool sharedWCXMPPTool].resterStorage.mainThreadManagedObjectContext;
    
    //2.FetchRequest[查哪张表]
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //3.设置过虐和排序
    //过滤当前登陆用户的好友
    NSString *jid = [WCUserInfo sharedWCUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jid];
    request.predicate = pre;
    
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    request.sortDescriptors = @[sort];
    
    //4,执行请求获取数据
    NSError *error = nil;
    
    _resultsCtl = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil];
    _resultsCtl.delegate = self;
    [_resultsCtl performFetch:&error];
    
//    self.friends = [_context executeFetchRequest:request error:&error];
    if (error) {
        DLOG(@"error=%@",error);
    }
    else
    {
        DLOG(@"friends= %@",_resultsCtl);
    }
}
-(void)loadFriends
{
    //如何使用CoreData获取数据
    //1.上下文[关联到数据XMPPRoster];
   _context = [WCXMPPTool sharedWCXMPPTool].resterStorage.mainThreadManagedObjectContext;
    
    //2.FetchRequest[查哪张表]
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //3.设置过虐和排序
    //过滤当前登陆用户的好友
    NSString *jid = [WCUserInfo sharedWCUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jid];
    request.predicate = pre;
    
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    request.sortDescriptors = @[sort];
    
    //4,执行请求获取数据
    NSError *error = nil;
   self.friends = [_context executeFetchRequest:request error:&error];
    if (error) {
        DLOG(@"error=%@",error);
    }
    else
    {
        DLOG(@"friends= %@",self.friends);
    }
}
#pragma mark "查看消息" 通知的响应
-(void)chackMessage:(NSNotification *)notif
{
    NSString *object = notif.object;
    NSRange range = [object rangeOfString:@"/"];
    NSString *jidStr = [object substringToIndex:range.location];
    DLOG(@"jidStr = %@",jidStr);
    for (int i = 0; i < _resultsCtl.fetchedObjects.count; i++) {
        XMPPUserCoreDataStorageObject *friend = _resultsCtl.fetchedObjects[i];
        if ([friend.jidStr isEqualToString:jidStr]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            return ;
        }
    }
}

#pragma mark NSFetchedResultsControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DLOG(@"数据发生改变");
    [self.tableView reloadData];
}
#pragma mark UITableViewDAtaSource和UITableViewDatagate的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _resultsCtl.fetchedObjects.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"ContactsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:ID];
    }
    //获取对应好友
    XMPPUserCoreDataStorageObject *friend  = _resultsCtl.fetchedObjects[indexPath.row];
    cell.textLabel.text = friend.jidStr;
    
//    sectionNu m
//    "0" - 在线
//    "1" - 离开
//    "2" - 离线
    
    int sectionNum = [friend.sectionNum intValue];
    switch (sectionNum) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
        default:
            break;
    }
    
    return cell;
}
//实现编辑删除的方法
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *friend  = _resultsCtl.fetchedObjects[indexPath.row];
        [[WCXMPPTool sharedWCXMPPTool].roster removeUser:friend.jid];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //选中表格进入聊天界面
    XMPPUserCoreDataStorageObject *friend  = _resultsCtl.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"ChatSegue" sender:friend];
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destCtl = segue.destinationViewController;
    if ([destCtl isKindOfClass:[WCChatIViewController class]]) {
        WCChatIViewController *chatCtl = destCtl;
        chatCtl.friendData = sender;
    }
}
@end
