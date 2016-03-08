//
//  ZYBaseViewModel.h
//  LogisticsShipper
//
//  Created by lynulzy on 8/26/15.
//  Copyright (c) 2015 leiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSXJHTTPSession.h"
/**
 *  @author lzy, 15-08-26 10:08:18
 *
 *  @brief  业务逻辑成功的回调
 *
 *  @param processResult 结果可以是一个类型，也可是要处理的数据
 */
typedef void (^VMResultBlock) (NSInteger type, id processResult);
/**
 *  @author lzy, 15-08-26 10:08:16
 *
 *  @brief  业务逻辑失败的回调
 *
 *  @param errorInfo 错误码、错误信息
 */
typedef void (^VMErrorBLock) (NSInteger type, id errorInfo);
/**
 *  @author lzy, 15-08-26 10:08:50
 *
 *  @brief  网络请求失败的回调
 *
 *  @param networStatus 网络状态
 */
typedef void (^VMFailureBlock) (NSInteger type, id networStatus);

typedef void (^VMNetworkStatusBlock) (AFNetworkReachabilityStatus status);
@interface ZYBaseViewModel : NSObject

@property (nonatomic, readwrite, copy) VMResultBlock resultBlock;
@property (nonatomic, readwrite, copy) VMErrorBLock errorBlock;
@property (nonatomic, readwrite, copy) VMFailureBlock failedBlock;

@property (nonatomic, readwrite, weak) UIViewController *relatedController;

- (void)setBlocksResutlBlock: (VMResultBlock) theResBlock
            errorBlock: (VMErrorBLock) theErrBlock
          failureBlock: (VMFailureBlock) thefailedBlock;
- (void)monitorNetworkStatus: (VMNetworkStatusBlock) theNetworkBlock;
@end
