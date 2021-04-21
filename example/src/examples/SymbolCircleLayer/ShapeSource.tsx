import React from 'react';
import MapboxGL, {SymbolLayerStyle} from '@react-native-mapbox-gl/maps';
import {View} from 'react-native';

const {MapView, Camera, Images, ShapeSource, SymbolLayer} = MapboxGL;

const styles = {
  icon: {
    iconImage: ['get', 'icon'],
    iconSize: [
      'match',
      ['get', 'icon'],
      'example',
      1.2,
      'airport-15',
      1.2,
      /* default */ 1,
    ],
  },
  mapView: {flex: 1},
  mapContainer: {flex: 1},
};

const exampleIcon = require('../../assets/example.png');

const featureCollection: GeoJSON.FeatureCollection = {
  type: 'FeatureCollection',
  features: [
    {
      type: 'Feature',
      id: '9d10456e-bdda-4aa9-9269-04c1667d4552',
      properties: {
        icon: 'example',
      },
      geometry: {
        type: 'Point',
        coordinates: [-117.20611157485, 52.180961084261],
      },
    },
    {
      type: 'Feature',
      id: '9d10456e-bdda-4aa9-9269-04c1667d4552',
      properties: {
        icon: 'airport-15',
      },
      geometry: {
        type: 'Point',
        coordinates: [-117.205908, 52.180843],
      },
    },
    {
      type: 'Feature',
      id: '9d10456e-bdda-4aa9-9269-04c1667d4552',
      properties: {
        icon: 'pin',
      },
      geometry: {
        type: 'Point',
        coordinates: [-117.206562, 52.180797],
      },
    },
    {
      type: 'Feature',
      id: '9d10456e-bdda-4aa9-9269-04c1667d4553',
      properties: {
        icon: 'pin3',
      },
      geometry: {
        type: 'Point',
        coordinates: [-117.206862, 52.180897],
      },
    },
  ],
};

class ShapeSourceIcon extends React.Component {
  state = {
    images: {
      example: exampleIcon,
    },
  };

  render(): JSX.Element {
    const {images} = this.state;

    return (
      <View style={styles.mapContainer}>
        <MapView style={styles.mapView}>
          <Camera
            zoomLevel={17}
            centerCoordinate={[-117.20611157485, 52.180961084261]}
          />
          <Images images={images} />
          <ShapeSource id="exampleShapeSource" shape={featureCollection}>
            <SymbolLayer
              id="exampleIconName"
              style={styles.icon as SymbolLayerStyle}
            />
          </ShapeSource>
        </MapView>
      </View>
    );
  }
}

export default ShapeSourceIcon;
