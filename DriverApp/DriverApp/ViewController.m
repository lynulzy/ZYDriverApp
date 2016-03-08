//
//  ViewController.m
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "ViewController.h"
#import "Define.h"
#import "LoginViewController.h"
#import "ZSXJUserDefaults.h"
#import "ActionSheetPicker.h"
#import "ZYFileManager.h"
#import "ZYDataBaseManager.h"
#import "RouteDetailViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKMultiPoint.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "FMDatabase.h"
#define TAG_StartRecord_View        1000
#define TAG_Recording_View          2000
#define TAG_Map_Containrer_View     3000
#define TAG_FINISHED_AV             4000
#define TAG_LOGOUT_AV               4001

#define DISTANCE_FILTER             100
typedef NS_ENUM(NSInteger, Tracking_Status) {
    TRACKING_START = 1,
    TRACKING_SUSPEND = 2,
    TRACKING_FINISHED = 3,
};
@interface ViewController ()<UITextFieldDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *provinceBT;
@property (weak, nonatomic) IBOutlet UITextField *carNumberTF;
@property (weak, nonatomic) IBOutlet UIButton *suspenBT;
@property (weak, nonatomic) IBOutlet UILabel *carNumberLB;//!< 保存用户已经输入的车牌号
@property (weak, nonatomic) IBOutlet UIView *starRecordView;
@property (weak, nonatomic) IBOutlet UIView *isRecordingView;
@property (nonatomic,assign) float currentDistance;

@end

@implementation ViewController
{
    BMKLocationService *locService_;
    CLLocation *latestLocation_;
    CLLocationSpeed currentTopSpeed;
    BOOL startLocate;       //开始定位
    BOOL finishedLocate;    //结束定位
    NSTimer *theTimer;//!<计时器
    float totalDistance_; //总里程单位:km
    __weak IBOutlet UILabel *distaceLB;
    __weak IBOutlet UILabel *totalTimeLB;
}
@synthesize currentDistance;
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDistance:)
                                                 name:NOTI_NAME_UPDATE_INFO
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveRecordingStatus:)
                                                 name:NOTI_NAME_TERMINATE
                                               object:nil];
    finishedLocate = [ZSXJUserDefaults getCurrentRouteID].length < 1 ? YES : NO;
    startLocate = [ZSXJUserDefaults getCurrentRouteID].length < 1 ? NO : YES;
    currentDistance = 0.0;
    totalDistance_ = 0.0;
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //判断是否登录过
    if ([ZSXJUserDefaults getCurrentUserID].length == 0) {
        //未登录
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:LOGIN_SB_IDENTIFIER];
        [self.navigationController presentViewController:loginVC animated:YES completion:nil];
    }
    
    //监听键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
//保存断点状态
- (void)saveRecordingStatus:(NSNotification *)noti {
    if (!finishedLocate) {
        NSNumber *status = [ZSXJUserDefaults getSuspendTime]!=0 ? @(1) : @(2);//1:暂停状态:2 记录中
        [ZSXJUserDefaults setRecordingStatus:status];
        return;
    }
    //未开始
    [ZSXJUserDefaults setRecordingStatus:@(0)];
   
}
//更新从数据库得到的数据
- (void)updateDistance:(NSNotification *)noti {
    DDLog(@"更新%@",noti.userInfo);
    NSInteger totalTime = [noti.userInfo[@"totalTime"] integerValue];
    float distance = [noti.userInfo[@"distance"] floatValue];
    totalDistance_ = distance;
    [self updateTimeLabel:totalTime distance:distance];
}
- (void)viewWillAppear:(BOOL)animated {
    [mapView_ viewWillAppear];
    [self loadMapViewService];
    mapView_.delegate = self;
    [mapView_ setShowsUserLocation:YES];
    mapView_.userTrackingMode = BMKUserTrackingModeFollow;
//    mapView_.showsUserLocation = YES;
//    mapView_.userTrackingMode = BMKUserTrackingModeFollow;
    [self setupUI];
    
}
- (void)updateTimeLabel:(NSInteger)totalTime distance:(float)distance {
    totalTimeLB.text = [NSString stringWithFormat:@"时长:%@",[NSString stringWithFormat:@"%.2d: %.2d : %.2d",totalTime/3600, (totalTime)%3600/60, totalTime%60]];
//    if (distance == 0) {
    //距离仅接收从数据库返回的数据
        distaceLB.text = [NSString stringWithFormat:@"里程:%.2fkm",totalDistance_];
//    }
//    else {
//        distaceLB.text = [NSString stringWithFormat:@"里程:%.2fkm",distance];
//    }
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [mapView_ viewWillDisappear];
    [self.view endEditing:YES];
    mapView_.delegate = nil;
    locService_.delegate = nil;
    
    
    //更新暂停状态
    if ([ZSXJUserDefaults getSuspendTime]) {
        [self.suspenBT setTitle:@"继续" forState:UIControlStateNormal];
    }
    else {
        [self.suspenBT setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
- (void)dealloc {
    mapView_.delegate = nil;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
}
- (void)setupUI {
    //判断是否保存车牌号
    if ([ZSXJUserDefaults getCarNumber].length < 1) {
        //没开始
        [self.view bringSubviewToFront:self.starRecordView];
        self.starRecordView.hidden = NO;
        self.isRecordingView.hidden = YES;
        [self updateTimeLabel:0 distance:0];
        
    }
    else {
        self.carNumberLB.text = [ZSXJUserDefaults getCarNumber];
        self.isRecordingView.hidden = NO;
        self.starRecordView.hidden = YES;
        if ([ZSXJUserDefaults getSuspendTime] == 0 && [ZSXJUserDefaults getRecordingStatus] == 2) {
            //不是暂停状态
            [self startTimer];
        }
        else if ([ZSXJUserDefaults getRecordingStatus] == 1) {
            //挂起状态
            [self.suspenBT setTitle:@"继续记录" forState:UIControlStateNormal];
            [[ZYDataBaseManager sharedZYDataBaseManager] updateRemain];
        }
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [mapView_ viewWillDisappear];
    mapView_.delegate = nil;
}
- (void)loadMapViewService {
#warning 调整地图准确度
    locService_ = [[BMKLocationService alloc] init];
    locService_.delegate = self;
    //定位精度设置
    locService_.distanceFilter = DISTANCE_FILTER;
    locService_.headingFilter = 1.0;
    locService_.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locService_.pausesLocationUpdatesAutomatically = NO;
    locService_.allowsBackgroundLocationUpdates = YES;
    [locService_ startUserLocationService];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Textfield Delegate
static float f = 0.0;
- (void)keyboardWillShow:(NSNotification *)info
{
    CGRect keyboardBounds = [[[info userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    f =  keyboardBounds.size.height;
    self.view.frame = CGRectMake(0, -f, self.view.frame.size.width, self.view.frame.size.height);
}
- (void)keyboardWillHide:(NSNotification *)info
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.view endEditing:YES];
}
- (BOOL)containSpecialCharacter:(NSString *)str
{
    //***需要过滤的特殊字符：~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€。
    NSRange specialCharacterRange = [str rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$€,，.。！!@？?"]];
    if (NSNotFound == specialCharacterRange.location) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}
#pragma mark - User Action
- (IBAction)logoutClick:(id)sender {
    //判断已经登录
    if ([ZSXJUserDefaults getCurrentUserID].length < 1) {
        DDLog(@"未登录!!!");
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"退出登录功能将不再记录您的行车轨迹，确定退出？" delegate:self cancelButtonTitle:@"不了" otherButtonTitles:@"退出", nil];
    alert.tag = TAG_LOGOUT_AV;
    [alert show];
}

- (IBAction)startRecordClicked:(id)sender {
    [self.view endEditing:YES];
    startLocate = YES;
    finishedLocate = NO;
    totalDistance_ = 0;
    if (![self.provinceBT.titleLabel.text isEqualToString:@"省份"] && self.carNumberTF.text.length > 0) {
        if (self.carNumberTF.text.length > 6 || [self containSpecialCharacter:self.carNumberTF.text]) {
            [self alertMessage:@"请输入正确的车牌号"];
            return;
        }
        //用户填了车牌号
        NSString *carNum = [NSString stringWithFormat:@"%@%@", self.provinceBT.titleLabel.text, self.carNumberTF.text];
            //保存车牌号
        [ZSXJUserDefaults setCarNumber:carNum];
        DDLog(@"车牌号:%@",carNum);
        self.carNumberLB.text = carNum;
            //更新View
        self.isRecordingView.hidden = NO;
        self.starRecordView.hidden = YES;
            //在数据库中新建一条记录
        [[ZYDataBaseManager sharedZYDataBaseManager] insertNewRow];
        //更新本地的路径状态
        [ZSXJUserDefaults setRouteStatus:[NSString stringWithFormat:@"%ld", (long)TRACKING_START]];
        [ZSXJUserDefaults setStartTime:[NSDate date]];
        //开始计时
        [self startTimer];
        DDLog(@"latest route id %@",[ZSXJUserDefaults getCurrentRouteID]);
    }
    else
    {
        [self alertMessage:@"请先填写车牌号！"];
        return;
    }
}
- (void)startTimer {
    //开启计时器
    theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                target:self
                                              selector:@selector(updateTimer:)
                                              userInfo:nil
                                               repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:theTimer forMode:NSDefaultRunLoopMode];
}
- (void)updateTimer:(NSTimer *)sender{
    if ([[ZSXJUserDefaults getStartTime] isKindOfClass:[NSNumber class]]) {
        return;
    }
    NSInteger deltaTime = [sender.fireDate timeIntervalSinceDate:[ZSXJUserDefaults getStartTime]];
    if ([NSThread isMainThread]) {
        [self updateTimeLabel:deltaTime distance:0.0f];
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateTimeLabel:deltaTime distance:0.0f];
        });
    }
}
- (void)endTimer {
    if (theTimer) {
        [theTimer invalidate];
        return;
    }
    DDLog(@"timer不存在");
}
- (IBAction)finishRecordingClicked:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"确定要停止记录吗？" delegate:self cancelButtonTitle:@"不了" otherButtonTitles:@"确定", nil];
    alert.tag = TAG_FINISHED_AV;
    [alert show];
}
- (IBAction)suspendRecordingClicked:(id)sender {
    if ([ZSXJUserDefaults getSuspendTime] == 0) {
        [self.suspenBT setTitle:@"继续记录" forState:UIControlStateNormal];
        [ZSXJUserDefaults setRecordingStatus:@(1)];
        //暂停操作
        [self endTimer];
        NSNumber *suspendTimeStamp = [[NSNumber alloc] initWithInteger:[[NSDate date] timeIntervalSince1970]] ;
        [ZSXJUserDefaults setSuspendTime:suspendTimeStamp];
        DDLog(@"suspend timeStamp %d",[ZSXJUserDefaults getSuspendTime]);
        
    }
    else {
        [self.suspenBT setTitle:@"暂停记录" forState:UIControlStateNormal];
        [ZSXJUserDefaults setRecordingStatus:@(2)];
        //本次暂停结束
        [self startTimer];
        //更新数据库
        [[ZYDataBaseManager sharedZYDataBaseManager] updateRemain];
        [ZSXJUserDefaults setSuspendTime:nil];
    }
    
}
- (IBAction)provinceBTClicked:(id)sender {
    [self.view endEditing:YES];
    NSArray *provinceArray = [NSArray arrayWithObjects:@"京", @"津", @"沪", @"渝", @"冀",
                              @"晋", @"辽", @"吉", @"黑",
                              @"苏", @"浙", @"皖", @"闽",
                              @"赣", @"鲁", @"豫", @"鄂",
                              @"湘", @"粤", @"琼", @"川",
                              @"黔", @"滇", @"陕", @"甘",
                              @"青", @"藏", @"桂", @"内蒙古",
                              @"宁", @"新", @"台", @"香港",
                              @"澳", nil];
    ActionSheetStringPicker *stringPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"请选择车牌省份简称"
                                                                                      rows:provinceArray
                                                                          initialSelection:1
                                                                                 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                                     [self.provinceBT setTitle:provinceArray[selectedIndex]
                                                                                                      forState:UIControlStateNormal];
                                                                                     DDLog(@"selected %@",self.provinceBT.titleLabel.text);
                                                                                     
    }
                                                                               cancelBlock:^(ActionSheetStringPicker *picker) {
        DDLog(@"取消选择");
    } origin:self.view];
    [stringPicker showActionSheetPicker];
}
#pragma mark - UIAlerView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_FINISHED_AV) {
        if (buttonIndex == 1) {
            /*******
             清空寄存器
             *******
             CLLocation *latestLocation_;
             CLLocationSpeed currentTopSpeed;
             BOOL startLocate;       //开始定位
             BOOL finishedLocate;    //结束定位
             NSTimer *theTimer;//!<计时器
             float totalDistance_; //总里程单位:km
             */
            
            //确认结束
            [self endTimer];
            [ZSXJUserDefaults setStartTime:nil];
            latestLocation_ = nil;
            currentDistance = 0.0;
            startLocate = NO;
            finishedLocate = YES;
            totalDistance_ = 0;
            //清除记录断点
            [ZSXJUserDefaults setSuspendTime:nil];
            [ZSXJUserDefaults setRouteStatus:[NSString stringWithFormat:@"%ld",(long)TRACKING_FINISHED]];
            [[ZYDataBaseManager sharedZYDataBaseManager] updateWhenfinished];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            UINavigationController *routeNav = [sb instantiateViewControllerWithIdentifier:@"recordDetailNavigation"];
            RouteDetailViewController *routeVC = [routeNav.viewControllers firstObject];
            RecordModel *rm = [[ZYDataBaseManager sharedZYDataBaseManager] generateCurrentRouteModel];
            routeVC.recordModel = rm;
            [self presentViewController:routeNav animated:YES completion:nil];
            
        }
        return;
    }
    if (alertView.tag == TAG_LOGOUT_AV) {
        if (buttonIndex == 1) {
            //退出
            UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:LOGIN_SB_IDENTIFIER];
            [self.navigationController presentViewController:loginVC animated:YES completion:^{
                [ZSXJUserDefaults setCarNumber:nil];
                [ZSXJUserDefaults setCurrentRouteID:nil];
                [ZSXJUserDefaults setCurrentUserID:nil];
            }];
        }
        else {
            //不退出
        }
        return;
    }
}
#pragma mark - Map View Delegate

#pragma mark - Location Delegate

- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    DDLog(@"Heading is %@",userLocation.heading);
    [mapView_ updateLocationData:userLocation];
    [self updateUserLocationToFile:userLocation];
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [mapView_ updateLocationData:userLocation];
#ifdef DEBUG    
    
//    self.title = [NSString stringWithFormat:@"heading %f",userLocation.heading.headingAccuracy];
    DDLog(@"*****Heading Accuracy  %f ******************update location lat %f, long %f speed %f", userLocation.heading.headingAccuracy,userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude, userLocation.location.speed);
#endif
    [self updateUserLocationToFile:userLocation];
}
- (void)updateUserLocationToFile:(BMKUserLocation *)userLocation {
    
    DDLog(@"heading description %@", userLocation.description);
    if ([ZSXJUserDefaults getCurrentUserID].length < 1 || !userLocation.updating) {
        //未登录
        return;
    }
    //[ZSXJUserDefaults getSuspendTime] == 0 -- 未暂停
    if ([ZSXJUserDefaults getSuspendTime] == 0 &&startLocate && !finishedLocate && (latestLocation_.coordinate.latitude != userLocation.location.coordinate.latitude || latestLocation_.coordinate.longitude != userLocation.location.coordinate.longitude)) {
        //写入文件
        [[ZYFileManager sharedZYFileManager] writeRecord:userLocation.location start:latestLocation_?YES:NO];
    }
    else {
        return;
    }
    if (![[ZSXJUserDefaults getStartTime] isKindOfClass:[NSNumber class]]) {
        NSInteger delttime = [theTimer.fireDate timeIntervalSinceDate:[ZSXJUserDefaults getStartTime]];
        if (delttime%3 != 0) {
            return;
        }
    }
    DDLog(@" # recorded  latest %f,%f  now %f,%f", latestLocation_.coordinate.latitude, latestLocation_.coordinate.longitude, userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    if (!latestLocation_) {
        latestLocation_ = userLocation.location;
        return;
    }
    //更新最高速度
    currentTopSpeed  = userLocation.location.speed > currentTopSpeed ? userLocation.location.speed : currentTopSpeed;
    
    //降低精度
    CLLocationCoordinate2D coorLatest = CLLocationCoordinate2DMake([[NSString stringWithFormat:@"%.4f",latestLocation_.coordinate.latitude] floatValue], [[NSString stringWithFormat:@"%.4f",latestLocation_.coordinate.longitude] floatValue]);
    CLLocationCoordinate2D coorNow = CLLocationCoordinate2DMake([[NSString stringWithFormat:@"%.4f",userLocation.location.coordinate.latitude] floatValue], [[NSString stringWithFormat:@"%.4f",userLocation.location.coordinate.longitude] floatValue]);
    
    BMKMapPoint last = BMKMapPointForCoordinate(coorLatest);
    BMKMapPoint new = BMKMapPointForCoordinate(coorNow);
    CLLocationDistance distance = BMKMetersBetweenMapPoints(last, new);
    
    DDLog(@"distance %f", distance);
//    if (distance  > DISTANCE_FILTER * 1.5) {
    if (distance > 3000) {
        latestLocation_ = userLocation.location;
        return;
    }
    if (distance > 0) {
        DDLog(@"# recorded  updated distance %f",distance);
        DDLog(@"# recorded  new latest location %f,%f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        //单位：米
        currentDistance = currentDistance + distance;
        latestLocation_ = userLocation.location;
        //更新行驶距离[数据库]
        totalDistance_ = currentDistance;
        [[ZYDataBaseManager sharedZYDataBaseManager] updateDistance:totalDistance_ topSpeed:currentTopSpeed];
    }
}

@end
