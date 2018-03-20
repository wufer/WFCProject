//
//  WFBMK_TrailVc.m
//  WFCProject
//
//  Created by wufer on 2018/3/15.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import "WFBMKTrailVc.h"

#import "LocationModel.h"
#import "WF_BMK_LocationHelp.h"
//#import "YZLocationManager.h"

#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>//基础地图
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//百度地图计算方法API

#import <YYCategories.h>

@interface WFBMKTrailVc ()<BMKMapViewDelegate>

/**
 模拟数据源
 */
@property (nonatomic,strong) NSDictionary *dataDict;
/**
 地图展示
 */
@property (nonatomic,strong) BMKMapView *mapView;


@end
static CLLocationManager *clLocationManager;
@implementation WFBMKTrailVc
//BMK地图显隐需控制代理
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addMapView];
    [self drawTheOverlay];
    //假设定位中心点
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 23.22504044;
    coordinate.longitude = 113.4938237;
    [_mapView setCenterCoordinate:coordinate];
    [WF_BMK_LocationManager sharedLocationManager].isAlwaysLocation = YES;
    [WF_BMK_LocationManager sharedLocationManager].locationInterval = 5.0f;
       [[WF_BMK_LocationManager sharedLocationManager]startLocationService];
  
  

   
}

#pragma mark createUI
-(void)addMapView{
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, KNAVHIGH, KSCREENWIDTH,KSCREENHEIGHT-KNAVHIGH)];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
   [self.view addSubview:_mapView];
}
-(void)loardOldRoute{
    
}
#pragma mark location&delegate
-(void)startLocation{
  
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    NSLog(@"%f %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}

- (void)didFailToLocateUserWithError:(NSError *)error{
}
#pragma mark BMKOverlayView&delegate
-(void)drawTheOverlay{
    if (self.dataDict) {
        NSArray *routeArr = [self.dataDict objectForKey:@"route"];
        if (routeArr.count>1) {//判断除起始点外存在其他路线经纬度时开始画线
            NSMutableArray *tempRouteArr = [[NSMutableArray alloc]init];
            [tempRouteArr addObject:routeArr.firstObject];
            NSMutableArray <NSMutableArray *>*overlayArr = [[NSMutableArray alloc]init];
            for (int i = 1; i<routeArr.count; i++) {
                LocationModel *firModel = routeArr[i];
                LocationModel *secModel = routeArr[i-1];
                BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([firModel.lat floatValue], [firModel.lon floatValue]));
                BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([secModel.lat floatValue],[secModel.lon floatValue]));
                CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
                if (distance<500) {
                    [tempRouteArr addObject:secModel];
                    if (i == (routeArr.count-1) && !overlayArr.count){//全部符合规范加入数组处理
                        [overlayArr addObject:tempRouteArr.mutableCopy];
                    }
                }else{
                    [overlayArr addObject:tempRouteArr.mutableCopy];
                    [tempRouteArr removeAllObjects];
                }
            }
            NSLog(@"完成间距分组,开始分段画线");
            [overlayArr enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                const int  Max  = (int)obj.count;
                CLLocationCoordinate2D *coors = malloc(Max *sizeof(CLLocationCoordinate2D));
                for (int i = 0; i<Max; i++) {
                    LocationModel *model = obj[i];
                    coors[i].latitude =[model.lat floatValue];
                    coors[i].longitude = [model.lon floatValue];
                }
                BMKPolyline *polylineView = [BMKPolyline polylineWithCoordinates:coors count:Max];
                [_mapView addOverlay:polylineView];
            }];
    }
}
}

-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView *polylineView = [[BMKPolylineView alloc]initWithOverlay:overlay];
        polylineView.isFocus = NO;
        polylineView.strokeColor = [UIColor purpleColor];
        polylineView.lineWidth = 2;
        return polylineView;
    }else{
         return nil;
    }
}

-(void)cleanOverlayView{
    NSArray *overlayViews = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:overlayViews];
}

- (BMKMapRect)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX = 0;
    CGFloat rbX = 0;
    CGFloat ltY = 0;
    CGFloat rbY = 0;
    if (polyLine.pointCount < 1) {
        return BMKMapRectNull;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x; ltY = pt.y;
    rbX = pt.x; rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    return rect;
}
#pragma mark lazyLoard
-(NSDictionary *)dataDict{
    if (!_dataDict) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"plist"];
        NSDictionary *localDict = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
        NSMutableArray *pointArr = [[NSMutableArray alloc]init];
        for (NSDictionary *dict in [localDict objectForKey:@"location"]) {
            LocationModel *model = [[LocationModel alloc]init];
            [model setValuesForKeysWithDictionary:dict];
            [pointArr addObject:model];
        }
        _dataDict = @{
                      @"route" : pointArr,
                      @"stations" : @[]
                      };
    }
    return _dataDict;
}
//-(BMKLocationService *)locationService{
//    if (!_locationService) {
//        //初始化实例
//        _locationService = [[BMKLocationService alloc] init];
//        //设置delegate
//        _locationService.delegate = self;
//        //设置定位服务是否会被系统暂停
//        _locationService.pausesLocationUpdatesAutomatically = NO;
//        //设置距离过滤参数
//        _locationService.distanceFilter = kCLDistanceFilterNone;
//        //设置预期精度参数
//        _locationService.desiredAccuracy = kCLLocationAccuracyBest;
//        //设置是否自动停止位置更新
//        _locationService.pausesLocationUpdatesAutomatically = NO;
//        //设置是否允许后台定位
//        _locationService.allowsBackgroundLocationUpdates = YES;
//    }
//    return _locationService;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
