import 'dart:core';
import 'dart:math';

import 'package:mapbox_gl/mapbox_gl.dart';

import 'geometry_utils.dart';
import 'tile_region.dart';

class MercatorProjector {
  const MercatorProjector({required this.tileSize})
      : _originShift = 2 * pi * kEquatorialRadius / 2.0;
  final int tileSize;
  final double _originShift;

  Point coordinateToMeters(LatLng coordinate) {
    double x = coordinate.longitude * _originShift / 180.0;
    double y = log(tan((90 + coordinate.latitude) * pi / 360.0)) / (pi / 180.0);
    y = y * _originShift / 180.0;
    return Point(x, y);
  }

  LatLng metersToCoordinate(Point meters) {
    double longitude = (meters.x / _originShift) * 180.0;
    double latitude = (meters.y / _originShift) * 180.0;

    latitude = 180 / pi * (2 * atan(exp(latitude * pi / 180.0)) - pi / 2.0);
    return LatLng(latitude, longitude);
  }

  Point metersToPixels(Point meters, int zoom) {
    double resolution = _resolutionInZoom(zoom);
    double x = (meters.x + _originShift) / resolution;
    double y = (meters.y + _originShift) / resolution;
    return Point(x, y);
  }

  Point pixelToMeters(Point pixel, int zoom) {
    double resolution = _resolutionInZoom(zoom);
    double x = pixel.x * resolution - _originShift;
    double y = pixel.y * resolution - _originShift;
    return Point(x, y);
  }

  TileData _pixelToTileData(Point pixel, int zoom) {
    int x = (pixel.x / tileSize).ceil() - 1;
    int y1 = (pixel.y / tileSize).ceil() - 1;
    final int y = (pow(2, zoom) - 1 - y1).toInt();
    return TileData(tileSize, zoom, x, y);
  }

  TileData tileDataAtCoordinate(LatLng coordinate, int zoom) {
    Point meters = coordinateToMeters(coordinate);
    Point pixel = metersToPixels(meters, zoom);
    TileData data = _pixelToTileData(pixel, zoom);
    return data;
  }

  double _resolutionInZoom(int zoom) {
    return (2 * pi * kEquatorialRadius) / (tileSize * pow(2, zoom));
  }

  String tileCode(int zoom, int x, int y) {
    return '$zoom/$x/$y';
  }

  TileData? tileDataWithCode(String tileCode) {
    List<String> components = tileCode.split('/');
    if (components.length < 3) return null;

    int zoom = int.parse(components[0]);
    int x = int.parse(components[1]);
    int y = int.parse(components[2]);

    final data = TileData(tileSize, zoom, x, y);
    if (!tileDataIsValid(data)) return null;

    return data;
  }

  TileMeterBoundingBox _pixelBoundingBox(int x, int y) {
    var northWest = Point(x * tileSize, y * tileSize);
    var northEast = Point((x + 1) * tileSize, y * tileSize);
    var southWest = Point(x * tileSize, (y + 1) * tileSize);
    var southEast = Point((x + 1) * tileSize, (y + 1) * tileSize);
    return TileMeterBoundingBox(northEast, northWest, southEast, southWest);
  }

  TileCoordinateBoundingBox _convertTileBoundingBox(
      int zoom, TileMeterBoundingBox pixelBox) {
    LatLng northWest =
        metersToCoordinate(pixelToMeters(pixelBox.northWest, zoom));
    LatLng northEast =
        metersToCoordinate(pixelToMeters(pixelBox.northEast, zoom));
    LatLng southWest =
        metersToCoordinate(pixelToMeters(pixelBox.southWest, zoom));
    LatLng southEast =
        metersToCoordinate(pixelToMeters(pixelBox.southEast, zoom));
    return TileCoordinateBoundingBox(
        northEast, northWest, southEast, southWest);
  }

  TileCoordinateBoundingBox tileBoundingBox(int zoom, int x, int y) {
    TileMeterBoundingBox box = _pixelBoundingBox(x, y);
    return _convertTileBoundingBox(zoom, box);
  }

  TileRegion? tileRegion(TileData data) {
    if (!tileDataIsValid(data)) return null;

    int x = _availableTileX(data.x, data.zoom);
    int yTMS = _convertTileDataYToTMS(data);
    TileCoordinateBoundingBox box = tileBoundingBox(data.zoom, x, yTMS);
    String code = tileCode(data.zoom, x, data.y);
    return TileRegion(data: data, tileCode: code, boundingBox: box);
  }

  int _availableTileX(int x, int zoom) {
    final num max = pow(2, zoom);
    if (x < 0) return (x + max).toInt();
    if (x > max) return (x - max).toInt();
    return x;
  }

  int _convertTileDataYToTMS(TileData data) {
    return (pow(2, data.zoom) - 1 - data.y).toInt();
  }

  bool tileDataIsValid(TileData data) {
    return data.y >= 0 && data.y <= (pow(2, data.zoom) - 1);
  }

  TileData maxTileData(int zoom) {
    return TileData(
        tileSize, zoom, (pow(2, zoom) - 1).toInt(), (pow(2, zoom) - 1).toInt());
  }
}
