//
//  GoelocationModule.m
//  RCTBaiduMap
//
//  Created by lovebing on 2016/10/28.
//  Copyright © 2016年 lovebing.org. All rights reserved.
//

#import "GeolocationModule.h"



@implementation GeolocationModule {
    BMKPointAnnotation* _annotation;
}

@synthesize bridge = _bridge;

static BMKGeoCodeSearch *geoCodeSearch;
static BMKLocationService *locationService;
static BMKCloudSearch* _search;
static BMKSuggestionSearch* _suggestSearch;

RCT_EXPORT_MODULE(BaiduGeolocationModule);

/**
 * GPS坐标转换百度坐标
 */
RCT_EXPORT_METHOD(getBaiduCoorFromGPSCoor:(double)lat lng:(double)lng
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    CLLocationCoordinate2D baiduCoor = [self getBaiduCoor:lat lng:lng];
    
    NSDictionary* coor = @{
                           @"latitude": @(baiduCoor.latitude),
                           @"longitude": @(baiduCoor.longitude)
                           };
    resolve(coor);
}

// 云地理编码 通过城市，地址返回经纬度信息
RCT_EXPORT_METHOD(geocode:(NSString *)city addr:(NSString *)addr) {
    
    [self getGeocodesearch].delegate = self;
    
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    
    geoCodeSearchOption.city= city;
    geoCodeSearchOption.address = addr;
    
    BOOL flag = [[self getGeocodesearch] geoCode:geoCodeSearchOption];
    
    if(flag) {
        NSLog(@"geo检索发送成功");
    } else{
        NSLog(@"geo检索发送失败");
    }
}

// 逆云地理编码，通过经纬度返回地址信息
RCT_EXPORT_METHOD(reverseGeoCode:(double)lat lng:(double)lng) {
    
    [self getGeocodesearch].delegate = self;
    CLLocationCoordinate2D baiduCoor = CLLocationCoordinate2DMake(lat, lng);
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){baiduCoor.latitude, baiduCoor.longitude};
    
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    
    BOOL flag = [[self getGeocodesearch] reverseGeoCode:reverseGeoCodeSearchOption];
    
    if(flag) {
        NSLog(@"逆向地理编码发送成功");
    }
    else{
        NSLog(@"逆向地理编码发送失败");
    }
//    [reverseGeoCodeSearchOption release];
}

RCT_EXPORT_METHOD(reverseGeoCodeGPS:(double)lat lng:(double)lng) {
    
    [self getGeocodesearch].delegate = self;
    CLLocationCoordinate2D baiduCoor = [self getBaiduCoor:lat lng:lng];
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){baiduCoor.latitude, baiduCoor.longitude};
    
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    
    BOOL flag = [[self getGeocodesearch] reverseGeoCode:reverseGeoCodeSearchOption];
    
    if(flag) {
        NSLog(@"逆向地理编码发送成功");
    }
    //[reverseGeoCodeSearchOption release];
}

/**
 *
 * OC抛出供JS调用的周边搜索方法
 * 传递经纬度参数
 *
 */
RCT_EXPORT_METHOD(nearbySearch:(NSString*) lat lng:(NSString*)lng ak:(NSString *)ak geoTableId:(int) geoTableId filter:(int) filter){
    // 获取search对象并指定委托对象
    [self getCloudSearch].delegate = self;
    
    BMKCloudNearbySearchInfo *cloudNearbySearch = [[BMKCloudNearbySearchInfo alloc]init];
    // 设置百度地图 服务端 ak
    cloudNearbySearch.ak = ak;
    // 设置百度地图 LBS 云存储的table id
    cloudNearbySearch.geoTableId = geoTableId;
    // cloudNearbySearch.pageIndex = 0; 默认值
    // cloudNearbySearch.pageSize = 10; 默认值
    // 格式化经纬度
    NSString *selfLocateStr = [NSString stringWithFormat:@"%@,%@",lng, lat];
    // 设置搜索中心
    cloudNearbySearch.location = selfLocateStr;
    // 设置搜索半径
    cloudNearbySearch.radius = 5000;
    // 设置所有标签
    // cloudNearbySearch.tags = @"wabg";
    // 设置搜索关键字，**必需值** ,搜索全部传递一个空格字符串
    cloudNearbySearch.keyword = @" ";
    if(filter == 0){
        cloudNearbySearch.filter = @"status:1";
    }else if(filter == 1){ // 会议
        cloudNearbySearch.filter = @"status:1|goods_type:1";
    }else if(filter == 2){ // 工位
        cloudNearbySearch.filter = @"status:1|goods_type:2";
    }
    
    
    BOOL flag = [_search nearbySearchWithSearchInfo:cloudNearbySearch];
    if(flag)
    {
        NSLog(@"周边云检索发送成功");
    }
    else
    {
        NSLog(@"周边云检索发送失败");
    }
    
}

/**
 * 在线建议查询，通过城市 关键字 搜索匹配的列表信息
 */
RCT_EXPORT_METHOD(suggestSearch:(NSString *) keyword cityname:(NSString *)cityname){
    [self getsuggestSearch].delegate = self;
    BMKSuggestionSearchOption *option = [[BMKSuggestionSearchOption alloc] init];
    option.cityname = cityname;
    option.keyword = keyword;
    NSLog(@"cityName:%@",cityname);
    BOOL flag = [_suggestSearch suggestionSearch:option];
    if(flag)
    {
        NSLog(@"建议检索发送成功");
    }
    else
    {
        NSLog(@"建议检索发送失败");
    }
}

/**
 * 在线建议查询回调
 */
- (void)onGetSuggestionResult:(BMKSuggestionSearch*)searcher result:(BMKSuggestionResult*)result errorCode:(BMKSearchErrorCode)error{
    NSMutableDictionary *body = [self getEmptyBody];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        if(result.keyList.count == 0){
            [body setObject:[NSNumber numberWithInt:1] forKey:@"code"];
            [body setObject:@"抱歉，未找到结果" forKey:@"message"];
        }else{
            [body setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            [body setObject:@"检索成功" forKey:@"message"];
            [body setObject:result.keyList forKey:@"data"];
        }
    }
    else {
        NSLog(@"抱歉，未找到结果");
        [body setObject:[NSNumber numberWithInt:1] forKey:@"code"];
        [body setObject:@"抱歉，未找到结果" forKey:@"message"];
    }
    
    [self sendEvent:@"onGetSuggestionResult" body:body];
}

/**
 * 初始化建议查询对象
 */
-(BMKSuggestionSearch *)getsuggestSearch{
    if(_suggestSearch == nil) {
        _suggestSearch = [[BMKSuggestionSearch alloc]init];
    }
    return _suggestSearch;
}

/**
 * 初始化地理查询对象
 */
-(BMKGeoCodeSearch *)getGeocodesearch{
    if(geoCodeSearch == nil) {
        geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    }
    return geoCodeSearch;
}

// 初始化搜索对象
-(BMKCloudSearch *)getCloudSearch{
    if(_search == nil) {
        _search = [[BMKCloudSearch alloc]init];    }
    return _search;
}

/**
 * 搜素结果回调函数
 * poiResultList 结果列表
 * searchType 搜索类型，如周边搜索，poi搜索...
 * errorCode 错误编号，0为正常
 */
- (void)onGetCloudPoiResult:(NSArray*)poiResultList searchType:(int)type errorCode:(int)error
{
    /**
     * body[@"code"] = [NSString stringWithFormat:@"%d", error]; 格式化非字符串类型值并传递参数，%d 整形，%f浮点型，%@字符型
     * body[@"message"] = @"没有数据返回"; 字符串直接赋值
     *
     */
    
    NSMutableDictionary *body = [self getEmptyBody];

    [body setObject:[NSNumber numberWithInt:error] forKey:@"code"];
    
    if (error == BMK_CLOUD_NO_ERROR) {
        BMKCloudPOIList* result = [poiResultList objectAtIndex:0];
        if(0 == [result size]){
            [body setObject:[NSNumber numberWithInt:10] forKey:@"code"];
            [body setObject:@"没有数据返回" forKey:@"message"];
        }else{
            body[@"message"] = @"周边数据检索成功";
            NSMutableArray * dataArray = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < result.POIs.count; i++) {
                NSMutableDictionary *item = [self getEmptyBody];
                
                BMKCloudPOIInfo* poi = [result.POIs objectAtIndex:i];
                
                [item setObject:poi.tags forKey:@"tags"];
                [item setObject:poi.address forKey:@"address"];
                [item setObject:[NSNumber numberWithFloat:poi.longitude] forKey:@"latitude"];
                [item setObject:[NSNumber numberWithFloat:poi.latitude] forKey:@"longitude"];
                [item setObject:[NSNumber numberWithInt:poi.geotableId] forKey:@"geotableId"];
                [item setObject:poi.title forKey:@"title"];
                
                //自定义字段
                if(poi.customDict!=nil&&poi.customDict.count>1)
                {
                    /**
                     * 非空判断
                     */
                    if([poi.customDict objectForKey:@"goods_type"] != nil){
                        [item setObject:[poi.customDict objectForKey:@"goods_type"] forKey:@"goods_type"];
                    }
                    if([poi.customDict objectForKey:@"mark"] != nil){
                        [item setObject:[poi.customDict objectForKey:@"mark"] forKey:@"mark"];
                    }
                    if([poi.customDict objectForKey:@"goods_id"] != nil){
                        [item setObject:[poi.customDict objectForKey:@"goods_id"] forKey:@"goods_id"];
                    }
                }
                
                [dataArray addObject:item];
            }
            body[@"data"] = dataArray;
        }
    } else {
        NSLog(@"error = %d",error);
        [body setObject:@"周边数据获取失败" forKey:@"message"];
    }
    [self sendEvent:@"onCloudSearch" body:body];
}

/**
 * 云地理编码回调
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    NSMutableDictionary *body = [self getEmptyBody];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSString *latitude = [NSString stringWithFormat:@"%f", result.location.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f", result.location.longitude];
        body[@"latitude"] = latitude;
        body[@"longitude"] = longitude;
    }
    else {
        body[@"errcode"] = [NSString stringWithFormat:@"%d", error];
        body[@"errmsg"] = [self getSearchErrorInfo:error];
    }
    [self sendEvent:@"onGetGeoCodeResult" body:body];
    
}

/**
 * 逆云地理编码回调
 */
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error {
    
    NSMutableDictionary *body = [self getEmptyBody];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        body[@"address"] = result.address;
        body[@"province"] = result.addressDetail.province;
        body[@"city"] = result.addressDetail.city;
        body[@"district"] = result.addressDetail.district;
        body[@"streetName"] = result.addressDetail.streetName;
        body[@"streetNumber"] = result.addressDetail.streetNumber;
    }
    else {
        body[@"errcode"] = [NSString stringWithFormat:@"%d", error];
        body[@"errmsg"] = [self getSearchErrorInfo:error];
    }
    [self sendEvent:@"onGetReverseGeoCodeResult" body:body];
    
    geoCodeSearch.delegate = nil;
}

-(NSString *)getSearchErrorInfo:(BMKSearchErrorCode)error {
    NSString *errormsg = @"未知";
    switch (error) {
        case BMK_SEARCH_AMBIGUOUS_KEYWORD:
            errormsg = @"检索词有岐义";
            break;
        case BMK_SEARCH_AMBIGUOUS_ROURE_ADDR:
            errormsg = @"检索地址有岐义";
            break;
        case BMK_SEARCH_NOT_SUPPORT_BUS:
            errormsg = @"该城市不支持公交搜索";
            break;
        case BMK_SEARCH_NOT_SUPPORT_BUS_2CITY:
            errormsg = @"不支持跨城市公交";
            break;
        case BMK_SEARCH_RESULT_NOT_FOUND:
            errormsg = @"没有找到检索结果";
            break;
        case BMK_SEARCH_ST_EN_TOO_NEAR:
            errormsg = @"起终点太近";
            break;
        case BMK_SEARCH_KEY_ERROR:
            errormsg = @"key错误";
            break;
        case BMK_SEARCH_NETWOKR_ERROR:
            errormsg = @"网络连接错误";
            break;
        case BMK_SEARCH_NETWOKR_TIMEOUT:
            errormsg = @"网络连接超时";
            break;
        case BMK_SEARCH_PERMISSION_UNFINISHED:
            errormsg = @"还未完成鉴权，请在鉴权通过后重试";
            break;
        case BMK_SEARCH_INDOOR_ID_ERROR:
            errormsg = @"室内图ID错误";
            break;
        case BMK_SEARCH_FLOOR_ERROR:
            errormsg = @"室内图检索楼层错误";
            break;
        default:
            break;
    }
    return errormsg;
}

// 获取百度地图坐标
-(CLLocationCoordinate2D)getBaiduCoor:(double)lat lng:(double)lng {
    // 创建坐标对象
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lat, lng);
    // 编码设置
    NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_COMMON);
    // 转换坐标（GPS to baidu）
    testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
    // 由于返回的字典对象是编码后的，需要解码，此方法就是解码坐标对象
    CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);
    return baiduCoor;
}

@end
