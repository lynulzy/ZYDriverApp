//
//  PersonViewController.m
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "PersonViewController.h"

@implementation PersonViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人中心";
}
- (IBAction)dismisThisViewClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
