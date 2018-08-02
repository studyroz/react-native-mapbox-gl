package com.mapbox.rctmgl.utils;

import android.graphics.PointF;
import android.graphics.RectF;
import android.view.MotionEvent;

import com.mapbox.android.gestures.AndroidGesturesManager;
import com.mapbox.android.gestures.MoveDistancesObject;
import com.mapbox.android.gestures.MoveGestureDetector;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.maps.MapView;
import com.mapbox.mapboxsdk.maps.MapboxMap;
import com.mapbox.services.commons.geojson.Feature;

import java.util.ArrayList;
import java.util.List;


public class DraggableSymbolsManager {
    public interface OnSymbolDragListener {
        void onSymbolDrag(String id, LatLng newLatLng);
        void onSymbolDragEnd(String id, LatLng newLatLng);
    }

    public class MapMoveGestureListener implements MoveGestureDetector.OnMoveGestureListener {
        private MapboxMap mapboxMap;
        private float touchAreaShiftX;
        private float touchAreaShiftY;
        private String symbolLayerID;

        private boolean querySymbol;
        private String draggedSymbolID;
        private LatLng latestLatLng;

        public MapMoveGestureListener(MapboxMap mapboxMap, String symbolLayerID,
                                      float touchAreaShiftX, float touchAreaShiftY) {
            this.mapboxMap = mapboxMap;
            this.touchAreaShiftX = touchAreaShiftX;
            this.touchAreaShiftY = touchAreaShiftY;
            this.symbolLayerID = symbolLayerID;

        }

        @Override
        public boolean onMoveBegin(MoveGestureDetector detector) {
            return true;
        }

        @Override
        public boolean onMove(MoveGestureDetector detector, float distanceX, float distanceY) {
            if (querySymbol && draggedSymbolID == null) {
                return false;
            }
            MoveDistancesObject moveObject = detector.getMoveObject(0);
            PointF point = new PointF(moveObject.getCurrentX() - touchAreaShiftX, moveObject.getCurrentY() - touchAreaShiftY);
            // 增大拖拽的响应区域
            int padding = 30;
            RectF rect = new RectF(point.x - padding, point.y - padding, point.x + padding, point.y + padding);
            if (!querySymbol) {
                querySymbol = true;
                List<Feature> features = mapboxMap.queryRenderedFeatures(rect, symbolLayerID);
                if (!features.isEmpty()) {
                    draggedSymbolID = features.get(0).getId();
                }
            }

            if (draggedSymbolID != null) {
                LatLng latLng = mapboxMap.getProjection().fromScreenLocation(point);
                latestLatLng = latLng;
                mapboxMap.getUiSettings().setAllGesturesEnabled(false);
                for (DraggableSymbolsManager.OnSymbolDragListener listener: onSymbolDragListeners) {
                    listener.onSymbolDrag(draggedSymbolID, latLng);
                }
                return true;
            }

            return false;
        }

        @Override
        public void onMoveEnd(MoveGestureDetector detector, float velocityX, float velocityY) {
            if (draggedSymbolID != null && latestLatLng != null) {
                for (DraggableSymbolsManager.OnSymbolDragListener listener: onSymbolDragListeners) {
                    listener.onSymbolDragEnd(draggedSymbolID, latestLatLng);
                }
            }
            latestLatLng = null;
            draggedSymbolID = null;
            querySymbol = false;
            mapboxMap.getUiSettings().setAllGesturesEnabled(true);
        }
    }

    private AndroidGesturesManager androidGesturesManager;
    private List<DraggableSymbolsManager.OnSymbolDragListener> onSymbolDragListeners;

    public DraggableSymbolsManager(MapView mapView,
                                   MapboxMap mapboxMap,
                                   String symbolLayerID) {
        onSymbolDragListeners = new ArrayList<>();
        androidGesturesManager = new AndroidGesturesManager(mapView.getContext(), false);
        androidGesturesManager.setMoveGestureListener(
                new MapMoveGestureListener(mapboxMap, symbolLayerID, 0, 0));
    }

    public void onParentTouchEvent(MotionEvent event) {
        androidGesturesManager.onTouchEvent(event);
    }

    public void addOnSymbolDragListener(OnSymbolDragListener listener) {
        onSymbolDragListeners.add(listener);
    }
}
