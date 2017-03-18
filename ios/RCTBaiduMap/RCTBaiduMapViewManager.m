//
//  RCTBaiduMapViewManager.m
//  RCTBaiduMap
//
//  Created by lovebing on Aug 6, 2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapViewManager.h"

@implementation RCTBaiduMapViewManager;

RCT_EXPORT_MODULE(RCTBaiduMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, int)
RCT_EXPORT_VIEW_PROPERTY(zoom, float)
RCT_EXPORT_VIEW_PROPERTY(trafficEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(baiduHeatMapEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(marker, NSDictionary*)
RCT_EXPORT_VIEW_PROPERTY(markers, NSArray*)

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(center, CLLocationCoordinate2D, RCTBaiduMapView) {
    [view setCenterCoordinate:json ? [RCTConvert CLLocationCoordinate2D:json] : defaultView.centerCoordinate];
}

// 初始化百度地图
+(void)initSDK:(NSString*)key {
    BMKMapManager* _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:key  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

// 初始化百度地图视图
- (UIView *)view {
    RCTBaiduMapView* mapView = [[RCTBaiduMapView alloc] init];
    mapView.delegate = self;
    return mapView;
}

// 添加地图双击事件
-(void)mapview:(BMKMapView *)mapView
 onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onDoubleClick");
    NSDictionary* event = @{
                            @"type": @"onMapDoubleClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

// 添加地图点击事件
-(void)mapView:(BMKMapView *)mapView
onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onClickedMapBlank");
    NSDictionary* event = @{
                            @"type": @"onMapClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

// 添加地图加载完成事件
-(void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    NSDictionary* event = @{
                            @"type": @"onMapLoaded",
                            @"params": @{}
                            };
    [self sendEvent:mapView params:event];
}

// 添加地图标注物点击事件，这里点击后，返回标注物自定义参数
-(void)mapView:(BMKMapView *)mapView
didSelectAnnotationView:(BMKAnnotationView *)view {
    /**
     * 强转为自定义的标注物类 CusBMKPointAnnotation
     * 并添加自定义参数
     */
    
    CusBMKPointAnnotation *_new = (CusBMKPointAnnotation *)[view annotation];
    NSDictionary* event = @{
                            @"type": @"onMarkerClick",
                            @"params": @{
                                    @"title": [_new title],
                                    @"position": @{
                                            @"latitude": @([_new coordinate].latitude),
                                            @"longitude": @([_new coordinate].longitude)
                                            },
                                    @"address": [_new address],
                                    @"goods_id": [_new goods_id],
                                    @"geotableId": [_new geotableId],
                                    @"mark": [_new mark],
                                    @"goods_type": [_new goods_type],
                                    @"tags": [_new tags]
                                    }
                            };
    [self sendEvent:mapView params:event];
}

// 气泡点击事件
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    CusBMKPointAnnotation *_new = (CusBMKPointAnnotation *)view.annotation;
    
    NSDictionary* event = @{
                            @"type": @"onPopClick",
                            @"params": @{
                                    @"title": [_new title],
                                    @"position": @{
                                            @"latitude": @([_new coordinate].latitude),
                                            @"longitude": @([_new coordinate].longitude)
                                            },
                                    @"address": [_new address],
                                    @"goods_id": [_new goods_id],
                                    @"geotableId": [_new geotableId],
                                    @"mark": [_new mark],
                                    @"goods_type": [_new goods_type],
                                    @"tags": [_new tags]
                                    }
                            };
    [self sendEvent:mapView params:event];
}

// 添加百度地图遮挡物点击事件
- (void) mapView:(BMKMapView *)mapView
 onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSDictionary* event = @{
                            @"type": @"onMapPoiClick",
                            @"params": @{
                                    @"name": mapPoi.text,
                                    @"uid": mapPoi.uid,
                                    @"latitude": @(mapPoi.pt.latitude),
                                    @"longitude": @(mapPoi.pt.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

// ？？？比较模糊，这里可以统一改变标注物的 图标
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if([annotation isKindOfClass:[BMKPointAnnotation class]]){
        
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        
        CusBMKPointAnnotation *_cusAnnotation = (CusBMKPointAnnotation *) annotation;
        int goods_id = [[_cusAnnotation goods_id] intValue];
        if(goods_id > 0){
            // 修改标注物图片
             newAnnotationView.image = [UIImage imageNamed:@"pin.png"];
        }else{
            // 设置默认样式
//            newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
            newAnnotationView.image = [UIImage imageNamed:@"location.png"];
        }
        return newAnnotationView;
    }
    
    return nil;
}

// 百度地图状态整改事件，如拖动百度地图
-(void)mapStatusDidChanged: (BMKMapView *)mapView	 {
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChange",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @"",
                                    @"overlook": @""
                                    }
                            };
    [self sendEvent:mapView params:event];
}

// 触发事件，并返回参数
-(void)sendEvent:(RCTBaiduMapView *) mapView params:(NSDictionary *) params {
    if (!mapView.onChange) {
        return;
    }
    mapView.onChange(params);
}

@end
