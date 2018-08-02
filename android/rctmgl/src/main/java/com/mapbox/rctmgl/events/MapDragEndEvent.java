package com.mapbox.rctmgl.events;

import android.view.View;

import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.rctmgl.events.constants.EventKeys;
import com.mapbox.rctmgl.events.constants.EventTypes;

public class MapDragEndEvent extends AbstractEvent {
    private LatLng newLatLng;
    private String id;
    public MapDragEndEvent(View view, String id, LatLng latLng) {
        super(view, EventTypes.MAP_DRAG_END);
        this.id = id;
        this.newLatLng = latLng;
    }
    @Override
    public String getKey() {
        return EventKeys.MAP_DRAG_END;
    }

    @Override
    public WritableMap getPayload() {
        WritableMap properties = new WritableNativeMap();
        WritableArray latLng = new WritableNativeArray();
        latLng.pushDouble(newLatLng.getLongitude());
        latLng.pushDouble(newLatLng.getLatitude());
        properties.putArray("coordinate", latLng);
        properties.putString("id", id);
        return properties;
    }
}
