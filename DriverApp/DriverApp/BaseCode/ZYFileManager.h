//
//  ZYFileManager.h
//  DriverApp
//
//  Created by lynulzy on 10/23/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "ZYDataBaseManager.h"
@interface ZYFileManager : NSObject
+ (ZYFileManager *)sharedZYFileManager;
- (BOOL)writeFile:(NSString *)fileName dataString:(NSString *)data appending: (BOOL) append;
/**
 *  @author lzy, 15-10-24 22:10:30
 *
 *  @brief  合成将要上传的文件（插入头部信息）
 *
 *  @return 返回文件合成后的完整路径
 */
- (NSString *)generateFileToUpload;

/**
 *  @author lzy, 15-10-25 01:10:43
 *
 *  @brief  写入一条位置信息
 *
 *  @param aLocation 位置信息
 *  @param start     是否是第一个点
 *
 *  @return 写入成功
 */
- (BOOL)writeRecord:(CLLocation *)aLocation start:(BOOL)start;
/**
 *  @author lzy, 15-10-25 14:10:52
 *
 *  @brief  对一个已有文件重命名(准备上传)
 *
 *  @param path     原来的路径
 *  @param fileName 原来的文件名
 *  @param newName  新的文件名
 *
 *  @return 更名后的文件地址
 */
- (NSString *)renameFile:(NSString *)path fileName:(NSString *)fileName newFileName:(NSString *)newName;
//- (void)testDES:(NSString *)path;
@end
