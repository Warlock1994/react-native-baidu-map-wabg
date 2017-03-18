//
//  RCTBaiduMap.m
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapView.h"
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@implementation RCTBaiduMapView {
    BMKMapView* _mapView;
    CusBMKPointAnnotation* _annotation;
    NSMutableArray* _annotations;
}

// 设置缩放级别
-(void)setZoom:(float)zoom {
    self.zoomLevel = zoom;
}

// 设置中心位置
-(void)setCenterLatLng:(NSDictionary *)LatLngObj {
    double lat = [RCTConvert double:LatLngObj[@"lat"]];
    double lng = [RCTConvert double:LatLngObj[@"lng"]];
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(lat, lng);
    NSLog(@"-->>>center");
    self.centerCoordinate = point;
}

// 添加标注物，这里用于添加当前位置的标注
-(void)setMarker:(NSDictionary *)option {
    if(option != nil) {
        if(_annotation == nil) {
            _annotation = [[CusBMKPointAnnotation alloc]init];
            [self addMarker:_annotation option:option];
        }
        else {
            [self updateMarker:_annotation option:option];
        }
    }
}

// 添加标注物
-(void)setMarkers:(NSArray *)markers {
    int markersCount = [markers count];
    if(_annotations == nil) {
        _annotations = [[NSMutableArray alloc] init];
    }
    if(markers != nil) {
        for (int i = 0; i < markersCount; i++)  {
            NSDictionary *option = [markers objectAtIndex:i];
            
            CusBMKPointAnnotation *annotation = nil;
            int count =  [_annotations count];
            // 判断当前下标annotation是否存在于 _annotations
            if(i < count) {
                annotation = [_annotations objectAtIndex:i];
            }
            
            // 为空不存在与数组，添加进去
            if(annotation == nil) {
                annotation = [[CusBMKPointAnnotation alloc]init];
                [self addMarker:annotation option:option];
                [_annotations addObject:annotation];
            }
            else { // 更新当前annotation数据
                [self updateMarker:annotation option:option];
            }
        }
        
        int _annotationsCount = [_annotations count];
        
        NSString *smarkersCount = [NSString stringWithFormat:@"%d", markersCount];
        NSString *sannotationsCount = [NSString stringWithFormat:@"%d", _annotationsCount];
        
        if(markersCount < _annotationsCount) {
            int start = _annotationsCount - 1;
            for(int i = start; i >= markersCount; i--) {
                CusBMKPointAnnotation *annotation = [_annotations objectAtIndex:i];
                [self removeAnnotation:annotation];
                [_annotations removeObject:annotation];
            }
        }
    }
}

// 从参数中获取经纬度
-(CLLocationCoordinate2D)getCoorFromMarkerOption:(NSDictionary *)option {
    double lat = [RCTConvert double:option[@"latitude"]];
    double lng = [RCTConvert double:option[@"longitude"]];
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;
    return coor;
}

// 添加标注物
-(void)addMarker:(CusBMKPointAnnotation *)annotation option:(NSDictionary *)option {
    [self updateMarker:annotation option:option];
    [self addAnnotation:annotation];
}

// 更新标注物
-(void)updateMarker:(CusBMKPointAnnotation *)annotation option:(NSDictionary *)option {
    CLLocationCoordinate2D coor = [self getCoorFromMarkerOption:option];
    NSString *title = [RCTConvert NSString:option[@"title"]];
    if(title.length == 0) {
        title = nil;
    }
    annotation.coordinate = coor;
    annotation.title = title;
    
//    annotation
    
    /**
     *
     * 以下部分为更新标注物，并返回自定义参数
     * 如果参数不存在或值为nil 默认返回 0 或 @""，JS中就可以通过 (!!parameter)
     */
    
    if([option objectForKey:@"address"] == nil){
        annotation.address = @"";
    }else{
        annotation.address = [option objectForKey:@"address"];
    }
    
    if([option objectForKey:@"goods_id"] == nil){
        annotation.goods_id = [NSNumber numberWithInt:0];
    }else{
        annotation.goods_id = [option objectForKey:@"goods_id"];
    }
    
    if([option objectForKey:@"geotableId"] == nil){
        annotation.geotableId = [NSNumber numberWithInt:0];
    }else{
        annotation.geotableId = [option objectForKey:@"geotableId"];
    }
    
    if([option objectForKey:@"mark"] == nil){
        annotation.mark = @"";
    }else{
        annotation.mark = [option objectForKey:@"mark"];
    }
    
    if([option objectForKey:@"goods_type"] == nil){
        annotation.goods_type = [NSNumber numberWithInt:0];
    }else{
        annotation.goods_type = [option objectForKey:@"goods_type"];
    }
    
    if([option objectForKey:@"tags"] == nil){
        annotation.tags = @"";
    }else{
        annotation.tags = [option objectForKey:@"tags"];
    }
}

@end
