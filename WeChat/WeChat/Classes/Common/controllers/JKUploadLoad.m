//
//  JKUploadLoad.m
//  sibu
//
//  Created by DongDong on 15/6/2.
//  Copyright (c) 2015年 com.gzsibu. All rights reserved.
//

#import "JKUploadLoad.h"

@implementation JKUploadLoad


+(void)uploadDict:(NSDictionary *)dict postURL:(NSString *)postURL imgPath:(NSString *)imgPath OK:(SiBuSucessBlock)successBlock Failure:(SiBuFailureBlock)failBlock
{
    /**
     *  appendPartWithFileURL   //  指定上传的文件
     *  name                    //  指定在服务器中获取对应文件或文本时的key
     *  fileName                //  指定上传文件的原始文件名
     *  mimeType                //  指定商家文件的MIME类型
     *  dict                    //  上传需要的uptype和token(key)
     *  postURL                 //  服务器的postURL
     *  imgPath                 //  本地的imgPath
     */
#pragma mark - AFNetworking上传文件
    NSData  *fileData=[NSData dataWithContentsOfFile:imgPath];  //二进制数据
    NSString *fileName=[imgPath lastPathComponent];             //文件名
    NSString *mimeType=[self getImagePath:imgPath];             //文件类型
    
    if (!mimeType) {
        mimeType = @"application/octet-stream";
    }
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    requestManager.requestSerializer.timeoutInterval=10.f;//请求超时45S
    [requestManager POST:postURL parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //系统自带JSON解析
        NSDictionary *resultJsonDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        successBlock(operation.responseData,resultJsonDic);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
}

+(NSString *)UpLoadImage:(UIImage*)image
{
    //将image转为data
    NSData  *data=UIImagePNGRepresentation(image);
    
    //    时间
    NSDate *  senddate=[NSDate  date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *  morelocationString=[dateformatter stringFromDate:senddate];
    
    
    //沙盒目录
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *appendStr = [NSString stringWithFormat:@"%zd",arc4random()%10000];
    
    //把刚刚图片转换的data对象拷贝至沙盒中并保存为image.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString  stringWithFormat:@"/%@%@.jpg",morelocationString,appendStr]] contents:data attributes:nil];
    
    NSString*   pngFilePath =[NSString  stringWithFormat:@"%@%@.jpg",morelocationString,appendStr];
    
    //    [[NSString alloc]initWithFormat:@"%@/%@.png",DocumentsPath,  morelocationString];
    
    /*由于IOS8 安全机制  返回图片名 取时拼接*/
    //   DLOG(@"--->%@",pngFilePath);
    return pngFilePath;
}

/**
 *  功能-取存取的图片路径
 *  @return 图片地址
 */
+(NSString *)getImagePath:(NSString *)imageName
{
    NSString  *DocmentPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString  *imagePath=[DocmentPaths  stringByAppendingFormat:@"/%@",imageName];
    return   imagePath;
}

/**
 *  功能 获取文件类型
 *  @param path 文件路径
 *  @return MIMEType
 */
-(NSString*)getMIMEType:(NSString *)path
{
    NSError *error;
    NSURLResponse*response;
    NSURLRequest*request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    return [response MIMEType];
}


@end
