//
//  ZYFileManager.m
//  DriverApp
//
//  Created by lynulzy on 10/23/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "ZYFileManager.h"
#import "ZSXJUserDefaults.h"
#import "RecordModel.h"
#import "Define.h"
@interface ZYFileManager()<NSStreamDelegate>

@end
@implementation ZYFileManager
{
    NSString *theFilePath;
}
+ (ZYFileManager *)sharedZYFileManager {
    static ZYFileManager *sharedZYFileManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedZYFileManager = [[ZYFileManager alloc] init];
    });
    return sharedZYFileManager;
}
- (NSString *)generateFileToUpload {
    //TODO: 合成文件的具体操作
    RecordModel *recM = [[ZYDataBaseManager sharedZYDataBaseManager] generateCurrentRouteModel];
//    NSString *recordHeader = [NSString stringWithFormat:@"%@ %@ %d %d %d %d %d %d %@ %@ %f %f %d000 %@\n", UDID, recM.carNum, recM.distance, recM.startTime, recM.endTime, recM.totalTime, recM.recordID, recM.userID, [ZSXJUserDefaults getLoginName], [ZSXJUserDefaults getLoginPwd],recM.averageSpeed, recM.topSpeed, recM.remain, recM.uuid];
    NSString *recordHeader = [NSString stringWithFormat:@"%@ %@ %.3f %d000 %d000 %d000 %d %d %@ %@ %f %f %d000 %@\n", UDID, recM.carNum, recM.distance, recM.startTime, recM.endTime, recM.totalTime, recM.recordID, recM.userID, [ZSXJUserDefaults getLoginName], [ZSXJUserDefaults getLoginPwd],recM.averageSpeed, recM.topSpeed, recM.remain, recM.uuid];
    DDLog(@"recmodel  header %@",recordHeader);
    NSString *fileName = [NSString stringWithFormat:@"record_%@",[ZSXJUserDefaults getCurrentRouteID]];
    if ([self writeFile:fileName dataString:recordHeader appending:NO]) {
        return theFilePath;
    }
    return nil;
}
- (BOOL)writeRecord:(CLLocation *)aLocation start:(BOOL)start{
    NSString *record = [NSString stringWithFormat:@"%f %f %f %f %d000 %f 0 %d\n", aLocation.coordinate.latitude, aLocation.coordinate.longitude, aLocation.speed, aLocation.altitude, (int)[[aLocation timestamp] timeIntervalSince1970], aLocation.horizontalAccuracy, start?1:0];
    DDLog(@"a record %@", record);
    NSString *fileName = [NSString stringWithFormat:@"record_%@",[ZSXJUserDefaults getCurrentRouteID]];
    return [self writeFile:fileName dataString:record appending:YES];
}
- (BOOL)writeFile:(NSString *)fileName dataString:(NSString *)data appending: (BOOL) append{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = path[0];
    NSString *dataDirectory = [documentDirPath stringByAppendingString:@"/LocationData"];
    //创建文件管理器
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",dataDirectory,fileName];
    DDLog(@"filePath %@",filePath);
    theFilePath = filePath;
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
    
    if ([fm fileExistsAtPath:filePath]) {
        //文件存在则追加文件
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if (fileHandle == nil) {
            DDLog(@"不能追加文件");
        }
        if (append) {
            //找到文件末尾
            [fileHandle seekToEndOfFile];
            //写入数据
            [fileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
        }
        else {
            NSString *currentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSString *gengerateString = [data stringByAppendingString:currentStr];
            DDLog(@"current str 【%@】", currentStr);
            [fileHandle seekToFileOffset:0];
            [fileHandle writeData:[gengerateString dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
        }
        
        return YES;
    }
    else {
        //不存在则创建文件
        return [fm createFileAtPath:filePath
                           contents:[data dataUsingEncoding:NSUTF8StringEncoding]
                         attributes:nil];
    }
}
- (NSString *)renameFile:(NSString *)path fileName:(NSString *)fileName newFileName:(NSString *)newName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = dirpath[0];
    NSString *newPath = [documentDirPath stringByAppendingString:[NSString stringWithFormat:@"/%@",newName]];
    NSError *error;
    if ([fileManager moveItemAtPath:path
                             toPath:newPath
                              error:&error] != YES) {
        DDLog(@"Unable To Move  errror %@", error.description);
        return nil;
        
    }
    return newPath;
}
//- (void)testDES:(NSString *)path {
//    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
//    NSOutputStream *outStream = [[NSOutputStream alloc] initToMemory];
//    [outStream open];
//    [inputStream open];
//    outStream.delegate = [[self class] sharedZYFileManager];
//    unsigned char buffer1[1024];
//    unsigned char buffer2[1024];
//    NSInteger r = 0;
//    while ((r = [inputStream read:buffer1 maxLength:1024]) > 0) {
//        for (NSInteger i = 0; i < r; i++) {
//            buffer2[i] = buffer1[i] == 255 ? 0 : ++buffer1[i];
//        }
//        [outStream write:buffer2 maxLength:1024];
//    }
//    [inputStream close];
//    [outStream close];
//     NSData *newData = [outStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
//    return
//}
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventEndEncountered:
        {
            NSData *newData = [aStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
            if (!newData) {
                DDLog(@"stream has no data");
            }
            else {
                
                DDLog(@"加密后%@",[[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding]);
            }
        }
            break;
            
        default:
            break;
    }
}
@end
