//
//  RecordModel.h
//  DriverApp
//
//  Created by lynulzy on 10/24/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordModel : NSObject

/*
 NSInteger userID = [[ZSXJUserDefaults getCurrentUserID] integerValue];
 //TODO: 计算距离
 NSInteger distance = 10000;
 NSInteger startTime = [[NSDate date] timeIntervalSince1970];
 //TODO: 结束时间
 NSInteger endTime = 0;
 NSInteger totalTime = endTime > startTime ? endTime - startTime : 0;
 NSInteger remain = [[ZSXJUserDefaults getRemainTime] integerValue];
 if (remain > 0) {
 //TODO: 记录等待时间
 remain = remain +1;
 }
 NSString *carNum = [ZSXJUserDefaults getCarNumber];
 NSString *loginName = [ZSXJUserDefaults getLoginName];
 NSString *loginPwd = [ZSXJUserDefaults getLoginPwd];
 //TODO: 路径id
 NSString *UUDI = [UDID stringByAppendingString:@"routeid"];
 float averageSpeed;
 if (totalTime == 0 || distance == 0) {
 averageSpeed = 0.0;
 }else {
 averageSpeed =  distance/(totalTime/3600);
 }
 
 float topSpeed = 80.01;
 //TODO: 是否上传过
 Boolean upload = NO;*/
@property (nonatomic,assign) NSInteger recordID;
@property (nonatomic,assign) NSInteger userID;
@property (nonatomic,assign) float distance;
@property (nonatomic,assign) NSInteger startTime;
@property (nonatomic,assign) NSInteger endTime;
@property (nonatomic,assign) NSInteger totalTime;
@property (nonatomic,assign) NSInteger remain;
@property (nonatomic, copy)NSString *carNum;
@property (nonatomic, copy)NSString *uuid;
@property (nonatomic, assign)float averageSpeed;
@property (nonatomic, assign)float topSpeed;
@property (nonatomic, assign) BOOL uploaded;

@end
