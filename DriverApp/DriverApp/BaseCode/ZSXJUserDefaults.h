//
//  ZSXJUserDefaults.h
//  LogisticsShipper
//
//  Created by lynulzy on 9/1/15.
//  Copyright (c) 2015 leiyang. All rights reserved.
//
/**
 *  @author lzy, 15-09-01 11:09:04
 *
 *  @brief  用来存储用户的默认数据
 */
#import <Foundation/Foundation.h>
@interface ZSXJUserDefaults : NSObject

#define  USER_DEFAULTS_CURRENT_USERID           @"current_user_id"
#define  USER_DEFAULTS_LAST_USER_PHONE          @"last_user_phone_number"
#define  USER_DEFAULTS_CAR_NUMBER               @"car_number"
#define  USER_DEFAULTS_CURRENT_ROUTE            @"current_route_id"  //!< 当前的路径id
#define  USER_DEFAULTS_REMAIN_TIME              @"driver_remain_time"
#define  USER_DEFAULTS_LOGINNAME                @"user_login_name"
#define  USER_DEFAULTS_LOGINPWD                  @"user_login_pwd"
#define  USER_DEFAULTS_ROUTE_STATUS              @"route_status"//行驶中、暂停两种状态
#define  USER_DEFAULTS_SUSPEND_TIME              @"tracking_suspend_time"//
#define  USER_DEFAULTS_START_DATE                @"start_tracking_date"//记录开始的时间
#define  USER_DEFAULTS_RECORDING_STATE           @"record_status"
/**
 *  @author lzy, 15-09-01 11:09:39
 *
 *  @brief  初始化用户默认选项
 */
+ (void)initUserDefaults;
+ (void)setStartTime:(NSDate *)date;
+ (NSDate *)getStartTime;
/**
 *  @author lzy, 15-09-01 11:09:08
 *
 *  @brief  当前用户id，用于归档和解档用户数据
 *
 *  @param currentUserID 当前用户id
 */
+ (void) setCurrentUserID:(NSString *) currentUserID;
+ (NSString *) getCurrentUserID;
/**
 *  @author lzy, 15-10-24 20:10:28
 *
 *  @brief  暂停按钮点击的时候记录时间，再次点击的时候计算
 *
 *  @param suspendStamp 时间戳
 */
+ (void)setSuspendTime:(NSNumber*)suspendStamp;
+ (NSInteger)getSuspendTime;
//!<  开始记录以后，处于暂停状态还是处于计时状态.  1: 暂停  2: 记录中  0:未开始
+ (void)setRecordingStatus:(NSNumber*)status;
+ (NSInteger)getRecordingStatus;;
/**
 *  @author lzy, 15-10-24 00:10:06
 *
 *  @brief  记录登录名
 *
 *  @param loginName 登录名
 */
+ (void) setLoginName:(NSString *) loginName;
+ (NSString *) getLoginName;
/**
 *  @author lzy, 15-10-24 00:10:56
 *
 *  @brief  密码
 *
 *  @param pwd 注册码
 */
+ (void) setLoginPWD:(NSString *) pwd;
+ (NSString *) getLoginPwd;

+ (void)setCarNumber:(NSString *)carNumber;
+ (NSString *)getCarNumber;
/**
 *  @author lzy, 15-10-24 00:10:02
 *
 *  @brief  当前正在记录的路径在本地数据库中的id
 *
 *  @param currentRouteID 当前记录的id
 */
+ (void)setCurrentRouteID:(NSString *) currentRouteID;
+ (NSString *)getCurrentRouteID;
/**
 *  @author lzy, 15-10-24 00:10:25
 *
 *  @brief  保存用户暂停时间
 *
 *  @param remainTime 叠加用户暂停的时间
 */
+ (void)setRemainTime:(NSString *)remainTime;
+ (NSString *)getRemainTime;
//保存当前路径的状态
+ (void)setRouteStatus:(NSString *)status;
+ (NSString *)getRouteStatus;

/**
 *  @author lzy, 15-09-10 17:09:16
 *
 *  @brief  用户登录时显示上次退出的用户电话
 *
 *  @param lastUserPhone 上次退出的用户
 */
+ (void)setLastUserPhoneNum: (NSString *) lastUserPhone;
+ (NSString *)getLastUserPhoneNum;

@end
