import {
  requireNativeComponent,
  NativeModules,
  Platform,
  DeviceEventEmitter,
  NativeAppEventEmitter
} from 'react-native';

import React, {
  Component,
  PropTypes
} from 'react';


const _module = NativeModules.BaiduGeolocationModule;

export default {
  detailSearch(uid){
    return new Promise((resolve, reject) => {
      try {
        _module.detailSearch(uid);
      }
      catch (e) {
        reject(e);
      }
      DeviceEventEmitter.once('onGetDetailSearchResult', resp => {
        resolve(resp);
      });
    });
  },
  suggestSearch(keyword, cityname){
    if (Platform.OS == 'ios') {
      return new Promise((resolve, reject) => {
        try {
          _module.suggestSearch(keyword,cityname);
        }
        catch (e) {
          reject(e);
          return;
        }
        NativeAppEventEmitter.once('onGetSuggestionResult',(resp) => {
          resolve(resp)
        })
      },(error) => {
        reject(error);
      });
    }
    return new Promise((resolve, reject) => {
      try {
        _module.suggestSearch(keyword, cityname);
      }
      catch (e) {
        reject(e);
      }
      DeviceEventEmitter.once('OnGetSuggestionResult', resp => {
        resolve(resp);
      });
    });
  },
  nearbySearch(lat, lng, ak, geoTableId, filter){
    if (Platform.OS == 'ios') {
      return new Promise((resolve, reject) => {
        try {
          _module.nearbySearch(lat + '', lng  + '', ak, geoTableId, filter);
        }
        catch (e) {
          reject(e);
          return;
        }
        NativeAppEventEmitter.once('onCloudSearch',(resp) => {
          resolve(resp)
        })
      },(error) => {
        reject(error);
      });
    }
    return new Promise((resolve, reject) => {
      try {
        _module.nearbySearch(lat, lng ,ak, geoTableId, filter);
      }
      catch (e) {
        reject(e);
        return;
      }
      DeviceEventEmitter.once('onCloudSearchResult', resp => {
        resolve(resp);
      });
    });
  },
  geocode(city, addr) {
    return new Promise((resolve, reject) => {
      try {
        _module.geocode(city, addr);
      }
      catch (e) {
        reject(e);
        return;
      }
      DeviceEventEmitter.once('onGetGeoCodeResult', resp => {
        resolve(resp);
      });
    });
  },
  reverseGeoCode(lat, lng) {
    return new Promise((resolve, reject) => {
      try {
        _module.reverseGeoCode(lat, lng);
      }
      catch (e) {
        reject(e);
        return;
      }
      DeviceEventEmitter.once('onGetReverseGeoCodeResult', resp => {
        resolve(resp);
      });
    });
  },
  reverseGeoCodeGPS(lat, lng) {
    return new Promise((resolve, reject) => {
      try {
        _module.reverseGeoCodeGPS(lat, lng);
      }
      catch (e) {
        reject(e);
        return;
      }
      DeviceEventEmitter.once('onGetReverseGeoCodeResult', resp => {
        resolve(resp);
      });
    });
  },
  getCurrentPosition() {
    if (Platform.OS == 'ios') {
      return new Promise((resolve, reject) => {
        navigator.geolocation.getCurrentPosition((position) => {
          _module.getBaiduCoorFromGPSCoor(position.coords.latitude, position.coords.longitude)
            .then((data) => {
              resolve(data);
            })
            .catch((e) => {
              reject(e);
            });
        }, (error) => {
          reject(error);
        }, {
          enableHighAccuracy: true,
          timeout: 20000,
          maximumAge: 1000
        });
      });
    }
    return new Promise((resolve, reject) => {
      try {
        _module.getCurrentPosition();
      }
      catch (e) {
        reject(e);
        return;
      }
      DeviceEventEmitter.once('onGetCurrentLocationPosition', resp => {
        resolve(resp);
      });
    });
  }
};