//
//  ZYBaseViewModel.m
//  LogisticsShipper
//
//  Created by lynulzy on 8/26/15.
//  Copyright (c) 2015 leiyang. All rights reserved.
//

#import "ZYBaseViewModel.h"

@implementation ZYBaseViewModel

- (void)setBlocksResutlBlock:(VMResultBlock)theResBlock
                  errorBlock:(VMErrorBLock)theErrBlock
                failureBlock:(VMFailureBlock)thefailedBlock {
    _resultBlock = theResBlock;
    _errorBlock  = theErrBlock;
    _failedBlock = thefailedBlock;
}
- (void)monitorNetworkStatus:(VMNetworkStatusBlock)theNetworkBlock {
    ZSXJHTTPSession *sessionmanager = [ZSXJHTTPSession sharedSession];
    sessionmanager.networkChangeBlock = theNetworkBlock;
}


@end
