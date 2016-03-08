//
//  ZYBaseViewController.m
//  LogisticsShipper
//
//  Created by lynulzy on 8/26/15.
//  Copyright (c) 2015 leiyang. All rights reserved.
//

#import "ZYBaseViewController.h"
#import "ZYBaseViewModel.h"
#import "MBProgressHUD.h"
@interface ZYBaseViewController ()<MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    ZYBaseViewModel *ViewModel;
}

@end

@implementation ZYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)alertMessage:(NSString *) theMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message: theMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"好的"
                                          otherButtonTitles: nil];
    [alert show];
    return;
}
#pragma  mark - Build HUD
- (void)tipMessage:(NSString *)message success:(BOOL)succ inWindow:(BOOL)presentInWIindow {
    if (!presentInWIindow) {
        [self tipMessage:message success:succ];
        return;
    }
    HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    HUD.mode = MBProgressHUDModeCustomView;
    [self.view.window addSubview:HUD];
    HUD.delegate = self;
    if (!message) {
        HUD.labelText = succ ? @"成功" : @"失败";
    }
    else {
        HUD.labelText = message;
    }
    NSString *imageName = succ ? @"HUDSuccess" : @"HUDFailed";
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [HUD show:YES];
    [HUD hide:YES afterDelay:0.8];
}
- (void)tipMessage:(NSString *)message success:(BOOL)succ {
    NSString *imageName = succ ? @"HUDSuccess" : @"HUDFailed";
    NSString *messageString;
    if (!message) {
        messageString = succ ? @"请求成功" : @"请求失败";
    }
    else {
        messageString = [message copy];
    }
    [self taskSuccess:messageString image:imageName];
}
- (void)taskSuccess:(NSString *) successMessage image: (NSString *) imageName {
    HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    if (successMessage) {
        HUD.labelText = successMessage;
    }
    HUD.color = [UIColor lightGrayColor];
    [HUD show:YES];
    [HUD hide:YES afterDelay:2.5];
    
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void)viewDidUnload {
//    [self setButtons:nil];
    [super viewDidUnload];
}

@end
