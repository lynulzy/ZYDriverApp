//
//  ZSXJHTTPSession.m
//  AFTestDemo
//
//  Created by lynulzy on 8/21/15.
//  Copyright (c) 2015 ZSXJ. All rights reserved.
//

#import "ZSXJHTTPSession.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworking.h"
#import "HTTPHelper.h"
#import "DESUtils.h"
#import "ZYFileManager.h"
@interface ZSXJHTTPSession()
@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

@implementation ZSXJHTTPSession
static NSString *serverURL = @"http://114.215.176.234:8080";
@synthesize actIndicator;
@synthesize sessionManager;
+ (ZSXJHTTPSession *)sharedSession {
    static ZSXJHTTPSession *shareaSession = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareaSession = [[ZSXJHTTPSession alloc] initWithBaseURL:[NSURL URLWithString:serverURL]
                                            sessionConfiguration:nil];
    });
    return shareaSession;
}
-(instancetype)initWithBaseURL: (NSURL *) url sessionConfiguration: (NSURLSessionConfiguration *) configuration {
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (self) {
        sessionManager = [AFHTTPSessionManager manager];
        actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //TODO  此处添加提示（全局通知），当网络状况发生改变的时候告知用户
        __weak typeof (self) weakSelf = self;
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            __strong typeof (weakSelf) strongSelf = weakSelf;
            if (strongSelf.networkChangeBlock) {
                strongSelf.networkChangeBlock(status);
            }
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable: {
                    //网络不可用
                    [strongSelf.operationQueue setSuspended:YES];
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWWAN: {
                    //手机网络
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    //wifi
                    break;
                }
                default:
                    [strongSelf.operationQueue setSuspended:NO];
                    break;
            }
        }];
        [self.reachabilityManager startMonitoring];
    }
    return self;
}
- (void)POST: (NSString *) actStr ReqParams: (NSDictionary *) params success: (SuccessBlock) succBlc failure: (FailedBlcok) failBlc {
    //Show network indicator in status bar.
    AFNetworkActivityIndicatorManager *indicatorManager = [AFNetworkActivityIndicatorManager sharedManager];
    indicatorManager.enabled = YES;
    [indicatorManager incrementActivityCount];
    
    //Contruct the post Params
    NSDictionary *postData = [[[HTTPHelper alloc] init] constructPOSTDict:params
                                                                 actParam:actStr];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSString *postURL = _userDefineServerURL ? _userDefineServerURL : serverURL;
    [sessionManager POST:postURL
       parameters:postData
          success:^(NSURLSessionDataTask *task, id responseObject) {
              [indicatorManager decrementActivityCount];
              succBlc(task,responseObject);
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              [indicatorManager decrementActivityCount];
              failBlc(task,error);
          }];
}
//Method 1
- (void)uploadImage: (NSDictionary *) imgDict
              byAct: (NSString *) theAct
          ReqParams: (NSDictionary *) params
            success: (SuccessBlock) succBlc
            failure: (FailedBlcok) failBlc {
        //上传图片
    NSDictionary *postData = [[[HTTPHelper alloc] init] constructPOSTDict:params
                                                                 actParam:theAct];
    
    NSString *postURL = _userDefineServerURL ? _userDefineServerURL : serverURL;
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [sessionManager POST:postURL
              parameters:postData
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (NSString *key in imgDict) {
            NSInputStream *stream = [[NSInputStream alloc] initWithData:imgDict[key]];
            [formData appendPartWithInputStream:stream
                                           name:key
                                       fileName:[NSString stringWithFormat:@"%@.jpg",key]
                                         length:[(NSData *)imgDict[key] length]
                                       mimeType:@"image/jpg"];
        }
    }
                 success:^(NSURLSessionDataTask *task, id responseObject) {
                     succBlc(task, responseObject);
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                     failBlc(task, error);
                 }];
}
//Method 2
- (void)monitorUploadImage:(NSDictionary *)imgDict
                     byAct:(NSString *)theAct
                 ReqParams:(NSDictionary *)params
           monitorProgress:(MonitorProgressBlock)monitorBlock
                  progress:(NSProgress *)theProgress
                   success:(SuccessBlock)succBlc
                   failure:(FailedBlcok)failBlc {
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //使用NSURLRequest发送请求
    [sessionManager setTaskDidSendBodyDataBlock:monitorBlock];
    
    
    
    NSDictionary *postData = [[[HTTPHelper alloc] init] constructPOSTDict:params
                                                                 actParam:theAct];
    NSString *postURL = _userDefineServerURL ? _userDefineServerURL : serverURL;
    
    NSError *postErr = nil;
    
    //构造附带图片上传的POST请求
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]
                                    multipartFormRequestWithMethod:@"POST"
                                    URLString:postURL
                                    parameters:postData
                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                                 for (NSString *key in imgDict) {
                                                                                                     NSInputStream *stream = [[NSInputStream alloc] initWithData:imgDict[key]];
                                                                                                     [formData appendPartWithInputStream:stream
                                                                                                                                    name:key
                                                                                                                                fileName:[NSString stringWithFormat:@"%@.jpg",key]
                                                                                                                                  length:[(NSData *)imgDict[key] length]
                                                                                                                                mimeType:@"image/jpg"];
                                                                                                 }
                                                                                             }
                                    error:&postErr];
    
    //以流的形式上传数据
    NSURLSessionDataTask *uploadTask = [sessionManager uploadTaskWithStreamedRequest:request
                                                                            progress:&theProgress
                                                                   completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                                       if (!error) {
                                                                           //upload Success
                                                                           succBlc(uploadTask, responseObject);
                                                                       }
                                                                       else {
                                                                           //upload failure
                                                                           failBlc(uploadTask, error);
                                                                       }
                                                                   }];
    [uploadTask resume];
    [theProgress addObserver:self
                  forKeyPath:@"fractionCompleted"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        DDLog(@"***%lld /  %lld***", progress.completedUnitCount, progress.totalUnitCount);
    }
}
- (void)uploadFileData:(NSData *)fileData filname:(NSString *)uploadFileName URL:(NSString *)serverURL success:(SuccessBlock)succBlc failure:(FailedBlcok)failBlc {
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    [requestManager POST:serverURL
              parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    //    NSData *data = [NSData dataWithContentsOfFile:path];
    //    [formData appendPartWithFileURL:fileURL name:@"file" fileName:@"fileName" mimeType:@"text/plain" error:nil];
//    DDLog(@"string %@ ", [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]);
//    NSData *fileData = [DESUtils dataEncryptUseDES:path key:@"abc"];
//    NSData *testDes = [DESUtils dataEncryptUseDES:path key:@""];
//    DDLog(@"DESSTRING1 %@", [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding]);
//    DDLog(@"DESSTRING2 %@", [[NSString alloc] initWithData:testDes encoding:NSUTF8StringEncoding]);
    [formData appendPartWithFileData:fileData name:@"file" fileName:uploadFileName mimeType:@"text/plain"];
}
                 success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                     NSString *errorCode = responseObject[@"errorcode"];
                     if ([errorCode isEqualToString:@"1"]) {
                         succBlc(nil, responseObject[@"errormsg"]);
                     }
                     else {
                         NSError *err = [NSError errorWithDomain:@"Upload" code:0 userInfo:@{@"msg":responseObject[@"errormsg"]}];
                         failBlc(nil, err);
                     }
                     DDLog(@"success %@",responseObject);
                 } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                     DDLog(@"%@",error);
                     failBlc(nil, error);
                 }];

}
- (void)uploadFile:(NSString *)path fileName:(NSString *)uploadfileName URL:(NSString *)serverURL success:(SuccessBlock)succBlc failure:(FailedBlcok)failBlc {
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    [requestManager POST:serverURL
              parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    [formData appendPartWithFileURL:fileURL name:@"file" fileName:@"fileName" mimeType:@"text/plain" error:nil];
    DDLog(@"string %@ ", [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]);
    NSData *fileData = [DESUtils dataEncryptUseDES:path key:@"abc"];
    //test
    NSData *testDes = [DESUtils dataEncryptUseDES:path key:@""];
    DDLog(@"DESSTRING1 %@", [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding]);
    DDLog(@"DESSTRING2 %@", [[NSString alloc] initWithData:testDes encoding:NSUTF8StringEncoding]);
    [formData appendPartWithFileData:fileData name:@"file" fileName:uploadfileName mimeType:@"text/plain"];
}
                 success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                     NSString *errorCode = responseObject[@"errorcode"];
                     if ([errorCode isEqualToString:@"1"]) {
                         succBlc(nil, responseObject[@"errormsg"]);
                     }
                     else {
                         NSError *err = [NSError errorWithDomain:@"Upload" code:0 userInfo:@{@"msg":responseObject[@"errormsg"]}];
                         failBlc(nil, err);
                     }
                     DDLog(@"success %@",responseObject);
                 } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                     DDLog(@"%@",error);
                     failBlc(nil, error);
                 }];
}
@end
