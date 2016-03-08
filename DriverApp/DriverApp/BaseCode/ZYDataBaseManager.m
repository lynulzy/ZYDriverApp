//
//  ZYDataBaseManager.m
//  DriverApp
//
//  Created by lynulzy on 10/23/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "ZYDataBaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "ZSXJUserDefaults.h"
#import "RecordModel.h"
#import "Define.h"
#define SQL_OPEN_FAILED   @"CAN'T OPEN SQL"
@implementation ZYDataBaseManager{
    FMDatabase *dataBase_;
    //保证线程安全性
    FMDatabaseQueue *dbQueue_;
    
    NSInteger changed_distance;
    NSInteger changed_totalTime;
    
}
+ (ZYDataBaseManager *)sharedZYDataBaseManager {
    static ZYDataBaseManager * sharedZYDataBaseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedZYDataBaseManager = [[ZYDataBaseManager alloc] init];
        [sharedZYDataBaseManager initializeDataBase];
        
    });
    return sharedZYDataBaseManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        changed_distance = 0;
        changed_totalTime = 0;
    }
    return self;
}
#pragma  mark - CREATE -
static NSString *sqlPath;
- (void)initializeDataBase {
    //Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = path[0];
    NSString *dataDirectory = [documentDirPath stringByAppendingString:@"/History/"];
    
    //创建数据库存储目录
    NSFileManager *fm = [NSFileManager defaultManager];
    //目录是否存在
    if (![fm fileExistsAtPath:dataDirectory]) {
        //创建目录
        NSError *error = nil;
        [fm createDirectoryAtPath:dataDirectory
      withIntermediateDirectories:NO
                       attributes:nil error:&error];
        if (error) {
            DDLog(@"Error %@",error.domain);
        }
    }
    
    dataBase_ = [FMDatabase databaseWithPath:[dataDirectory stringByAppendingString:@"DriverApp.sqlite"]];
    dbQueue_ = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    sqlPath = [dataDirectory stringByAppendingString:@"DriverApp.sqlite"];
    DDLog(@"SQLITE PATH %@",dataDirectory);
//    [dataBase_ open];
    if ([dataBase_ open]) {
        
        /*
         #define TABLE_NAME              @"UploadRecord" //!< 表名
         
         #define DB_RouteId              @"route_id"//!<路线的id（主键 自增）*i
         #define DB_CardNum              @"car_num" //!< 车牌号t
         #define DB_Distance             @"distance" //!< 行驶距离i *
         #define DB_StarTime             @"start_time"//!< 开始的时间戳i *
         #define DB_EndTime              @"end_time" //!< 结束的时间戳i*
         #define DB_TotalTime            @"total_time"//!< 总共耗时（时间戳相减）i*
         #define DB_UserId               @"user_id" //!<用户id *
         #define DB_LoginName            @"login_name"//!<用户名t
         #define DB_LoginPWD             @"login_pwd"//!<密码t
         #define DB_AverageSpeed         @"speed"//!<平均速度(总路程/总时间)r
         #define DB_TopSpeed             @"top_speed"//!<最高速度(记录)r
         #define DB_RemainTime           @"remain_time"//!<按下暂停的时间i *
         #define DB_UUID                 @"uuid"//!<由device+routeid组成 t
         #define DB_Upload               @"upload"//!<标识是否上传*/
        NSString *sqlCreateTB = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' INTERGER, '%@' INTERGER, '%@' FLOAT, '%@' INTERGER, '%@' INTERGER, '%@' INTERGER, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' FLOAT, '%@' FLOAT, '%@' INTERGER, '%@' TEXT)", TABLE_NAME, DB_RouteId, DB_UserId, DB_Distance, DB_StarTime, DB_EndTime, DB_TotalTime, DB_RemainTime, DB_CardNum, DB_LoginName, DB_LoginPWD, DB_UUID, DB_AverageSpeed, DB_TopSpeed, DB_Upload, DB_FilePath];
        BOOL res = [dataBase_ executeUpdate:sqlCreateTB];
        if (!res) {
            DDLog(@"createFailed %@",[dataBase_ lastError].description);
        }
        else {
            NSLog(@"success");
        }
    }
    //test add a line
//    [self addAline];
//    [self updateAline];
//    [self query];
//    NSArray *resArr = [self fetchAllRows];
    [dataBase_ close];
}
#pragma mark - INSERT -
- (BOOL)insertNewRow {
    //初始化一行数据
    if ([dataBase_ open]) {
        NSInteger userID = [[ZSXJUserDefaults getCurrentUserID] integerValue];
        float distance = 0.000;
        NSInteger startTime = [[NSDate date] timeIntervalSince1970];
        NSInteger endTime = 0;
        NSInteger totalTime = 0;
        NSInteger remain = [[ZSXJUserDefaults getRemainTime] integerValue];
        NSString *carNum = [ZSXJUserDefaults getCarNumber];
        NSString *loginName = [ZSXJUserDefaults getLoginName];
        NSString *loginPwd = [ZSXJUserDefaults getLoginPwd];
        
        //构造uuid
        NSInteger recordID = 0;
        NSString *sql_getID = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = (SELECT MAX(%@) FROM %@)", DB_RouteId, TABLE_NAME, DB_RouteId, DB_RouteId,TABLE_NAME];
        FMResultSet *rs = [dataBase_ executeQuery:sql_getID];
        DDLog(@"Query Info %@ ",dataBase_.lastErrorMessage);
        while ([rs next]) {
            recordID = [rs intForColumn:DB_RouteId];
        }

        NSDateFormatter *fm = [[NSDateFormatter alloc] init];
        [fm setDateFormat:@"yyyyMMdd"];
        NSString *today = [fm stringFromDate:[NSDate date]];
        
        NSString *uuid = [NSString stringWithFormat:@"%@%@%02d", [ZSXJUserDefaults getLoginName], today, recordID + 1];
        float averageSpeed = 0.0;
//        if (totalTime == 0 || distance == 0) {
//            averageSpeed = 0.0;
//        }else {
//            averageSpeed =  distance/(totalTime/3600);
//        }
        float topSpeed = 0.00;
        BOOL upload = NO;
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%ld', '%.3f', '%ld', '%ld', '%ld', '%ld', '%@', '%@', '%@', '%@', '%f', '%f', '%d')",TABLE_NAME, DB_UserId, DB_Distance, DB_StarTime, DB_EndTime, DB_TotalTime, DB_RemainTime, DB_CardNum, DB_LoginName, DB_LoginPWD, DB_UUID, DB_AverageSpeed, DB_TopSpeed, DB_Upload,
                               (long)userID, distance, (long)startTime, (long)endTime, (long)totalTime, (long)remain, carNum, loginName, loginPwd, uuid, averageSpeed, topSpeed, upload];
        DDLog(@"inserSql [%@] ", insertSql);
        BOOL res1 = [dataBase_ executeUpdate:insertSql];
        if (!res1 ) {
            DDLog(@"createFailed %@",[dataBase_ lastError].description);
            return NO;
        }
        else {
            DDLog(@"Inser Success");
            //更新本地记录的routeId
            NSInteger routeId = [self latestRouteID];
            if (routeId != NSNotFound) {
                [ZSXJUserDefaults setCurrentRouteID:[NSString stringWithFormat:@"%ld", (long)routeId]];
            }
            return YES;
        }
    }
    return NO;
}
//!< deprecated 添加数据
- (BOOL)addAline {
    if ([dataBase_ open]) {
        NSInteger userID = [[ZSXJUserDefaults getCurrentUserID] integerValue];
        //TODO: 计算距离
        NSInteger distance = 10000;
        NSInteger startTime = [[NSDate date] timeIntervalSince1970];
        //TODO: 结束时间
        NSInteger endTime = 0;
        NSInteger totalTime = endTime > startTime ? endTime - startTime : 0;
        NSInteger remain = [[ZSXJUserDefaults getRemainTime] integerValue];
        if (remain > 0) {
            //TODO: 记录等待时间
            remain = remain +1;
        }
        NSString *carNum = [ZSXJUserDefaults getCarNumber];
        NSString *loginName = [ZSXJUserDefaults getLoginName];
        NSString *loginPwd = [ZSXJUserDefaults getLoginPwd];
        //TODO: 路径id
        NSString *UUDI = [UDID stringByAppendingString:@"routeid"];
        float averageSpeed;
        if (totalTime == 0 || distance == 0) {
            averageSpeed = 0.0;
        }else {
         averageSpeed =  distance/(totalTime/3600);
        }
        
        float topSpeed = 80.01;
        //TODO: 是否上传过
        Boolean upload = NO;
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%ld', '%ld', '%ld', '%ld', '%ld', '%ld', '%@', '%@', '%@', '%@', '%f', '%f', '%d')",TABLE_NAME, DB_UserId, DB_Distance, DB_StarTime, DB_EndTime, DB_TotalTime, DB_RemainTime, DB_CardNum, DB_LoginName, DB_LoginPWD, DB_UUID, DB_AverageSpeed, DB_TopSpeed, DB_Upload,
                               (long)userID, (long)distance, (long)startTime, (long)endTime, (long)totalTime, (long)remain, carNum, loginName, loginPwd, UUDI, averageSpeed, topSpeed, upload];
        DDLog(@"inserSql [%@] ", insertSql);
        BOOL res1 = [dataBase_ executeUpdate:insertSql];
        [dataBase_ close];
        if (!res1 ) {
            DDLog(@"createFailed %@",[dataBase_ lastError].description);
            return NO;
        }
        else {
            DDLog(@"Inser Success");
            return YES;
        }
    }
    
    //数据库打开失败
    return NO;
}
#pragma mark - UPDATE -
- (BOOL)updateUploadStatus:(BOOL)status routeID:(NSInteger)routeId {
    DDLog(@"%@",sqlPath);
    dbQueue_ = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    __block BOOL res;
    [dbQueue_ inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET '%@' = '%@'", TABLE_NAME, DB_UUID, @"abcde"];
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%@' WHERE `%@` = '%d'", TABLE_NAME, DB_Upload, status?@"1":@"0", DB_RouteId, routeId];
//        NSString *updateSql2 = [NSString stringWithFormat:@"UPDATE '%@' SET '%@' = '%@' WHERE '%@' = '%ld'", TABLE_NAME, DB_UUID, @"abcd", DB_RouteId, (long)currentRouteID];
//        DDLog(@"updateSql2 %@",updateSql2);
        res = [db executeUpdate:updateSql];
        if (!res) {
            DDLog(@"UPDATE ERROR %@",db.lastErrorMessage);
        }
        else {
            DDLog(@"UPDATE SUCCESS");
        }
        //Test
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` = '%d'", TABLE_NAME, DB_RouteId,routeId];
        FMResultSet *rs = [db executeQuery:sql];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        while ([rs next]) {
            DDLog(@"test_res %d", [rs intForColumn:DB_Upload]);
        }
    }];
    return res;
        
//        NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET '%@' = '%d' WHERE '%@' = '%ld'", TABLE_NAME, DB_Upload, status ? 1 : 0, DB_RouteId, (long)currentRouteID];
}
- (void)updateDistance:(float)theDistance topSpeed:(float)theSpeed {
    dbQueue_ = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    __block float theTopSpeed = theSpeed;
    [dbQueue_ inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //判断最高速度
        float oldDistance = 0;
        NSInteger startTime = 0;//计算平均速度用
        float newDistance = 0;//总的距离，需要更新
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` = '%@'", TABLE_NAME, DB_RouteId,[ZSXJUserDefaults getCurrentRouteID]];
        FMResultSet *rs = [db executeQuery:sql];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        while ([rs next]) {
            if (theTopSpeed < [rs doubleForColumn:DB_TopSpeed]) {
                theTopSpeed = 0;
            }
            oldDistance = [rs doubleForColumn:DB_Distance];
            startTime = [rs intForColumn:DB_StarTime];
            DDLog(@"test_res %f", [rs doubleForColumn:DB_TopSpeed]);
        }
        if (theTopSpeed != 0) {
            //更新最高速度
            NSString *sqlStatement1 = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%f' WHERE `%@` = '%@'", TABLE_NAME, DB_TopSpeed, theTopSpeed, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
            BOOL res = [db executeUpdate:sqlStatement1];
            if (!res) {
                DDLog(@"UPDATE ERROR %@",db.lastErrorMessage);
            }
            else {
                DDLog(@"UPDATE SUCCESS");
            }
            
        }
       
        
        //更新平均速度
        NSInteger now = [[NSDate date] timeIntervalSince1970];
        NSInteger totalTime = now - startTime;
        float hour = totalTime/3600 + (float)(totalTime%3600)/3600;
        newDistance = (oldDistance + theDistance)/1000;
        float averSpeed = newDistance/hour;
        NSString *sqlStatement2 = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%f' WHERE `%@` = '%@'", TABLE_NAME, DB_AverageSpeed, averSpeed, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        BOOL res = [db executeUpdate:sqlStatement2];
        if (!res) {
            DDLog(@"UPDATE ERROR %@",db.lastErrorMessage);
        }
        else {
            DDLog(@"UPDATE SUCCESS");
        }
        
        //Test
        NSString *testSql2 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` = '%@'", TABLE_NAME, DB_RouteId,[ZSXJUserDefaults getCurrentRouteID]];
        FMResultSet *rs3 = [db executeQuery:testSql2];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        while ([rs3 next]) {
            DDLog(@"test %f", [rs3 doubleForColumn:DB_AverageSpeed]);
        }
        
        //更新总时间
        NSString *sqlStatement3 = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%d' WHERE `%@` = '%@'", TABLE_NAME, DB_TotalTime, totalTime, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        BOOL res2 = [db executeUpdate:sqlStatement3];
        if (!res2) {
            DDLog(@"UPDATE ERROR %@",db.lastErrorMessage);
        }
        else {
            DDLog(@"UPDATE SUCCESS");
        }
        //更新距离
        NSString *sqlStatement4 = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%.3f' WHERE `%@` = '%@'", TABLE_NAME, DB_Distance, newDistance, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        BOOL res3 = [db executeUpdate:sqlStatement4];
        if (!res3) {
            DDLog(@"UPDATE ERROR %@",db.lastErrorMessage);
        }
        else {
            DDLog(@"UPDATE SUCCESS");
        }
        
        //Test
        NSString *testSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` = '%@'", TABLE_NAME, DB_RouteId,[ZSXJUserDefaults getCurrentRouteID]];
        FMResultSet *rs2 = [db executeQuery:testSql];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        while ([rs2 next]) {
            DDLog(@"test %d", [rs2 intForColumn:DB_Distance]);
            
            //发送通知，更新显示数据
            NSDictionary *userInfo = @{@"totalTime" : [NSString stringWithFormat:@"%d",totalTime],
                                       @"distance"  : [NSString stringWithFormat:@"%.3f",newDistance]};
            NSNotification *noti = [NSNotification notificationWithName:NOTI_NAME_UPDATE_INFO
                                                                 object:nil
                                                               userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:noti];
        }
    }];
}
- (void)updateFilePath:(NSString *)thePath {
    if (thePath.length < 1) {
        DDLog(@"文件路径长度不够!");
        return;
    }
    dbQueue_ = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    [dbQueue_ inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%@' WHERE `%@` = '%@'", TABLE_NAME,DB_FilePath,thePath,DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            DDLog(@"UPDATE ERROR %@",db.lastErrorMessage);
        }
        else {
            DDLog(@"UPDATE SUCCESS");
        }
        //Test
        NSString *sql2 = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` = '%@'", TABLE_NAME, DB_RouteId,[ZSXJUserDefaults getCurrentRouteID]];
        FMResultSet *rs = [db executeQuery:sql2];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        while ([rs next]) {
            DDLog(@"test_res %@", [rs stringForColumn:DB_FilePath]);
        }
    }];
    
}
- (void)updateWhenfinished {
    dbQueue_ = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    [dbQueue_ inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //获得原来数据
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` = '%@'", TABLE_NAME, DB_RouteId,[ZSXJUserDefaults getCurrentRouteID]];
        FMResultSet *rs = [db executeQuery:sql];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        NSInteger endtime = [[NSDate date] timeIntervalSince1970];
        NSInteger totaltime = 0;
        float speed = 0.0;
        while ([rs next]) {
            //
            NSInteger startTime = [rs intForColumn:DB_StarTime];
            float distance = [rs doubleForColumn:DB_Distance];
            totaltime = endtime - startTime;
            float hour = (float)totaltime/3600 + (float)(totaltime%3600)/3600;
            speed = distance/hour;
        }
        //计算后更新到数据库中
        NSString *updateSql1 = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%d' WHERE `%@` = '%@'", TABLE_NAME, DB_EndTime, endtime, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        BOOL res = [db executeUpdate:updateSql1];
        NSString *updateSql2 = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%d' WHERE `%@` = '%@'", TABLE_NAME, DB_TotalTime, totaltime, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        BOOL res2 = [db executeUpdate:updateSql2];
        NSString *updateSql3 = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = '%f' WHERE `%@` = '%@'", TABLE_NAME, DB_AverageSpeed, speed, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        BOOL res3 = [db executeUpdate:updateSql3];
        if (!res || !res2 || !res3) {
            DDLog(@"UPDATE ERROR %@",db.lastErrorMessage);
        }
        else {
            DDLog(@"UPDATE SUCCESS");
        }
        //test
        NSString *testsql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` = '%@'", TABLE_NAME, DB_RouteId,[ZSXJUserDefaults getCurrentRouteID]];
        FMResultSet *testrs = [db executeQuery:testsql];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        while ([testrs next]) {
            DDLog(@"test_res %d", [testrs intForColumn:DB_EndTime]);
            DDLog(@"test_res %d", [testrs intForColumn:DB_TotalTime]);
            DDLog(@"test_res %f", [testrs doubleForColumn:DB_AverageSpeed]);
        }
    }];
    
}
- (void)updateRemain {
    dbQueue_ = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    if (![ZSXJUserDefaults getSuspendTime]) {
        DDLog(@"没有暂停！！！");
        return;
    }
    [dbQueue_ inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //计算后更新到数据库中
        NSInteger remainTime = [[NSDate date] timeIntervalSince1970] - [ZSXJUserDefaults getSuspendTime];
        
        NSString *updateSql1 = [NSString stringWithFormat:@"UPDATE %@ SET `%@` = `%@` + '%d' WHERE `%@` = '%@'", TABLE_NAME, DB_RemainTime, DB_RemainTime, remainTime, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        BOOL res = [db executeUpdate:updateSql1];
        if (!res) {
            DDLog(@"UPDATE ERROR %@",db.lastErrorMessage);
        }
        else {
            DDLog(@"UPDATE SUCCESS");
        }
        //Test
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` = '%@'", TABLE_NAME, DB_RouteId,[ZSXJUserDefaults getCurrentRouteID]];
        FMResultSet *rs = [db executeQuery:sql];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        while ([rs next]) {
            float distance = [rs doubleForColumn: DB_Distance];
            NSInteger totalTime = (NSInteger)[[NSDate date] timeIntervalSince1970] - [rs intForColumn:DB_StarTime];
            DDLog(@"test_res %d", [rs intForColumn:DB_RemainTime]);
            DDLog(@"*** distance %f",distance);
            DDLog(@"*** totalTime %d",totalTime);
            
            //发送通知，更新显示数据
            NSDictionary *userInfo = @{@"totalTime" : [NSString stringWithFormat:@"%d",totalTime],
                                       @"distance"  : [NSString stringWithFormat:@"%.3f",distance]};
            NSNotification *noti = [NSNotification notificationWithName:NOTI_NAME_UPDATE_INFO
                                                                 object:nil
                                                               userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:noti];
        }

    }];
    
}
- (void)updateAline {
    if ([dataBase_ open]) {
        NSString *tableName = @"History";
        NSString *key1 = @"ID";
        NSString *key3 = @"AGE";
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET '%@' = '%@' WHERE '%@' = '%@'", tableName, key3, @(18), key1, @(1)];
        BOOL res = [dataBase_ executeUpdate:updateSql];
        if (!res) {
            DDLog(@"update error %@",dataBase_.lastError.description);
        }
        else {
            DDLog(@"update success");
        }
        [dataBase_ close];
    }
}

#pragma  mark - QUERY
- (NSArray *)fetchAllRows {
    if ([dataBase_ open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_NAME];
        FMResultSet *resSet = [dataBase_ executeQuery:sql];
        NSMutableArray * resultArr = [[NSMutableArray alloc] init];
        while ([resSet next]) {
            /*
             @property (nonatomic,assign) NSInteger userID;
             @property (nonatomic,assign) NSInteger distance;
             @property (nonatomic,assign) NSInteger startTime;
             @property (nonatomic,assign) NSInteger endTime;
             @property (nonatomic,assign) NSInteger totalTime;
             @property (nonatomic,assign) NSInteger remain;
             @property (nonatomic, copy)NSString *carNum;
             @property (nonatomic, copy)NSString *uuid;
             @property (nonatomic, assign)float speed;
             @property (nonatomic, assign)float averageSpeed;
             @property (nonatomic, assign)float topSpeed;
             @property (nonatomic, assign) BOOL uploaded;*/
            RecordModel *aRecord = [[RecordModel alloc] init];
            aRecord.recordID = [resSet intForColumn:DB_RouteId];
            aRecord.userID = [resSet intForColumn:DB_UserId];
            aRecord.distance = [resSet doubleForColumn:DB_Distance];
            aRecord.startTime = [resSet intForColumn:DB_StarTime];
            aRecord.endTime = [resSet intForColumn:DB_EndTime];
            aRecord.totalTime = [resSet intForColumn:DB_TotalTime];
            aRecord.remain = [resSet intForColumn:DB_RemainTime];
            aRecord.carNum = [resSet stringForColumn:DB_CardNum];
            aRecord.uuid = [resSet stringForColumn:DB_UUID];
            aRecord.averageSpeed = [resSet doubleForColumn:DB_AverageSpeed];
            aRecord.topSpeed = [resSet doubleForColumn:DB_TopSpeed];
            aRecord.uploaded = [resSet boolForColumn:DB_Upload];
            [resultArr addObject:aRecord];
        }
        [dataBase_ close];
        return resultArr;
    }
    return nil;
}
- (NSInteger)latestRouteID {
    if ([dataBase_ open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = (SELECT MAX(%@) FROM %@)", DB_RouteId, TABLE_NAME, DB_RouteId, DB_RouteId,TABLE_NAME];
        FMResultSet *rs = [dataBase_ executeQuery:sql];
        DDLog(@"Query Info %@ ",dataBase_.lastErrorMessage);
        while ([rs next]) {
            return [rs intForColumn:DB_RouteId];
        }
        return NSNotFound;
    }
    DDLog("%@",SQL_OPEN_FAILED);
    return NSNotFound;
}
- (NSString *)queryPath:(NSInteger)routeID {
    if ([dataBase_ open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = %d", DB_FilePath, TABLE_NAME, DB_RouteId, routeID];
        FMResultSet *rs = [dataBase_ executeQuery:sql];
        DDLog(@"Query Info %@ ",dataBase_.lastErrorMessage);
        while ([rs next]) {
            return [rs stringForColumn:DB_FilePath];
        }
    }
    return nil;
}
- (RecordModel *)generateCurrentRouteModel {
    if ([ZSXJUserDefaults getCurrentRouteID].length < 1) {
        DDLog(@"current route id 不存在 ！！！");
        return nil;
    }
    __block RecordModel *rm = [[RecordModel alloc] init];
    dbQueue_ = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    [dbQueue_ inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE `%@` LIKE '%@'", TABLE_NAME, DB_RouteId, [ZSXJUserDefaults getCurrentRouteID]];
        FMResultSet *rs = [db executeQuery:sql];
        DDLog(@"Query Info %@ ",db.lastErrorMessage);
        while ([rs next]) {
            /*
             @property (nonatomic,assign) NSInteger recordID;
             @property (nonatomic,assign) NSInteger userID;
             @property (nonatomic,assign) NSInteger distance;
             @property (nonatomic,assign) NSInteger startTime;
             @property (nonatomic,assign) NSInteger endTime;
             @property (nonatomic,assign) NSInteger totalTime;
             @property (nonatomic,assign) NSInteger remain;
             @property (nonatomic, copy)NSString *carNum;
             @property (nonatomic, copy)NSString *uuid;
             @property (nonatomic, assign)float averageSpeed;
             @property (nonatomic, assign)float topSpeed;
             @property (nonatomic, assign) BOOL uploaded;
             */
            rm.recordID = [rs intForColumn:DB_RouteId];
            rm.userID = [rs intForColumn:DB_UserId];
            rm.distance = [rs doubleForColumn:DB_Distance];
            rm.startTime = [rs intForColumn:DB_StarTime];
            rm.endTime = [rs intForColumn:DB_EndTime];
            rm.totalTime = [rs intForColumn:DB_TotalTime];
            rm.remain = [rs intForColumn:DB_RemainTime];
            rm.carNum = [rs stringForColumn:DB_CardNum];
            rm.uuid = [rs stringForColumn:DB_UUID];
            rm.averageSpeed = [rs doubleForColumn:DB_AverageSpeed];
            rm.topSpeed = [rs doubleForColumn:DB_TopSpeed];
            rm.uploaded = [rs boolForColumn:DB_Upload];
        }
    }];
        return rm;
}
- (void)query {
    if ([dataBase_ open]) {
        NSString *tableName = @"History";
//        NSString *key3 = @"NAME";
        NSString *ID = @"ID";
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM %@ WHERE %@ = (SELECT MAX(%@) FROM %@)", tableName, ID, ID, tableName];
        FMResultSet *rs = [dataBase_ executeQuery:sql];
        DDLog(@"QUERY ERROR  %@",dataBase_.lastErrorMessage);
//        if (![rs next]) {
//            DDLog(@"error %@",dataBase_.lastError.description);
//        }
        while ([rs next]) {
            NSInteger ID = [rs intForColumn:@"ID"];
            NSString *name = [rs stringForColumn:@"NAME"];
            NSString *age = [rs stringForColumn:@"AGE"];
            DDLog(@"id - %ld name - %@  age - %@", (long)ID, name, age);
        }
        [dataBase_ close];
    }
}



@end
