//
//  WF_BMK_LocationManager.h
//  WFCProject
//
//  Created by wufer on 2018/3/19.
//  Copyright © 2018年 wufer. All rights reserved.
//*****************************************************************************************************************************************************************************************
//开启后前后台默认活跃 需手动关闭
//delegate&block相对独立  数据源相同
//*****************************************************************************************************************************************************************************************


#import <Foundation/Foundation.h>

@import CoreLocation;
@protocol WFBMKLocationManagerDelegate <NSObject>
@optional
/**
 WFBMK_前台定位

 @param coordinate coordinate description
 */
-(void)WFBMK_foregroundLocation:(CLLocationCoordinate2D)coordinate;

/**
 后台定位

 @param coordinate coordinate description
 */
-(void)WFBMK_backgroundLocation:(CLLocationCoordinate2D)coordinate;

/**
 常驻定位

 @param coordinate coordinate description
 */
-(void)WFBMK_residentLocation:(CLLocationCoordinate2D)coordinate;
/**
 定位失败

 @param coordinate 最近更新经纬度信息
 @param error 失败信息
 */
-(void)WFBMK_failLocation:(CLLocationCoordinate2D)coordinate error:(NSError *)error;

@end

typedef enum {
    WFBMKLocationModeNormal = 0, //普通回调模式 根据位移距离产生回调 默认
    //TODO:TODO定时回调
    WFBMKLocationModeTImer ,        //定时回调模式 根据设置的时间定时回调
}WFBMKLocationMode;

@interface WFBMKLocationManager : NSObject

/**
 定时更新时间设置 WFBMKLocationModeNormal 设置无效
 */
@property (nonatomic,assign) NSTimeInterval locationInterval;

/**
 最近一次位置更新
 */
@property (nonatomic,strong,readonly) CLLocation* lastLocation;

/**
 定位代理 独立于Block
 */
@property (nonatomic,weak) id<WFBMKLocationManagerDelegate>delegate;

/**
 定位模式
 */
@property (nonatomic,assign)WFBMKLocationMode locationMode;

+(WFBMKLocationManager *)sharedLocationManager;
/**
 开启WFBMK定位
 */
-(void)startLocationService;
/**
 关闭WFBMK定位
 */
-(void)stopLocationService;

-(void)getCurrentLocationHander:(void(^)(CLLocationCoordinate2D coordiante,NSError *error))coordinateHander;

-(void)foregroundLocationHander:(void(^)(CLLocationCoordinate2D coordinate))coordinateHander;

-(void)backgroundLocationHander:(void(^)(CLLocationCoordinate2D coordinate))coordinateHander;

-(void)residentLocationHander:(void(^)(CLLocationCoordinate2D coordinate))coordinateHander;

-(void)failLocationHander:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander;



@end
