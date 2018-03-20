//
//  WF_BMK_LocationManager.m
//  WFCProject
//
//  Created by wufer on 2018/3/19.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import "WF_BMK_LocationManager.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "WFBackgroundTaskManager.h"
typedef enum {
    onceLocationCoordinateType = 0,
    activeLocationCoordinateType,
    backgroundlocationCoordinateType
}WFLocationState;
@interface WF_BMK_LocationManager ()<BMKLocationServiceDelegate>
@property (nonatomic,strong) BMKLocationService *locationService;
@property (nonatomic,assign) NSTimeInterval nowLocationTime;
@property (nonatomic,assign) NSTimeInterval lastLocationTime;
@property (nonatomic,strong) NSTimer *backgroundLocationTimer;
@property (nonatomic,strong) NSTimer *restaertTimer;
@property (nonatomic,strong) WFBackgroundTaskManager *bgTask;
@property (nonatomic,readwrite) CLLocationCoordinate2D lastCoordinate;
@property (nonatomic,assign) BOOL isBackGroundLocation;
@property (nonatomic,assign) WFLocationState locationSate;
@property (nonatomic,copy) void(^oncecoordinatehander) (CLLocationCoordinate2D coordinate,NSError *rerror);
@property (nonatomic,copy) void (^activelocationCoordinateHander) (CLLocationCoordinate2D coordinate,NSError *error);
@property (nonatomic,copy) void (^backgroundLocationHander) (CLLocationCoordinate2D coordinate,NSError *error);

@end
static CLLocationManager *_clLocationManager;//系统定位管理访问相关定位权限
@implementation WF_BMK_LocationManager
#pragma mark - LifeCycle
+(WF_BMK_LocationManager *)sharedLocationManager{
    static WF_BMK_LocationManager *locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[WF_BMK_LocationManager alloc]init];
    });
    return locationManager;
}

-(instancetype)init{
    if (self = [super init]) {
        _isAlwaysLocation = NO;
        _isBackGroundLocation = NO;
        _locationSate = [self checkLocationState];
        self.locationService = [[BMKLocationService alloc]init];
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
#pragma mark Custom Accessors

-(void)setIsAlwaysLocation:(BOOL)isAlwaysLocation{
    _isAlwaysLocation = isAlwaysLocation;
    if (isAlwaysLocation) {
        if (!self.locationInterval) {
            self.locationInterval = 30.0f;
        }
        self.locationService.pausesLocationUpdatesAutomatically = NO;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=9.0) {
            self.locationService.allowsBackgroundLocationUpdates = YES;
        }
    }else{
        self.locationInterval = 0.0f;
        self.locationService.pausesLocationUpdatesAutomatically = YES;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>9.0) {
            self.locationService.allowsBackgroundLocationUpdates = NO;
        }
    }
}
-(void)setLocationInterval:(NSTimeInterval)locationInterval{
    if (locationInterval != 0) {
        if (!_isAlwaysLocation) {
            NSLog(@"常驻定位未开启");
            locationInterval = 0;
            return;
        }
    }
    _locationInterval = locationInterval;
    if (self.backgroundLocationTimer) {
        [self.backgroundLocationTimer invalidate];
        self.backgroundLocationTimer = nil;
    }
}
-(void)setWF_BMK_BGLocationHander:(void (^)(CLLocationCoordinate2D))WF_BMK_BGLocationHander{
    if (!self.isAlwaysLocation) {
        return;
    }
    _backgroundLocationHander = [WF_BMK_BGLocationHander copy];
}
#pragma mark - Public
-(void)getCurrentCordinate:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander{
    self.oncecoordinatehander = [coordinateHander copy];
}

-(void)activeCoordinate:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander{
    self.activelocationCoordinateHander =  [coordinateHander copy];
}

-(void)backGCoordinate:(void(^)(CLLocationCoordinate2D coordinate,NSError *error))coordinateHander{
    self.backgroundLocationHander =  [coordinateHander copy];
}

-(void)startLocationService{
    NSLog(@"WFBMK location start");
    self.nowLocationTime = [[NSDate date] timeIntervalSince1970];
    //两次定位时差大于一定时间 重启定位 反之返回最近一次经纬度
    if ((self.nowLocationTime - self.lastLocationTime)>8.0f) {
        if (![self checkCLAuthorizationStatus]) {
            NSLog(@"定位服务未开启");
            return;
        }
        self.locationService.delegate = self;
        [self.locationService startUserLocationService];
    }else{
        [self onceCoordinate];
    }
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
    [self.locationService stopUserLocationService];
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
-(WFLocationState)checkLocationState{
    if (!_isAlwaysLocation) {
        return onceLocationCoordinateType;
    }else{
        if (_isBackGroundLocation) {
            return backgroundlocationCoordinateType;
        }else{
            return activeLocationCoordinateType;
        }
    }
}
-(void)restartLocationUpdates{
    NSLog(@"定位重启");
    if (self.restaertTimer) {
        [self.restaertTimer invalidate];
        self.restaertTimer = nil;
    }
    [self startLocationService];
}
-(void)backGroundBackCoordinate{
    if ([self checkCLAuthorizationStatus]) {
        if (self.backgroundLocationHander) {
            CLLocationCoordinate2D locationCoordinate = self.lastCoordinate;
            _backgroundLocationHander(locationCoordinate,nil);
        }
    }
}
-(void)activeLocationCoordinate{
    if ([self checkCLAuthorizationStatus]) {
        if (self.activelocationCoordinateHander) {
            CLLocationCoordinate2D locationCoordinate = self.lastCoordinate;
        _activelocationCoordinateHander(locationCoordinate,nil);
        }
    }
}
-(void)onceCoordinate{
    if ([self checkCLAuthorizationStatus]) {
        if (self.oncecoordinatehander) {
            CLLocationCoordinate2D locationCoordinate = self.lastCoordinate;
            _oncecoordinatehander(locationCoordinate,nil);
           _oncecoordinatehander = nil;
        }
    }
}
-(void)addBackgroundTask{
    self.bgTask = [WFBackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
}
-(void)applicationEnterBackground{
    _isBackGroundLocation = YES;
    if (_isAlwaysLocation) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
          //  [_clLocationManager requestAlwaysAuthorization];
        }
            [self addBackgroundTask];
    }
}
-(void)applicationBecomeActive{
    NSLog(@"前台操作 切换定位模式");
    _isBackGroundLocation = NO;
    if (self.backgroundLocationTimer) {
        [self.backgroundLocationTimer invalidate];
        self.backgroundLocationTimer = nil;
    }
    if (self.restaertTimer) {
        [self.restaertTimer invalidate];
        self.restaertTimer = nil;
    }
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
      CLLocationCoordinate2D locationCoordiate = userLocation.location.coordinate;
    self.lastLocationTime = [[NSDate date] timeIntervalSince1970];
    self.lastCoordinate = locationCoordiate;
    self.locationSate = [self checkCLAuthorizationStatus];
    [self onceCoordinate];
    if (!self.isAlwaysLocation) {
        [self startLocationService];
    }
    if (self.locationSate == onceLocationCoordinateType) {
        [self stopLocationService];
        return;
    }
    if (self.isBackGroundLocation) {
        if (self.restaertTimer) {//定位重启中不回调
            return;
        }
        [self addBackgroundTask];
        if (!self.backgroundLocationTimer) {
            self.backgroundLocationTimer = [NSTimer scheduledTimerWithTimeInterval:self.locationInterval target:self selector:@selector(backGroundBackCoordinate) userInfo:nil repeats:YES];
            [self backGroundBackCoordinate];
            [[NSRunLoop currentRunLoop] addTimer:self.backgroundLocationTimer forMode:NSRunLoopCommonModes];
        }
        //如果1分钟没有调用代理将重启定位服务
        self.restaertTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.restaertTimer forMode:NSRunLoopCommonModes];

    }else{
         [self activeLocationCoordinate];
    }
}

-(void)didFailToLocateUserWithError:(NSError *)error{
   
}

@end
