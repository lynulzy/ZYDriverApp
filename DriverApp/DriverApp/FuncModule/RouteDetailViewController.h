//
//  RouteDetailViewController.h
//  DriverApp
//
//  Created by lynulzy on 10/24/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "ZYBaseViewController.h"
#import "RecordModel.h"
@interface RouteDetailViewController : ZYBaseViewController
//!< 保存整理好要传入此页面展示的数据
@property (nonatomic, strong)RecordModel *recordModel;
@end
