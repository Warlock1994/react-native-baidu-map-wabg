package org.lovebing.reactnative.baidumap;

import android.os.Bundle;
import android.util.Log;
import android.widget.Button;

import com.baidu.mapapi.common.SysOSUtil;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.InfoWindow;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.map.OverlayOptions;
import com.baidu.mapapi.model.LatLng;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by lovebing on Sept 28, 2016.
 */
public class MarkerUtil {

    public static void updateMaker(Marker maker, ReadableMap option) {
        LatLng position = getLatLngFromOption(option);
        maker.setPosition(position);
        maker.setTitle(option.getString("title"));
        Bundle bundle = new Bundle();
        try{
            if(option.hasKey("mark")) bundle.putString("mark",option.getString("mark"));
            if(option.hasKey("goods_type")) bundle.putInt("goods_type",option.getInt("goods_type"));
            if(option.hasKey("goods_id")) bundle.putInt("goods_id",option.getInt("goods_id"));
            if(option.hasKey("uid")) bundle.putInt("uid",option.getInt("uid"));
            maker.setExtraInfo(bundle);
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    public static Marker addMarker(MapView mapView, ReadableMap option) {
        BitmapDescriptor bitmap = BitmapDescriptorFactory.fromResource(option.hasKey("goods_id") ? R.drawable.pin : R.drawable.location);
        LatLng position = getLatLngFromOption(option);
        OverlayOptions overlayOptions = new MarkerOptions()
                .icon(bitmap)
                .position(position)
                .title(option.getString("title"));

        Marker marker = (Marker)mapView.getMap().addOverlay(overlayOptions);
        try{
            Bundle bundle = new Bundle();
            if(option.hasKey("mark")) bundle.putString("mark",option.getString("mark"));
            if(option.hasKey("goods_type")) bundle.putInt("goods_type",option.getInt("goods_type"));
            if(option.hasKey("goods_id")) bundle.putInt("goods_id",option.getInt("goods_id"));
            if(option.hasKey("uid")) bundle.putInt("uid",option.getInt("uid"));
            marker.setExtraInfo(bundle);
        }catch (Exception e){
            e.printStackTrace();
        }
        return marker;
    }

    public static LatLng getLatLngFromOption(ReadableMap option) {
        double latitude = option.getDouble("latitude");
        double longitude = option.getDouble("longitude");
        return new LatLng(latitude, longitude);

    }
}
