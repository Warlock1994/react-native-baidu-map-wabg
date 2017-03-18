package org.lovebing.reactnative.baidumap;

import android.util.Log;

import com.baidu.location.BDLocation;
import com.baidu.location.BDLocationListener;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.baidu.mapapi.cloud.CloudListener;
import com.baidu.mapapi.cloud.CloudManager;
import com.baidu.mapapi.cloud.CloudPoiInfo;
import com.baidu.mapapi.cloud.CloudSearchResult;
import com.baidu.mapapi.cloud.DetailSearchInfo;
import com.baidu.mapapi.cloud.DetailSearchResult;
import com.baidu.mapapi.cloud.NearbySearchInfo;
import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.search.core.SearchResult;
import com.baidu.mapapi.search.geocode.GeoCodeOption;
import com.baidu.mapapi.search.geocode.GeoCodeResult;
import com.baidu.mapapi.search.geocode.GeoCoder;
import com.baidu.mapapi.search.geocode.OnGetGeoCoderResultListener;
import com.baidu.mapapi.search.geocode.ReverseGeoCodeOption;
import com.baidu.mapapi.search.geocode.ReverseGeoCodeResult;
import com.baidu.mapapi.search.sug.OnGetSuggestionResultListener;
import com.baidu.mapapi.search.sug.SuggestionResult;
import com.baidu.mapapi.search.sug.SuggestionSearch;
import com.baidu.mapapi.search.sug.SuggestionSearchOption;
import com.baidu.mapapi.utils.CoordinateConverter;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;

import java.util.List;
import java.util.Map;

/**
 * Created by lovebing on 2016/10/28.
 */
public class GeolocationModule extends BaseModule
        implements BDLocationListener, OnGetGeoCoderResultListener {

    private LocationClient locationClient;
    private static GeoCoder geoCoder;
    final int RADIUS = 5000;
    final int PAGE_SIZE = 10;
    private CloudManager cloudManager;
    private SuggestionSearch suggestionSearch;

    public GeolocationModule(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
    }

    public String getName() {
        return "BaiduGeolocationModule";
    }

    private void initCloudListener(){
        this.cloudManager.init(new CloudListener() {
            @Override
            public void onGetSearchResult(CloudSearchResult cloudSearchResult, int i) {
                System.out.println("cloudSearchResult:" + cloudSearchResult);

                if(cloudSearchResult == null || cloudSearchResult.size == 0){
                    WritableMap params = Arguments.createMap();
                    params.putInt("code",2);
                    params.putString("message","没有查询到数据");
                    sendEvent("onCloudSearchResult",params);
                }else{
                    WritableMap params = Arguments.createMap();
                    WritableArray writableArray = new WritableNativeArray();
                    List<CloudPoiInfo> poiInfos= cloudSearchResult.poiList;
                    for(int j = 0; j< poiInfos.size(); j++){
                        WritableMap paramItem = Arguments.createMap();
                        CloudPoiInfo info = poiInfos.get(j);
                        paramItem.putInt("uid",info.uid);
                        paramItem.putString("title",info.title);
                        paramItem.putString("address",info.address);
                        paramItem.putString("city",info.city);
                        paramItem.putString("direction",info.district);
                        paramItem.putString("province",info.province);
                        paramItem.putString("district",info.district);
                        paramItem.putString("tags",info.tags);
                        paramItem.putInt("distance",info.distance);

                        paramItem.putInt("geotableId",info.geotableId);
                        paramItem.putDouble("latitude",info.latitude);
                        paramItem.putDouble("longitude",info.longitude);

                        Map<String, Object> extras = info.extras;
                        int goods_id = (int) extras.get("goods_id");
                        int goods_type = (int) extras.get("goods_type");
                        String mark = (String) extras.get("mark");
                        paramItem.putInt("goods_id",goods_id);
                        paramItem.putInt("goods_type",goods_type);
                        paramItem.putString("mark",mark);

                        writableArray.pushMap(paramItem);
                    }
                    params.putInt("code",0);
                    params.putString("message","数据返回成功");
                    params.putArray("data",writableArray);
                    sendEvent("onCloudSearchResult",params);
                }
            }

            @Override
            public void onGetDetailSearchResult(DetailSearchResult result, int i) {
                if (result != null) {
                    if (result.poiInfo != null) {
                        System.out.println(result.poiInfo.title);
                    } else {
                        System.out.println("--->>>");
                    }
                }
            }
        });
    }

    private void initLocationClient() {
        LocationClientOption option = new LocationClientOption();
        option.setCoorType("bd09ll");
        option.setIsNeedAddress(true);
        option.setIsNeedAltitude(true);
        option.setIsNeedLocationDescribe(true);
        option.setOpenGps(true);
        locationClient = new LocationClient(context.getApplicationContext());
        locationClient.setLocOption(option);
        Log.i("locationClient", "locationClient");
        locationClient.registerLocationListener(this);
    }
    /**
     *
     * @return
     */
    protected GeoCoder getGeoCoder() {
        if(geoCoder != null) {
            geoCoder.destroy();
        }
        geoCoder = GeoCoder.newInstance();
        geoCoder.setOnGetGeoCodeResultListener(this);
        return geoCoder;
    }

    /**
     *
     * @param sourceLatLng
     * @return
     */
    protected LatLng getBaiduCoorFromGPSCoor(LatLng sourceLatLng) {
        CoordinateConverter converter = new CoordinateConverter();
        converter.from(CoordinateConverter.CoordType.GPS);
        converter.coord(sourceLatLng);
        LatLng desLatLng = converter.convert();
        return desLatLng;

    }

    @ReactMethod
    public void getCurrentPosition() {
        if(locationClient == null) {
            initLocationClient();
        }
        Log.i("getCurrentPosition", "getCurrentPosition");
        locationClient.start();
    }
    @ReactMethod
    public void geocode(String city, String addr) {
        getGeoCoder().geocode(new GeoCodeOption()
                .city(city).address(addr));
    }

    @ReactMethod
    public void reverseGeoCode(double lat, double lng) {
        getGeoCoder().reverseGeoCode(new ReverseGeoCodeOption()
                .location(new LatLng(lat, lng)));
    }

    @ReactMethod
    public void reverseGeoCodeGPS(double lat, double lng) {
        getGeoCoder().reverseGeoCode(new ReverseGeoCodeOption()
                .location(getBaiduCoorFromGPSCoor(new LatLng(lat, lng))));
    }

    @ReactMethod
    public void nearbySearch(Double lat, Double lng, String ak, Integer geoTableId, int filter){

        if(lat == null || lng == null || ak == null || "".equals(ak) || geoTableId == null){
            WritableMap params = Arguments.createMap();
            params.putInt("code",1);
            params.putString("message","经纬度为空");
            sendEvent("onCloudSearchResult",params);
        }else{
            NearbySearchInfo nearbySearchInfo = new NearbySearchInfo();

            nearbySearchInfo.ak = ak;
            nearbySearchInfo.geoTableId = geoTableId;
            nearbySearchInfo.radius = this.RADIUS;
            nearbySearchInfo.pageSize = this.PAGE_SIZE;
            nearbySearchInfo.location = lng + "," + lat;
            if(filter == 0){
                nearbySearchInfo.filter = "status:1";
            }else if(filter == 1){
                nearbySearchInfo.filter = "status:1|goods_type:1";
            }else if(filter == 2){
                nearbySearchInfo.filter = "status:1|goods_type:2";
            }
            if(this.cloudManager == null){
                this.cloudManager = CloudManager.getInstance();
                initCloudListener();
            }
            this.cloudManager.nearbySearch(nearbySearchInfo);
        }
    }

    @ReactMethod
    public void detailSearch(int uid){
//        DetailSearchInfo info = new DetailSearchInfo();
//        info.ak = "";
//        info.geoTableId = ;
//        info.uid = uid;
//
//        if(this.cloudManager == null){
//            this.cloudManager = CloudManager.getInstance();
//            initCloudListener();
//        }
//        this.cloudManager.detailSearch(info);
    }



    @ReactMethod
    public void suggestSearch(String keyword, String city){
        if(keyword == null || "".equals(keyword)){
            System.out.println("关键字未传递");
        }else{
            if(this.suggestionSearch == null){
                suggestionSearch = SuggestionSearch.newInstance();
                initSuggestListener();
            }
            if(city == null || "".equals(city)){
                city = "上海";
            }
            this.suggestionSearch.requestSuggestion(new SuggestionSearchOption().keyword(keyword).city(city));
        }
    }

    private void initSuggestListener(){
        this.suggestionSearch.setOnGetSuggestionResultListener(new OnGetSuggestionResultListener() {
            @Override
            public void onGetSuggestionResult(SuggestionResult result) {
                WritableMap params = Arguments.createMap();
                if(result == null || result.getAllSuggestions() == null || result.getAllSuggestions().size() == 0){
                    params.putInt("code",2);
                    params.putString("message","没有查询到数据");
                }else{
                    params.putInt("code",0);
                    params.putString("message","查询成功");
                    List<SuggestionResult.SuggestionInfo> sugList = result.getAllSuggestions();
                    WritableArray writableArray = new WritableNativeArray();
                    for (SuggestionResult.SuggestionInfo info : sugList){
                        writableArray.pushString(info.key);
                    }
                    params.putArray("data",writableArray);
                }

                sendEvent("OnGetSuggestionResult",params);
            }
        });
    }

    @Override
    public void onReceiveLocation(BDLocation bdLocation) {
        WritableMap params = Arguments.createMap();
        params.putDouble("latitude", bdLocation.getLatitude());
        params.putDouble("longitude", bdLocation.getLongitude());
        params.putDouble("direction", bdLocation.getDirection());
        params.putDouble("altitude", bdLocation.getAltitude());
        params.putDouble("radius", bdLocation.getRadius());
        params.putString("address", bdLocation.getAddrStr());
        params.putString("countryCode", bdLocation.getCountryCode());
        params.putString("country", bdLocation.getCountry());
        params.putString("province", bdLocation.getProvince());
        params.putString("cityCode", bdLocation.getCityCode());
        params.putString("city", bdLocation.getCity());
        params.putString("district", bdLocation.getDistrict());
        params.putString("street", bdLocation.getStreet());
        params.putString("streetNumber", bdLocation.getStreetNumber());
        params.putString("buildingId", bdLocation.getBuildingID());
        params.putString("buildingName", bdLocation.getBuildingName());
        Log.i("onReceiveLocation", "onGetCurrentLocationPosition");
        sendEvent("onGetCurrentLocationPosition", params);
        locationClient.stop();
    }

    @Override
    public void onGetGeoCodeResult(GeoCodeResult result) {
        WritableMap params = Arguments.createMap();
        if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR) {
            params.putInt("errcode", -1);
            params.putString("message", "未能正确解析此地址");
        }
        else {
            params.putDouble("latitude",  result.getLocation().latitude);
            params.putDouble("longitude",  result.getLocation().longitude);
        }
        sendEvent("onGetGeoCodeResult", params);
    }

    @Override
    public void onGetReverseGeoCodeResult(ReverseGeoCodeResult result) {
        WritableMap params = Arguments.createMap();
        if (result == null || result.error != SearchResult.ERRORNO.NO_ERROR) {
            params.putInt("errcode", -1);
            params.putString("message", "未能正确解析此地址");
        }
        else {
            ReverseGeoCodeResult.AddressComponent addressComponent = result.getAddressDetail();
            params.putString("address", result.getAddress());
            params.putString("province", addressComponent.province);
            params.putString("city", addressComponent.city);
            params.putString("district", addressComponent.district);
            params.putString("street", addressComponent.street);
            params.putString("streetNumber", addressComponent.streetNumber);
        }
        sendEvent("onGetReverseGeoCodeResult", params);
    }
}
