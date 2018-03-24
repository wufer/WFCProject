//
//  WF_BMK_LocationManager.m
//  WFCProject
//
//  Created by wufer on 2018/3/19.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import "WFBMKLocationManager.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "WFBackgroundTaskManager.h"
@interface WFBMKLocationManager ()<BMKLocationServiceDelegate>

@property (nonatomic,strong) BMKLocationService *locationService;
@property (nonatomic,strong,readwrite) CLLocation *lastLocation;
@property (nonatomic,strong) WFBackgroundTaskManager *bgTask;
@property (nonatomic,assign) BOOL isBackGroundLocation;
@property (nonatomic,assign) BOOL isStartLocation;

@property (nonatomic,strong) NSTimer *restaertTimer;
@property (nonatomic,assign) NSTimeInterval nowLocationTime;
@property (nonatomic,assign) NSTimeInterval lastLocationTime;
@property (nonatomic,strong) NSTimer *backgroundLocationTimer;


@property (nonatomic,copy) void(^getCurrentLocationHander) (CLLocationCoordinate2D coordinate,NSError *rerror);
@property (nonatomic,copy) void (^foregroundLocationHander)(CLLocationCoordinate2D coordinate);
@property (nonatomic,copy) void (^backgroundLocationHander)(CLLocationCoordinate2D coordinate);
@property (nonatomic,copy) void(^residentLocationHander)(CLLocationCoordinate2D coordinate);
@property (nonatomic,copy) void(^failLocationHander)(CLLocationCoordinate2D coordiante,NSError *error);

@end
static CLLocationManager *_clLocationManager;//系统定位管理访问相关定位权限
@implementation WFBMKLocationManager
#pragma mark - LifeCycle
+(WFBMKLocationManager *)sharedLocationManager{
    static WFBMKLocationManager *locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[WFBMKLocationManager alloc]init];
    });
    return locationManager;
}

-(instancetype)init{
    if (self = [super init]) {
        _isBackGroundLocation = NO;
        _isStartLocation = NO;
        _showTheBlueAlert = YES;
        self.locationService = [[BMKLocationService alloc]init];
        if (!self.locationInterval) {//当用户设置timerMode时提供默认回调时间
            self.locationInterval = 30.0f;
        }
        self.locationService.pausesLocationUpdatesAutomatically = NO;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=9.0) {
            self.locationService.allowsBackgroundLocationUpdates = YES;
        }
        self.locationService.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationService.distanceFilter = 10;
        _clLocationManager = [[CLLocationManager alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}
-(void)dealloc{
    if (self.restaertTimer) {
        [self.restaertTimer invalidate];
        self.restaertTimer = nil;
    }
    if (self.backgroundLocationTimer) {
        [self.backgroundLocationTimer invalidate];
        self.backgroundLocationTimer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Custom Accessors
-(void)setLocationInterval:(NSTimeInterval)locationInterval{
    _locationInterval = locationInterval;
    if (self.backgroundLocationTimer) {//重新设置定时器时间 停止当前计时器
        [self.backgroundLocationTimer invalidate];
        self.backgroundLocationTimer = nil;
    }
}
#pragma mark - Public
-(void)startLocationService{
    NSLog(@"WFBMK location start");
    self.nowLocationTime = [[NSDate date] timeIntervalSince1970];
        if (![self checkCLAuthorizationStatus]) {
            NSLog(@"定位服务未开启");
            _isStartLocation = NO;
            return;
        }
        _isStartLocation = YES;
        self.locationService.delegate = self;
        [self.locationService startUserLocationService];
}
-(void)stopLocationService{
     NSLog(@"WFBNK location stop");
    if (self.backgroundLocationTimer) {
        [self.backgroundLocationTimer invalidate];
        self.backgroundLocationTimer = nil;
    }
    if (self.restaertTimer) {
        [self.restaertTimer invalidate];
        self.restaertTimer = nil;
    }
    self.locationService.delegate = nil;
    _isStartLocation = NO;
    [[WFBackgroundTaskManager sharedBackgroundTaskManager] endAllBackgroundTasks];
    [self.locationService stopUserLocationService];
}
-(void)foregroundLocationHander:(void(^)(CLLocationCoordinate2D coordinate))coordinateHander{
    if (![self checkCLAuthorizationStatus]) {
        return;
    }
    _foregroundLocationHander = [coordinateHander copy];
}
-(void)backgroundLocationHander:(void (^)(CLLocationCoordinate2D))coordinateHander{
    if (![self checkCLAuthorizationStatus]) {
        return;
    }
    _backgroundLocationHander = [coordinateHander copy];
}
-(void)residentLocationHander:(void (^)(CLLocationCoordinate2D))coordinateHander{
    if (![self checkCLAuthorizationStatus]) {
        return;
    }
    _residentLocationHander = [coordinateHander copy];
}
-(void)failLocationHander:(void (^)(CLLocationCoordinate2D, NSError *))coordinateHander{
    if (![self checkCLAuthorizationStatus]) {
        return;
    }
    _failLocationHander = [coordinateHander copy];
}
-(void)getCurrentLocationHander:(void (^)(CLLocationCoordinate2D, NSError *))coordinateHander{
    if (![self checkCLAuthorizationStatus]) {
        return;
    }
    _getCurrentLocationHander = [coordinateHander copy];
    if (!_isStartLocation) {
        [self startLocationService];
    }
}

#pragma mark - Private
-(BOOL)checkCLAuthorizationStatus{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"定位服务被禁止");
        return NO;
    }else{
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
            NSLog(@"请开启定位服务");
            return NO;
        }
    }
    return YES;
}

-(void)restartLocationUpdates{
    NSLog(@"定位重启");
    if (self.restaertTimer) {
        [self.restaertTimer invalidate];
        self.restaertTimer = nil;
    }
    [self startLocationService];
}

-(void)addBackgroundTask{
    self.bgTask = [WFBackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
}

-(void)applicationEnterBackground{
     NSLog(@"前台操作 切换后台模式");
    _isBackGroundLocation = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0 && self.showTheBlueAlert) {
           [_clLocationManager requestAlwaysAuthorization];
    }
    if (_isStartLocation) {
        [self addBackgroundTask];
        [self startLocationService];//重启一次定位服务保证定时器开启
    }
}

-(void)applicationBecomeActive{
    NSLog(@"前台操作 切换前台模式");
    _isBackGroundLocation = NO;
    if (self.backgroundLocationTimer) {
        [self.backgroundLocationTimer invalidate];
        self.backgroundLocationTimer = nil;
    }
    if (self.restaertTimer) {
        [self.restaertTimer invalidate];
        self.restaertTimer = nil;
    }
    [[WFBackgroundTaskManager sharedBackgroundTaskManager]endAllBackgroundTasks];
    if (_isStartLocation) {
        [self startLocationService];
    }
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    CLLocationCoordinate2D locationCoordiate ;
    if (_lastLocation) {
        if (userLocation.location.horizontalAccuracy<40 && userLocation.location.horizontalAccuracy>0 ){//保证定位精度
            self.lastLocation = userLocation.location;
            locationCoordiate = userLocation.location.coordinate;
        }else{//当精度存在较大误差时 不对当前经纬度进行更新
            locationCoordiate = self.lastLocation.coordinate;
        }
    }else{
        self.lastLocation = userLocation.location;
        locationCoordiate = userLocation.location.coordinate;
    }
    self.lastLocationTime = [[NSDate date] timeIntervalSince1970];//记录最近更新时间
    if (_getCurrentLocationHander) {
        _getCurrentLocationHander(locationCoordiate,nil);
        _getCurrentLocationHander = nil;
    }
    if (self.isBackGroundLocation) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(WFBMK_backgroundLocation:)]) {
                [self.delegate WFBMK_backgroundLocation:locationCoordiate];
            }
            if ([self.delegate respondsToSelector:@selector(WFBMK_residentLocation:)]) {
                [self.delegate WFBMK_residentLocation:locationCoordiate];
            }
        }
        if (_backgroundLocationHander) {
            _backgroundLocationHander(locationCoordiate);
        }
        if (_residentLocationHander) {
            _residentLocationHander(locationCoordiate);
        }
        if (self.restaertTimer) {
            return;
        }else{
            NSLog(@"开启定时器定时重启保证应用活跃");
            [self addBackgroundTask];//加入后台任务
            self.restaertTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:self.restaertTimer forMode:NSRunLoopCommonModes];
        }
    }else{
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(WFBMK_residentLocation:)]) {
                [self.delegate WFBMK_residentLocation:locationCoordiate];
            }
            if ([self.delegate respondsToSelector:@selector(WFBMK_foregroundLocation:)]) {
                [self.delegate WFBMK_foregroundLocation:locationCoordiate];
            }
        }
        if (_foregroundLocationHander) {
            _foregroundLocationHander(locationCoordiate);
        }
        if (_residentLocationHander) {
            _residentLocationHander(locationCoordiate);
        }
    }
}

-(void)didFailToLocateUserWithError:(NSError *)error{
    CLLocationCoordinate2D coordinate;
    if (_lastLocation) {
        coordinate = _lastLocation.coordinate;
    }else{
        coordinate = CLLocationCoordinate2DMake(0, 0);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(WFBMK_failLocation:error:)]) {
        [self.delegate WFBMK_failLocation:coordinate error:error];
    }
    if (self.failLocationHander) {
        self.failLocationHander(coordinate, error);
    }
    if (_getCurrentLocationHander) {
        if (_lastLocation) {
        _getCurrentLocationHander(coordinate,error);
        }else{
        _getCurrentLocationHander(CLLocationCoordinate2DMake(0, 0),error);
        }
    }
}



@end
