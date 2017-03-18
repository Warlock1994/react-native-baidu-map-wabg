//
//  GoelocationModule.h
//  RCTBaiduMap
//
//  Created by lovebing on 2016/10/28.
//  Copyright © 2016年 lovebing.org. All rights reserved.
//

#ifndef GeolocationModule_h
#define GeolocationModule_h


#import <BaiduMapAPI_Location/BMKLocationService.h>

#import "BaseModule.h"
#import "RCTBaiduMapViewManager.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Search/BMKSuggestionSearch.h>
#import "RCTBridgeModule.h"

@interface GeolocationModule : BaseModule <BMKGeoCodeSearchDelegate, BMKCloudSearchDelegate, BMKSuggestionSearchDelegate> {
    
}

@end

#endif /* GeolocationModule_h */
