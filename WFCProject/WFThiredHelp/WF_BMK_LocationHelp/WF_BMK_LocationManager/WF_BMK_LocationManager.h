//
//  WF_BMK_LocationManager.h
//  WFCProject
//
//  Created by wufer on 2018/3/19.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;
@protocol WF_BMK_LocationManagerDelegate <NSObject>

-(void)activeCoordinate:(CLLocationCoordinate2D)coordinate;

-(void)backGCoordinate:(CLLocationCoordinate2D)coordinate;

@end


@interface WF_BMK_LocationManager : NSObject



@property (nonatomic,assign) NSTimeInterval locationInterval;

@property (nonatomic,readonly) CLLocationCoordinate2D lastCoordinate;

@property (nonatomic,weak) id<WF_BMK_LocationManagerDelegate>delegate;

+(WF_BMK_LocationManager *)sharedLocationManager;
/**
 开启BMK定位
 */
-(void)startLocationService;
/**
 关闭BMK定位
 */
-(void)stopLocationService;

-(void)activeCoordinate:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander;

-(void)backGCoordinate:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander;



@end
