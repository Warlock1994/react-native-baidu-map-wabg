//
//  CusBMKPointAnnotation.h
//  RCTBaiduMap
//
//  Created by hexing on 2017/2/22.
//  Copyright © 2017年 lovebing.org. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@interface CusBMKPointAnnotation : BMKPointAnnotation

@property NSString* address;
@property NSNumber* goods_id;
@property NSNumber* geotableId;
@property NSString* mark;
@property NSNumber* goods_type;
@property NSString* tags;

@end
