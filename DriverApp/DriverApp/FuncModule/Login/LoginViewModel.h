//
//  loginViewModel.h
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "ZYBaseViewModel.h"
typedef NS_ENUM(NSInteger, LoginSucc) {
    LoginSuccess,//!< 登录成功
};
typedef NS_ENUM(NSInteger, LoginErr) {
    LoginErr_Local,//!< 本地错误
    LoginErr_Server,//!< 服务器返回错误消息
    LoginErr_Request,//!< 请求本身出错
};
@interface LoginViewModel : ZYBaseViewModel
-(void)loginRequest:(NSDictionary *)params;
@end
