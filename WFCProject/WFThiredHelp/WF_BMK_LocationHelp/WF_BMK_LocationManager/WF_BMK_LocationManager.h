//
//  WF_BMK_LocationManager.h
//  WFCProject
//
//  Created by wufer on 2018/3/19.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;
@interface WF_BMK_LocationManager : NSObject

@property (nonatomic,assign) BOOL isAlwaysLocation;

@property (nonatomic,assign) NSTimeInterval locationInterval;

@property (nonatomic,readonly) CLLocationCoordinate2D lastCoordinate;

+(WF_BMK_LocationManager *)sharedLocationManager;
/**
 开启BMK定位
 */
-(void)startLocationService;
/**
 关闭BMK定位
 */
-(void)stopLocationService;

-(void)getCurrentCordinate:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander;

-(void)activeCoordinate:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander;

-(void)backGCoordinate:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander;



@end
