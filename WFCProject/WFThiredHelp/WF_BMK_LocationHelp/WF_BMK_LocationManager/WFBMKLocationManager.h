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
    WFBMKLocationModeNormal = 0,            //普通回调模式 根据位移距离产生回调  调用频率不稳定 默认
    WFBMKLocationModeTimerNormal,         //定时回调模式  根据位移距离修改当前经纬度  调用频率稳定
    WFBMKLocationModeTimerRepeat          //定时回调模式 根据设置的时间重复开关定位
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
@property (nonatomic,assign) WFBMKLocationMode locationMode;

/**
 仅在iOS8以后有效 控制是否显示定位蓝条 默认显示 关闭时会在进入后台模式时进行询问定位调用 选择后蓝条隐藏
 */
@property (nonatomic,assign) BOOL showTheBlueAlert;

+(WFBMKLocationManager *)sharedLocationManager;
/**
 开启WFBMK定位
 */
-(void)startLocationService;
/**
 关闭WFBMK定位
 */
-(void)stopLocationService;

/**
 获取当前经纬度地址

 @param coordinateHander coordinateHander description
 */
-(void)getCurrentLocationHander:(void(^)(CLLocationCoordinate2D coordiante,NSError *error))coordinateHander;

/**
 前台获取经纬度地址 调试阶段 后期剔除

 @param coordinateHander coordinateHander description
 */
-(void)foregroundLocationHander:(void(^)(CLLocationCoordinate2D coordinate))coordinateHander;

/**
 后台获取经纬度地址 调试阶段 后期剔除

 @param coordinateHander coordinateHander description
 */
-(void)backgroundLocationHander:(void(^)(CLLocationCoordinate2D coordinate))coordinateHander;

/**
 常驻经纬度地址

 @param coordinateHander coordinateHander description
 */
-(void)residentLocationHander:(void(^)(CLLocationCoordinate2D coordinate))coordinateHander;

/**
 经纬度地址获取失败

 @param coordinateHander coordinateHander description
 */
-(void)failLocationHander:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander;



@end
