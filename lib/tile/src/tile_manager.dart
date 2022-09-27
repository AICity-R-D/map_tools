import 'dart:math';

import 'package:mapbox_gl/mapbox_gl.dart';

import 'mercator_projector.dart';
import 'tile_collection.dart';
import 'tile_region.dart';

class TileManager {
  TileManager();
  final MercatorProjector _projector = const MercatorProjector(tileSize: 256);

  Point coordinateToMeters(LatLng coordinate) {
    return _projector.coordinateToMeters(coordinate);
  }

  LatLng metersToCoordinate(Point meters) {
    return _projector.metersToCoordinate(meters);
  }

  String tileCodeAtCoordinate(LatLng coordinate, int zoom) {
    final TileData data = _projector.tileDataAtCoordinate(coordinate, zoom);
    return _projector.tileCode(data.zoom, data.x, data.y);
  }

  TileRegion? tileRegionAtCoordinate(LatLng coordinate, int zoom) {
    final TileData data = _projector.tileDataAtCoordinate(coordinate, zoom);
    return _projector.tileRegion(data);
  }

  TileRegion? tileRegion(String tileCode) {
    final TileData? data = _projector.tileDataWithCode(tileCode);
    return data != null ? _projector.tileRegion(data) : null;
  }

  String tileCode(int zoom, int x, int y) {
    return _projector.tileCode(zoom, x, y);
  }

  TileCollectionRange rangeWithBounds(int zoom, LatLngBounds bounds) {
    TileData from = _projector.tileDataAtCoordinate(bounds.southwest, zoom);
    TileData to = _projector.tileDataAtCoordinate(bounds.northeast, zoom);

    int xLength = (from.x - to.x).abs();
    int yLength = (from.y - to.y).abs();

    ValueRange rangeX = ValueRange(from.x, xLength);
    ValueRange rangeY = ValueRange(from.y, yLength);
    return TileCollectionRange(zoom, rangeX, rangeY);
  }

  TileCollection rangeCollection(TileCollectionRange range) {
    List<String> tileCodes = [];
    TileData edge = _projector.maxTileData(range.zoom);

    for (int x = range.x.location; x <= range.x.max(); x++) {
      for (int y = range.y.location; y <= range.y.max(); y++) {
        int tileX = x <= edge.x ? x : (edge.x - x);
        int tileY = y <= edge.y ? y : (edge.y - y);

        if (tileX != x) {
          print('$x -> $tileX');
        }

        if (tileY != y) {
          print('$y -> $tileY');
        }

        String tileCode = _projector.tileCode(range.zoom, tileX, tileY);
        tileCodes.add(tileCode);
      }
    }

    return TileCollection(range: range, tileCodes: tileCodes);
  }
}
