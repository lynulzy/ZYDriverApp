//
//  AppDelegate.h
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UINavigationController *navigationController;
    BMKMapManager *_mapManager;
}

@property (strong, nonatomic) UIWindow *window;

@end

