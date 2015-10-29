    //
//  AFNetClient.h
//  AFNetClient
//
//  Created by l.h on 14-9-23.
//  Copyright (c) 2014年 sibu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

extern NSString *const kAPI_BASE_URL;


/**
 @ Copyright (c) 2014年 gzsibu. All rights reserved.
 @ AFNetClient 请求回调的块声明；
 @ 2014.9 基本的Get,Post 请求完成 Block回调；
 @
 */
typedef void (^AFNetRequestSuccessBlock)(NSData *strData,id JSONDict,NSInteger tag);
typedef void (^AFNetRequestFailBlock)(NSError *error,NSInteger tag);
typedef void (^HHSuccessBlock)(NSData *stringData,id JSONDict);
typedef void (^HHFailedBlock)(NSError *error);
typedef void (^HHSpeedBlock)(float  progress);

@interface AFNetClient : NSObject


/*请求客户端*/
+ (instancetype)client;


/**
  @       get  请求
  @param  path=nil  无参数
 */
+ (void)GET_Path:(NSString *)path completed:(HHSuccessBlock )successBlock failed:(HHFailedBlock )failed;


/**
 @       get  请求 
 @param  path  有参数
 */
+ (void)GET_Path:(NSString *)path  params:(NSDictionary *)params  completed:(HHSuccessBlock )successBlock failed:(HHFailedBlock )failed;
/**
 *  get请求带标签
 *
 */
+ (void)GET_Path:(NSString *)path params:(NSDictionary *)params tag:(NSInteger)tag completed:(AFNetRequestSuccessBlock)successBlock failed:(AFNetRequestFailBlock)failed;

+ (void)POST_Path2:(NSString *)path completed:(HHSuccessBlock )successBlock failed:(HHFailedBlock )failed;


/**
 @          POST  请求 无参数
 @param     无参数
 */
+ (void)POST_Path:(NSString *)path completed:(HHSuccessBlock )successBlock failed:(HHFailedBlock )failed;


/**
 @          POST  请求  有参数
 @param     有参数
 */
+ (void)POST_Path:(NSString *)path params:(NSDictionary *)paramsDic completed:(HHSuccessBlock )successBlock failed:(HHFailedBlock )failed;

/**
 *  POST 请求 带tag标签
 *
 *  @param path         url
 *  @param paramsDic    参数
 *  @param tag          tag标签
 *  @param successBlock 成功回调
 *  @param failed       失败回调
 */
+ (void)POST_Path:(NSString *)path params:(NSDictionary *)paramsDic tag:(NSInteger)tag completed:(AFNetRequestSuccessBlock )successBlock failed:(AFNetRequestFailBlock )failed;


/**
 *  取消所有网络请求
 */
+(void)cancelAllRequests;


/**
 @          文件下载
 @param     HHSpeedBlock  下载进度
 @param     下载进度建议用SVProgressHUD显示
 */
+(void)downloadFile:(NSString *)UrlAddress  completed:(HHSuccessBlock)successBlock failed:(HHFailedBlock)failed  progress:(HHSpeedBlock)progressBlock;

//================================================

//+(void)POST_Path:(NSString *)path arams:(NSDictionary *)paramsDi completed:(HHSuccessBlock)successBlock failed:(HHFailedBlock)failed;

/**
 官方文档:  http://cocoadocs.org/docsets/AFNetworking/2.4.0/
 Github:   https://github.com/AFNetworking/AFNetworking/
 
 */

@end
