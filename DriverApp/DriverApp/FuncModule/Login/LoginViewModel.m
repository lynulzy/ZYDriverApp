//
//  loginViewModel.m
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "LoginViewModel.h"
#import "ZSXJUserDefaults.h"
#import "MBProgressHUD.h"
#import "Define.h"
@implementation LoginViewModel
- (void)loginRequest:(NSDictionary *)params {
    ZSXJHTTPSession *session = [ZSXJHTTPSession sharedSession];
    
    if (params[@"loginname"] && params[@"loginpwd"] && params [@"device"]) {
        
        NSMutableString *formatURL = [NSMutableString stringWithString:SERVER_URL];
        [formatURL appendString:LOGIN_URL];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.relatedController.view];
        HUD.labelText = @"正在登录";
        [self.relatedController.view addSubview:HUD];
        [HUD show:YES];
        [session GET:formatURL
          parameters:params
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                 [HUD hide:YES];
                 if ([responseObject[@"errorcode"] isEqualToString:@"1"]) {
                     //登录成功
                     self.resultBlock(LoginSuccess,responseObject[@"errormsg"]);
                     //保存UserID
                     NSString *userId = [NSString stringWithFormat:@"%@",responseObject[@"userId"]];
                     [ZSXJUserDefaults setCurrentUserID:userId];
                     [ZSXJUserDefaults setLoginName:params[@"loginname"]];
                     [ZSXJUserDefaults setLoginPWD:params[@"loginpwd"]];
                     return ;
                 }
                 else
                 {
                     //登录失败
                     self.errorBlock(LoginErr_Server,responseObject[@"errormsg"]);
                     return ;
                 }
             }
             failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                 [HUD hide:YES];
                 DDLog(@"error %@",error);
                 self.errorBlock(LoginErr_Request,@"请求出错!");
             }];
    }
}
@end
