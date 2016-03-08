//
//  HistoryListViewController.m
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "HistoryListViewController.h"
#import "RecordCell.h"
#import "ZYDataBaseManager.h"
#import "RecordModel.h"
@interface HistoryListViewController()<UITableViewDataSource,UITableViewDelegate>

@end
@implementation HistoryListViewController
{

    __weak IBOutlet UITableView *recordTableView;
    NSArray *dataSource_;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史数据";
    recordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self refreshDatasource];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDatasource) name:NOTI_NAME_REFRESH_INFO object:nil];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_NAME_REFRESH_INFO object:nil];
}
- (void)refreshDatasource {
    dataSource_ = [[ZYDataBaseManager sharedZYDataBaseManager] fetchAllRows];
    if (dataSource_.count == 0) {
        [self alertMessage:@"暂无历史数据"];
        return;
    }
    [recordTableView reloadData];
}
- (void)alertMessage:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    [alert show];
}
#pragma mark - UITableView Dlegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource_.count > 0?dataSource_.count:0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellName = @"recordCell";
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        DDLog(@"cell 初始化失败");
    }
    if (dataSource_.count > 0) {
        [cell fillDataWithModel:dataSource_[indexPath.row]];
    }
    return cell;
}
@end
