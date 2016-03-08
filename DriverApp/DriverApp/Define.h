//
//  Define.h
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#ifndef Define_h
#define Define_h
#define BAIDU_KEY       @"rGGvQCqnbv6dsIQXFA7nlLp5"

#define THEME_COLOR   [UIColor colorWithRed:0.17 green:0.36 blue:0.51 alpha:1]

#define RECORD_FILE_NAME   [NSString stringWithFormat:@"record_%@",[ZSXJUserDefaults getCurrentRouteID]]
//!< 5s @"F60346BC-A8F8-483C-8DB8-A54394810240"
//#define UDID          @"F7D29DE9-F62B-4EEA-8190-C9D1406E696F"//调试状态
#define UDID        [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define SERVER_URL    @"http://114.215.176.234:8080"

#define LOGIN_URL     @"/lines/clientLoginByGet.do"

#define NOTI_NAME_UPDATE_INFO           @"update_route_distance&totalTime"
#define NOTI_NAME_REFRESH_INFO          @"refresh_list"
#define NOTI_NAME_TERMINATE             @"application_will_terminate"//应用将要退出
#endif /* Define_h */
