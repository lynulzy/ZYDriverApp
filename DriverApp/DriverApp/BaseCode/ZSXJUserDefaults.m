//
//  ZSXJUserDefaults.m
//  LogisticsShipper
//
//  Created by lynulzy on 9/1/15.
//  Copyright (c) 2015 leiyang. All rights reserved.
//

#import "ZSXJUserDefaults.h"

@implementation ZSXJUserDefaults
+ (void)initUserDefaults {
    if (![ZSXJUserDefaults getCurrentUserID]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@"" forKey:USER_DEFAULTS_CURRENT_USERID];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getLastUserPhoneNum]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@"" forKey:USER_DEFAULTS_LAST_USER_PHONE];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getCarNumber]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@"" forKey:USER_DEFAULTS_REMAIN_TIME];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getCarNumber]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@"" forKey:USER_DEFAULTS_CURRENT_ROUTE];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getCarNumber]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@"" forKey:USER_DEFAULTS_LOGINPWD];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getCarNumber]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@"" forKey:USER_DEFAULTS_LOGINNAME];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getRouteStatus]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@"" forKey:USER_DEFAULTS_ROUTE_STATUS];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getSuspendTime]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@(0) forKey:USER_DEFAULTS_SUSPEND_TIME];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getStartTime]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@(0) forKey:USER_DEFAULTS_START_DATE];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    if (![ZSXJUserDefaults getRecordingStatus]) {
        NSDictionary *resourceDict = [NSDictionary dictionaryWithObject:@(0) forKey:USER_DEFAULTS_RECORDING_STATE];
        [[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
    }
    
}

#pragma mark - 需要保存的用户默认选项
+ (void)setStartTime:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:USER_DEFAULTS_START_DATE];
}
+ (NSDate *)getStartTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_START_DATE];
}
+ (void)setSuspendTime:(NSNumber *)suspendStamp {
    if (suspendStamp == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:USER_DEFAULTS_SUSPEND_TIME];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:suspendStamp forKey:USER_DEFAULTS_SUSPEND_TIME];
}
+ (NSInteger)getSuspendTime {
    return [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_SUSPEND_TIME] integerValue];
}
+ (void)setRecordingStatus:(NSNumber *)status {
    [[NSUserDefaults standardUserDefaults] setObject:status forKey:USER_DEFAULTS_RECORDING_STATE];
}
+ (NSInteger)getRecordingStatus {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_RECORDING_STATE] integerValue];
}
+ (void)setCurrentUserID:(NSString *)currentUserID {
    if (currentUserID.length > 0) {
        [self postLoginNotification];
    }
    [[NSUserDefaults standardUserDefaults] setObject:currentUserID forKey:USER_DEFAULTS_CURRENT_USERID];
}

//用户登录（注册成功）之后发送的全局通知
+ (void)postLoginNotification{
}
//用户退出登录
+ (void)postLogoutNotification {
#warning  TODO  退出之后的页面逻辑
}
+ (NSString *)getCurrentUserID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_CURRENT_USERID];
}
+ (NSString *)getCarNumber {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_CAR_NUMBER];
}
+ (void)setLoginName:(NSString *)loginName {
    [[NSUserDefaults standardUserDefaults] setObject:loginName forKey:USER_DEFAULTS_LOGINNAME];
}
+ (NSString *)getLoginName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_LOGINNAME];
}
+(void)setLoginPWD:(NSString *)pwd {
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:USER_DEFAULTS_LOGINPWD];
}
+(NSString *)getLoginPwd {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_LOGINPWD];
}
+ (void)setCarNumber:(NSString *)carNumber {
    [[NSUserDefaults standardUserDefaults] setObject:carNumber forKey:USER_DEFAULTS_CAR_NUMBER];
}
+ (void)setLastUserPhoneNum:(NSString *)lastUserPhone {
    [[NSUserDefaults standardUserDefaults] setObject:lastUserPhone forKey:USER_DEFAULTS_LAST_USER_PHONE];
}
+ (NSString *)getLastUserPhoneNum {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_LAST_USER_PHONE];
}
+ (void)setRouteStatus:(NSString *)status {
    [[NSUserDefaults standardUserDefaults] setObject:status forKey:USER_DEFAULTS_ROUTE_STATUS];
}
+ (NSString *)getRouteStatus {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_ROUTE_STATUS];
}
+ (void)setCurrentRouteID:(NSString *)currentRouteID {
    [[NSUserDefaults standardUserDefaults] setObject:currentRouteID forKey:USER_DEFAULTS_CURRENT_ROUTE];
}
+ (NSString *)getCurrentRouteID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_CURRENT_ROUTE];
}

+ (void)setRemainTime:(NSString *)remainTime {
    [[NSUserDefaults standardUserDefaults] setObject:remainTime forKey:USER_DEFAULTS_REMAIN_TIME];
}
+(NSString *)getRemainTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_REMAIN_TIME];
}
@end
