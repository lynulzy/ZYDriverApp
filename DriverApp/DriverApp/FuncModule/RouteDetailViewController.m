//
//  RouteDetailViewController.m
//  DriverApp
//
//  Created by lynulzy on 10/24/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "ZYDataBaseManager.h"
#import "ZYFileManager.h"
#import "ZSXJUserDefaults.h"
#import "ZSXJHTTPSession.h"
#import "MBProgressHUD.h"
@interface RouteDetailViewController ()<NSStreamDelegate>

@end
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
 @property (nonatomic, assign) BOOL uploaded;*/
@implementation RouteDetailViewController
{
    //UI
    
    __weak IBOutlet UILabel *carNumberLB;
    __weak IBOutlet UILabel *distanceLB;
    __weak IBOutlet UILabel *totalTimeLB;
    __weak IBOutlet UILabel *averageSpeedLB;
    __weak IBOutlet UILabel *topSpeedLB;
    __weak IBOutlet UILabel *remainTimeLB;
    __weak IBOutlet UILabel *recordIDLB;
    
}
@synthesize recordModel;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fillData];
}
- (void)fillData {
    carNumberLB.text = recordModel.carNum;
    distanceLB.text = [NSString stringWithFormat:@"%.2f/km",recordModel.distance];
    totalTimeLB.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",recordModel.totalTime/3600, (recordModel.totalTime%3600)/60, recordModel.totalTime%60];
    if (recordModel.distance < 0.1) {
             averageSpeedLB.text = [NSString stringWithFormat:@"0 km/h"];
    }
    else {
        averageSpeedLB.text = [NSString stringWithFormat:@"%.2f km/h",(float)recordModel.distance/(float)(recordModel.totalTime/3600)];
    }
    
    remainTimeLB.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",recordModel.remain/3600, (recordModel.remain%3600)/60, recordModel.remain%60];
    topSpeedLB.text = [NSString stringWithFormat:@"%.2f km/h",recordModel.topSpeed];
    recordIDLB.text = [NSString stringWithFormat:@"%@",recordModel.uuid];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - User Action -
- (IBAction)notSaveClicked:(id)sender {
    ////TODO: 更新本条记录
    [[ZYDataBaseManager sharedZYDataBaseManager] updateUploadStatus:NO routeID:[[ZSXJUserDefaults getCurrentRouteID] integerValue]];
    [ZSXJUserDefaults setCarNumber:nil];
    NSString *filePath = [[ZYFileManager sharedZYFileManager] generateFileToUpload];
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH_mm_ss"];
//    NSString *dateString = [formatter stringFromDate:[NSDate date]];
//    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDict));
//    NSString *version = infoDict[@"CFBundleShortVersionString"];
//    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@_%@", UDID, [ZSXJUserDefaults getCurrentUserID], dateString,version];
//    NSString *uploadPath = [[ZYFileManager sharedZYFileManager] renameFile:filePath
//                                           fileName:[NSString stringWithFormat:@"%@_%@.text",UDID,[ZSXJUserDefaults getCurrentRouteID]]
//                                        newFileName:fileName];
//    [[ZSXJHTTPSession sharedSession] uploadFile:uploadPath
//                                       fileName:fileName
//                                            URL:@"http://114.215.176.234:8080/lines/uploadfileFromAndroid.do"
//                                        success:^(NSURLSessionDataTask *task, id responseObject) {
//                                            
//                                        }
//                                        failure:^(NSURLSessionDataTask *task, NSError *theError) {
//                                            
//                                        }];
    //更新的路径保存到数据库
    [[ZYDataBaseManager sharedZYDataBaseManager] updateFilePath:filePath];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [ZSXJUserDefaults setCurrentRouteID:nil];
    }];
}
- (IBAction)uploadClicked:(id)sender {
    //上传
    NSString *filePath = [[ZYFileManager sharedZYFileManager] generateFileToUpload];
    __block NSData *postData = [self testDES:filePath];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH_mm_ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDict));
    NSString *version = infoDict[@"CFBundleShortVersionString"];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@_%@", UDID, [ZSXJUserDefaults getCurrentUserID], dateString,version];
//    NSString *uploadPath = [[ZYFileManager sharedZYFileManager] renameFile:filePath
//                                                                  fileName:[NSString stringWithFormat:@"record_%@",[ZSXJUserDefaults getCurrentRouteID]]
//                                                               newFileName:fileName];
    __weak typeof(self) weakSelf = self;
    
    DDLog(@"加密前 %@",[[NSString alloc] initWithContentsOfFile:filePath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil]);
    
//    [self testString:@"F7D29DE9-F62B-4EEA-8190-C9D1406E696F 琼YUYU5 0 1445848838 1445848852 14 7 2327 ios5 ceshi 0.000000 0.001000 0 F7D29DE9-F62B-4EEA-8190-C9D1406E696Frouteid\n38.503988 116.662472 -1.000000 0.000000 1445848850 5.000000 0 1"];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    [[ZSXJHTTPSession sharedSession] uploadFileData:postData
                                            filname:fileName URL:@"http://114.215.176.234:8080/lines/uploadfileFromAndroid.do"
                                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                                
                                                [self alertMessage:@"上传成功"];
                                                __strong typeof (weakSelf) strongSelf = weakSelf;
                                                [[ZYDataBaseManager sharedZYDataBaseManager] updateUploadStatus:YES routeID:[[ZSXJUserDefaults getCurrentRouteID] integerValue]];
                                                [ZSXJUserDefaults setCarNumber:nil];
                                                [ZSXJUserDefaults setCurrentRouteID:nil];
                                                [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                [HUD hide:YES];
                                            } failure:^(NSURLSessionDataTask *task, NSError *theError) {
                                                [self alertMessage:@"上传失败"];
                                                __strong typeof (weakSelf) strongSelf = weakSelf;
                                                [[ZYDataBaseManager sharedZYDataBaseManager] updateUploadStatus:NO routeID:[[ZSXJUserDefaults getCurrentRouteID] integerValue]];
                                                [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                [HUD hide:YES];
                                                [ZSXJUserDefaults setCarNumber:nil];
                                                [ZSXJUserDefaults setCurrentRouteID:nil];
                                            }];
//    [[ZSXJHTTPSession sharedSession] uploadFile:uploadPath
//                                       fileName:fileName
//                                            URL:@"http://114.215.176.234:8080/lines/uploadfileFromAndroid.do"
//                                        success:^(NSURLSessionDataTask *task, id responseObject) {
//                                            [self alertMessage:@"上传成功"];
//                                            __strong typeof (weakSelf) strongSelf = weakSelf;
//                                            [[ZYDataBaseManager sharedZYDataBaseManager] updateUploadStatus:YES];
//                                            [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
//                                            [HUD hide:YES];
//                                        }
//                                        failure:^(NSURLSessionDataTask *task, NSError *theError) {
//                                            [self alertMessage:@"上传失败"];
//                                            __strong typeof (weakSelf) strongSelf = weakSelf;
//                                            [[ZYDataBaseManager sharedZYDataBaseManager] updateUploadStatus:NO];
//                                            [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
//                                            [HUD hide:YES];
//                                        }];
    [[ZYDataBaseManager sharedZYDataBaseManager] updateFilePath:filePath];
    
}

- (void)testString:(NSString *)string {
    NSMutableData *data = [[NSMutableData alloc] init];
    //string 转data
    NSData *testData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:testData];
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
    if (!data) {
        DDLog(@"stream has no data");
    }
    else {
        
        DDLog(@"加密后%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    [inputStream close];
    [outStream close];
    

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
