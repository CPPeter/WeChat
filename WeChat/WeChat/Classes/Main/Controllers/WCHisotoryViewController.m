//
//  WCHisotoryViewController.m
//  WeChat
//
//  Created by apple on 15/10/21.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCHisotoryViewController.h"

@interface WCHisotoryViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation WCHisotoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //监听一个登陆状态的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LoginStatus:) name:WCLoginStatusChangeNotfication object:nil];
}
-(void)LoginStatus:(NSNotification *)notif
{
    //通知是在子线程,要在主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        DLOG(@"user=%@",notif.userInfo);
        DLOG(@"object=%@",notif.object);
        switch ([notif.object integerValue]) {
            case XMPPResultTpyeConnecting:
                //连接中
                [self.indicatorView startAnimating];
                break;
            case XMPPResultTypeLoginfailure:
                //连接断开
                [self.indicatorView stopAnimating];
                break;
            case XMPPResultTypeLoginSuccess:
                //连接成功
                [self.indicatorView stopAnimating];
                break;
            case XMPPResultTypeLoginNEtErr:
                //网络不稳定
                [MBProgressHUD showError:@"网络不稳定,请检查网络" toView:self.view];
                [self.indicatorView stopAnimating];
                break;
            default:
                break;
        }
    });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
