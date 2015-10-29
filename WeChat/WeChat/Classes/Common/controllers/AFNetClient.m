//
//  AFNetClient.m
//  AFNetClient
//
//  Created by l.h on 14-9-23.
//  Copyright (c) 2014年 sibu. All rights reserved.
//

#import "AFNetClient.h"

@implementation AFNetClient
static double RequestTimeout = 30.0f;
//单例  GCD
+ (instancetype)client
{
    static AFNetClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[AFNetClient alloc]init];
    });
    return client;
}



//get请求  无参数
+ (void)GET_Path:(NSString *)path completed:(HHSuccessBlock )successBlock failed:(HHFailedBlock )faileBlock
{
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //1.获得请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",nil];
    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"text/plain",@"text/html",@"text/json",@"application/json",@"text/css",@"text/javascript",nil];
    manager.requestSerializer.timeoutInterval = RequestTimeout;
    //服务端需要，一般不添加
//    [self setHTTPHeaderFieldValue:manager];
    //3.发送Get请求
  [manager  GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      if (successBlock){
          successBlock(operation.responseData,responseObject);
      }
      
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      if (faileBlock){
          faileBlock(error);
      }
  }];
}

//get同步请求  无参数
//+ (void)GET_Path3:(NSString *)path completed:(HHSuccessBlock )successBlock failed:(HHFailedBlock )failed
//{
//    NSURL *url = [NSURL URLWithString:path];
//    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//}

//get请求  有参数
+(void)GET_Path:(NSString *)path  params:(NSDictionary *)params  completed:(HHSuccessBlock )successBlock failed:(HHFailedBlock )failed
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //1.获得请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //http://www.cocoachina.com/bbs/read.php?tid=176000
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", nil];
    manager.requestSerializer.timeoutInterval = RequestTimeout;

    //服务端需要，一般不添加
//    [self setHTTPHeaderFieldValue:manager];
   [manager  GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       if (successBlock){
           
           successBlock(operation.responseData,responseObject);
       }
       
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       if (failed){
           
           failed(error);
       }
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   }];
}
+(void)GET_Path:(NSString *)path params:(NSDictionary *)params tag:(NSInteger)tag completed:(AFNetRequestSuccessBlock)successBlock failed:(AFNetRequestFailBlock)failed{
    //1.获得请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //http://www.cocoachina.com/bbs/read.php?tid=176000
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css", nil];
    manager.requestSerializer.timeoutInterval = RequestTimeout;
    
    //服务端需要，一般不添加
//    [self setHTTPHeaderFieldValue:manager];
    [manager  GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock){
            
            successBlock(operation.responseData,responseObject,tag);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failed){
            
            failed(error,tag);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


//POST 无参数
+(void)POST_Path:(NSString *)path completed:(HHSuccessBlock)successBlock failed:(HHFailedBlock)failed
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //服务端需要，一般不添加
//    [self setHTTPHeaderFieldValue:manager];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    manager.requestSerializer.timeoutInterval = RequestTimeout;
   [manager  POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       successBlock(operation.responseData,responseObject);
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       if(failed){
           failed(error);
       }
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   }];
}

//POST 无参数
+(void)POST_Path2:(NSString *)path completed:(HHSuccessBlock)successBlock failed:(HHFailedBlock)failed
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:[NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/javascript", nil]];
    
    manager.requestSerializer.timeoutInterval = RequestTimeout;
    //服务端需要，一般不添加
//    [self setHTTPHeaderFieldValue:manager];
    
    [manager  POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        successBlock(operation.responseData,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failed){
            failed(error);
        }
    }];
}


//POST 请求有参数
+(void)POST_Path:(NSString *)path params:(NSDictionary *)paramsDic completed:(HHSuccessBlock)successBlock failed:(HHFailedBlock)failed
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        DLOG(@"AFNetClient-\nAFNethead==%@\n参数==%@",path,paramsDic);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"text/plain",@"text/html",@"text/json",@"application/json",@"text/css",@"text/javascript",nil];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = RequestTimeout;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    //服务端需要，一般不添加
//    [self setHTTPHeaderFieldValue:manager];
    
    [manager  POST:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLOG(@"\nresponseObject==%@",responseObject);
        if (successBlock){
            successBlock(operation.responseData,responseObject);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failed){
            failed(error);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}
+(void)POST_Path:(NSString *)path params:(NSDictionary *)paramsDic tag:(NSInteger)tag completed:(AFNetRequestSuccessBlock)successBlock failed:(AFNetRequestFailBlock)failed{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    DLOG(@"AFNetClient-\nAFNethead==%@\n参数==%@",path,paramsDic);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    //    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"text/plain",@"text/html",@"text/json",@"application/json",@"text/css",@"text/javascript",nil];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = RequestTimeout;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    //服务端需要，一般不添加
//    [self setHTTPHeaderFieldValue:manager];
    
    [manager  POST:path parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLOG(@"\nresponseObject==%@",responseObject);
        if (successBlock){
            successBlock(operation.responseData,responseObject,tag);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failed){
            failed(error,tag);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}
//文件下载
+(void)downloadFile:(NSString *)UrlAddress  completed:(HHSuccessBlock)successBlock failed:(HHFailedBlock)failed  progress:(HHSpeedBlock)progressBlock;
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:UrlAddress]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *pdfName = @"The_PDF_Name_I_Want.pdf";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:pdfName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filepath append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLOG(@"Successfully downloaded file to %@", [NSURL  URLWithString:filepath]);
        successBlock(operation.responseData,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLOG(@"Error: %@", error);
        failed(error);
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float  speed=(float)totalBytesRead / totalBytesExpectedToRead;
        DLOG(@"Download = %f", (float)totalBytesRead / totalBytesExpectedToRead);
        progressBlock(speed);
        
    }];
    [operation start];
}


#pragma mark---服务端需要 一般----
/**
 *  取消当前所有请求,在ViewController的dealloc方法中调用,防止数据请求下来之前vc已经销毁而造成崩溃
 */
+(void)cancelAllRequests {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if (manager.operationQueue.operationCount) {
        //通过queue取消请求
        [manager.operationQueue cancelAllOperations];
    }
}


#pragma mark---------以下一代码封装尚未测试-------
+(void)POST_Path:(NSString *)path arams:(NSDictionary *)paramsDi completed:(HHSuccessBlock)successBlock failed:(HHFailedBlock)failed
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"foo": @"bar"};
    NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
    [manager POST:@"http://example.com/resources.json" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath name:@"image" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLOG(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLOG(@"Error: %@", error);
    }];
}








- (void)dealloc
{
    DLOG(@"line<%d> %s release siglton",__LINE__,__func__);
}

@end
