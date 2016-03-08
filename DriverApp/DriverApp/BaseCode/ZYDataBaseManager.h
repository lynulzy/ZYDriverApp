//
//  ZYDataBaseManager.h
//  DriverApp
//
//  Created by lynulzy on 10/23/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RecordModel.h"
/*
 2	cardnum车牌号
 3	distance距离
 4	startime开始时间 (时间戳)
 5	endtime结束时间 （整型戳）
 6	totaltime总时间 (整型)
 7	routeid规定路线id
 8	userid用户id  (整型)
 9	loginnamme账号 （字符串）
 10	loginpwd注册码 (字符串)
 11	speed平均速度
 12	topspeed最高速度
 13	spenttime停留时间
 14	uuid该文件入库主键()
 
 是否上传过*/
#define TABLE_NAME              @"UploadRecord" //!< 表名

#define DB_RouteId              @"route_id"//!<路线的id（主键 自增）
#define DB_CardNum              @"car_num" //!< 车牌号
#define DB_Distance             @"distance" //!< 行驶距离
#define DB_StarTime             @"start_time"//!< 开始的时间戳
#define DB_EndTime              @"end_time" //!< 结束的时间戳
#define DB_TotalTime            @"total_time"//!< 总共耗时（时间戳相减）
#define DB_UserId               @"user_id" //!<用户id
#define DB_LoginName            @"login_name"//!<用户名
#define DB_LoginPWD             @"login_pwd"//!<密码
#define DB_AverageSpeed         @"speed"//!<平均速度(总路程/总时间)
#define DB_TopSpeed             @"top_speed"//!<最高速度(记录)
#define DB_RemainTime           @"remain_time"//!<按下暂停的时间
#define DB_UUID                 @"uuid"//!<由device+routeid组成
#define DB_Upload               @"upload"//!<标识是否上传
#define DB_FilePath             @"file_path"//文件合成后在本地的路径(根据此路径上传服务器)


@interface ZYDataBaseManager : NSObject
+ (ZYDataBaseManager *)sharedZYDataBaseManager;
/**
 *  @author lzy, 15-10-23 17:10:13
 *
 *  @brief  初始化数据库
 */
- (void)initializeDataBase;
/**
 *  @author lzy, 15-10-24 01:10:27
 *
 *  @brief  获取所有记录
 *
 *  @return 记录的数组，保存的是RecordModel类型的数据
 */
- (NSArray *)fetchAllRows;
//!< 新建一条记录
- (BOOL)insertNewRow;


- (NSString *)queryPath:(NSInteger)routeID;//!< 查询文件保存路径
- (NSInteger)latestRouteID;//!< 最新的路径id
/**
 *  @author lzy, 15-10-24 12:10:40
 *
 *  @brief  更新当前记录的上传状态
 *
 *  @param status YES - 已经上传; NO - 未上传
 *
 *  @return 更新操作是否成功
 */
- (BOOL)updateUploadStatus:(BOOL)status routeID:(NSInteger)routeId;
//根据当前routeid生成一个route Model对象
- (RecordModel *)generateCurrentRouteModel;
/**
 *  @author lzy, 15-10-24 18:10:42
 *
 *  @brief  当记录结束的时候更新数据库字段  endtime, totaltime, speed
 */
- (void)updateWhenfinished;
/**
 *  @author lzy, 15-10-24 21:10:47
 *
 *  @brief  更新数据库中停留时间字段,以当前timestamp 和 defaults中记录的差值为准
 */
- (void)updateRemain;
/**
 *  @author lzy, 15-10-24 22:10:51
 *
 *  @brief  更新数据库中的文件地址
 *
 *  @param thePath 文件的完整路径
 */
- (void)updateFilePath:(NSString *)thePath;
- (void)updateDistance:(float)theDistance topSpeed:(float) theSpeed;
@end
