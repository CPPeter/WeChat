//
//  JKUploadLoad.h
//  sibu
//
//  Created by DongDong on 15/6/2.
//  Copyright (c) 2015年 com.gzsibu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SiBuSucessBlock)(NSData *stringData,id JSONDict);
typedef void (^SiBuFailureBlock)(NSError *error);
typedef void (^notNetWorkBlock) (NSString *alertMessage);

@interface JKUploadLoad : NSObject

+(void)uploadDict:(NSDictionary *)dict postURL:(NSString *)postURL imgPath:(NSString *)imgPath OK:(SiBuSucessBlock)successBlock Failure:(SiBuFailureBlock)failBlock;

@end
