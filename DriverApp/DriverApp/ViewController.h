//
//  ViewController.h
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYBaseViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
@interface ViewController : ZYBaseViewController{

    __weak IBOutlet BMKMapView *mapView_;
}


@end

