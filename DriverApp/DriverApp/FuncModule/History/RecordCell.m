//
//  RecordCell.m
//  DriverApp
//
//  Created by lynulzy on 10/24/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "RecordCell.h"
#import "ZYDataBaseManager.h"
#import "ZYFileManager.h"
#import "ZSXJUserDefaults.h"
#import "MBProgressHUD.h"
#import "ZSXJHTTPSession.h"
#import "Define.h"
@implementation RecordCell
{
    RecordModel *theRecord;
}
@synthesize recordIdLB;
@synthesize startTimeLB;
@synthesize distanceLB;
@synthesize totalTimeLB;
@synthesize uploadBT;
#define UPLOAD_COLOR   [UIColor colorWithRed:0.3 green:0.33 blue:0.35 alpha:1]
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)fillDataWithModel:(RecordModel *)record {
    theRecord = record;
    //ID
    recordIdLB.text = [NSString stringWithFormat:@"%@",record.uuid];
    //开始时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    startTimeLB.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:record.startTime]];
    //里程
    distanceLB.text = [NSString stringWithFormat:@"%.2f/km",record.distance];
    //时长
    totalTimeLB.text = [NSString stringWithFormat:@"%.2d: %.2d : %.2d",record.totalTime/3600, (record.totalTime)%3600/60, record.totalTime%60];
    
    //TODO:
    //上传按钮
    if (!record.uploaded) {
        [uploadBT setTitle:@"上传" forState:UIControlStateNormal];
        [uploadBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [uploadBT setBackgroundColor:UPLOAD_COLOR];
    }
    else {
        [uploadBT setTitle:@"已上传" forState:UIControlStateNormal];
        [uploadBT setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [uploadBT setBackgroundColor:[UIColor whiteColor]];
    }
    
    
}
- (IBAction)uploadClicked:(id)sender {
    DDLog(@"select record id %ld", (long)theRecord.recordID);
    //上传按钮
    NSString *filePath = [[ZYDataBaseManager sharedZYDataBaseManager] queryPath:theRecord.recordID];
    NSString *fileName = [NSString stringWithFormat:@"record_%d",theRecord.recordID];
    if (filePath.length < 1 || fileName.length < 1) {
        [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"请先结束当前记录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }
    __block NSData *postData = [self testDES:filePath];
    DDLog(@"filePath  %@", filePath);
    DDLog(@"fileName  %@", fileName);
    //构造文件名
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH_mm_ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDict));
    NSString *version = infoDict[@"CFBundleShortVersionString"];
    //将要上传的文件名
    NSString *uploadFileName = [NSString stringWithFormat:@"%@_%@_%@_%@", UDID, [ZSXJUserDefaults getCurrentUserID], dateString,version];
//    NSString *uploadPath = [[ZYFileManager sharedZYFileManager] renameFile:filePath
//                                                                  fileName:fileName
//                                                               newFileName:uploadFileName];
    DDLog(@"加密前 %@",[[NSString alloc] initWithContentsOfFile:filePath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil]);
    
    //    [self testString:@"F7D29DE9-F62B-4EEA-8190-C9D1406E696F 琼YUYU5 0 1445848838 1445848852 14 7 2327 ios5 ceshi 0.000000 0.001000 0 F7D29DE9-F62B-4EEA-8190-C9D1406E696Frouteid\n38.503988 116.662472 -1.000000 0.000000 1445848850 5.000000 0 1"];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
    [HUD show:YES];
    __weak typeof(self) weakSelf = self;
    [[ZSXJHTTPSession sharedSession] uploadFileData:postData
                                            filname:uploadFileName URL:@"http://114.215.176.234:8080/lines/uploadfileFromAndroid.do"
                                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                                [HUD hide:YES];
                                                [[ZYDataBaseManager sharedZYDataBaseManager] updateUploadStatus:YES routeID:theRecord.recordID];
                                                __strong typeof (weakSelf) strongSelf = weakSelf;
                                                [strongSelf postNoti];
                                                [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"上传成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                                                
//                                                [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                
                                            } failure:^(NSURLSessionDataTask *task, NSError *theError) {
                                                [HUD hide:YES];
                                                [[ZYDataBaseManager sharedZYDataBaseManager] updateUploadStatus:NO routeID:theRecord.recordID];
                                                __strong typeof (weakSelf) strongSelf = weakSelf;
                                                [strongSelf postNoti];
                                                NSString *msg = [[theError userInfo] objectForKey:@"msg"];
                                                [[[UIAlertView alloc] initWithTitle:@"提醒" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                                                
                                                
                                            }];

    
    
    if (theRecord.recordID%2 == 0) {
        [uploadBT setTitle:@"上传" forState:UIControlStateNormal];
        [uploadBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [uploadBT setBackgroundColor:UPLOAD_COLOR];
    }
    else {
        [uploadBT setTitle:@"已上传" forState:UIControlStateNormal];
        [uploadBT setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [uploadBT setBackgroundColor:[UIColor whiteColor]];
    }
    
}
- (void)postNoti {
    NSNotification *refreshNoti = [[NSNotification alloc] initWithName:NOTI_NAME_REFRESH_INFO object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNoti];
}
- (NSData *)testDES:(NSString *)path {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
    NSOutputStream *outStream = [[NSOutputStream alloc] initToMemory];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outStream open];
    [inputStream open];
    //    outStream.delegate = self;
    //    inputStream.delegate = self;
    unsigned char buffer1[1024];
    unsigned char buffer2[1024];
    NSInteger r = 0;
    while ((r = [inputStream read:buffer1 maxLength:1024]) > 0) {
        for (NSInteger i = 0; i < r; i++) {
            buffer2[i] = buffer1[i] == 255 ? 0 : ++buffer1[i];
        }
        [outStream write:buffer2 maxLength:1024];
        [data appendBytes:buffer2 length:r];
    }
    [inputStream close];
    [outStream close];
    if (!data) {
        DDLog(@"stream has no data");
    }
    else {
        
        DDLog(@"加密后%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    return data;
    
}

@end
