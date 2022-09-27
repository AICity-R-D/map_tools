import 'dart:math';

import 'package:mapbox_gl/mapbox_gl.dart';

class TileData {
  const TileData(this.pixelSize, this.zoom, this.x, this.y);
  final int pixelSize;
  final int zoom;
  final int x;
  final int y;

  @override
  int get hashCode =>
      pixelSize.hashCode ^ zoom.hashCode ^ x.hashCode ^ y.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TileData &&
        runtimeType == other.runtimeType &&
        pixelSize == other.pixelSize &&
        zoom == other.zoom &&
        x == other.x &&
        y == other.y;
  }
}

class TileMeterBoundingBox {
  const TileMeterBoundingBox(
      this.northEast, this.northWest, this.southEast, this.southWest);

  final Point northEast;
  final Point northWest;
  final Point southEast;
  final Point southWest;

  @override
  int get hashCode =>
      northWest.hashCode ^
      northWest.hashCode ^
      southEast.hashCode ^
      southWest.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TileMeterBoundingBox &&
        runtimeType == other.runtimeType &&
        northEast == other.northEast &&
        northWest == other.northWest &&
        southEast == other.southEast &&
        southWest == other.southWest;
  }
}

class TileCoordinateBoundingBox {
  const TileCoordinateBoundingBox(
      this.northEast, this.northWest, this.southEast, this.southWest);

  final LatLng northEast;
  final LatLng northWest;
  final LatLng southEast;
  final LatLng southWest;

  @override
  int get hashCode =>
      northWest.hashCode ^
      northWest.hashCode ^
      southEast.hashCode ^
      southWest.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TileCoordinateBoundingBox &&
        runtimeType == other.runtimeType &&
        northEast == other.northEast &&
        northWest == other.northWest &&
        southEast == other.southEast &&
        southWest == other.southWest;
  }
}

class TileRegion {
  const TileRegion(
      {required this.data, required this.tileCode, required this.boundingBox});

  final String tileCode;
  final TileData data;
  final TileCoordinateBoundingBox boundingBox;

  @override
  int get hashCode => data.hashCode ^ tileCode.hashCode ^ boundingBox.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TileRegion &&
        runtimeType == other.runtimeType &&
        tileCode == other.tileCode &&
        data == other.data &&
        boundingBox == other.boundingBox;
  }
}
