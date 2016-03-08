//
//  RecordCell.h
//  DriverApp
//
//  Created by lynulzy on 10/24/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordModel.h"
@interface RecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *recordIdLB;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLB;
@property (weak, nonatomic) IBOutlet UILabel *distanceLB;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLB;
@property (weak, nonatomic) IBOutlet UIButton *uploadBT;

- (void)fillDataWithModel:(RecordModel *)record;

@end
