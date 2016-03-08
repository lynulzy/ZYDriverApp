//
//  ZYBaseViewController.h
//  LogisticsShipper
//
//  Created by lynulzy on 8/26/15.
//  Copyright (c) 2015 leiyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYBaseViewController : UIViewController
- (void)alertMessage: (NSString *) theMessage;
- (void)tipMessage: (NSString *) message success: (BOOL) succ;
- (void)tipMessage: (NSString *) message success: (BOOL) succ inWindow: (BOOL) presentInWindow;
@end
