import 'dart:math';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:vector_math/vector_math.dart';

const int kEquatorialRadius = 6378137;
const int kEarthRadius = 6371000;

enum AzimuthQuadrant { first, second, third, fourth }

class GeometryUtils {
  static double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static double radiansToDegree(double radians) {
    return radians * 180.0 / pi;
  }

  AzimuthQuadrant directionQuadrant(double direction) {
    if (direction >= 0 && direction < 90) {
      return AzimuthQuadrant.first;
    } else if (direction >= 90 && direction < 180) {
      return AzimuthQuadrant.second;
    } else if (direction >= 180 && direction < 270) {
      return AzimuthQuadrant.third;
    }

    return AzimuthQuadrant.fourth;
  }

  static double directionAloneCoordinates(LatLng from, LatLng to) {
    double lat1 = degreesToRadians(from.latitude);
    double lon1 = degreesToRadians(from.longitude);

    double lat2 = degreesToRadians(to.latitude);
    double lon2 = degreesToRadians(to.longitude);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);

    double direction = radiansToDegree(radiansBearing);
    if (direction < 0) {
      direction += 360;
    } else if (direction > 360) {
      direction -= 360;
    }

    return direction;
  }

  static double distanceBetween(LatLng lhs, LatLng rhs) {
    double dLat = degreesToRadians(rhs.latitude - lhs.latitude);
    double dLng = degreesToRadians(rhs.longitude - lhs.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(rhs.latitude)) *
            cos(degreesToRadians(lhs.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = kEquatorialRadius * c;
    return distance;
  }

  static LatLng intersectionToLine(
      LatLng coordinate, LatLng lineStart, LatLng lineEnd) {
    double a = (lineStart.latitude - lineEnd.latitude);
    double b = (lineEnd.longitude - lineStart.longitude);
    double c = (lineStart.latitude * (lineStart.longitude - lineEnd.longitude) -
        (lineStart.longitude * (lineStart.latitude - lineEnd.latitude)));
    Vector3 vector = Vector3(a, b, c);

    double longitude = (pow(vector.x, 2) * coordinate.longitude -
            vector.x * vector.y * coordinate.latitude -
            vector.x * vector.z) /
        (pow(vector.x, 2) + pow(vector.y, 2));
    double latitude = (-vector.x * vector.y * coordinate.longitude +
            pow(vector.x, 2) * coordinate.latitude -
            vector.y * vector.z) /
        (pow(vector.x, 2) + pow(vector.y, 2));
    LatLng intersectCoordinate = LatLng(latitude, longitude);

    var vector1 =
        Point(lineStart.longitude - longitude, lineStart.latitude - latitude);
    var vector2 =
        Point(longitude - lineEnd.longitude, latitude - lineEnd.latitude);

    //check if the point is landing on extension cord
    num m = vector1.x * vector2.x + vector1.y * vector2.y;
    if (m < 0) {
      //if point landing on extension cord, then find the nearest instead
      double startDistance = distanceBetween(intersectCoordinate, lineStart);
      double endDistance = distanceBetween(intersectCoordinate, lineEnd);
      return startDistance < endDistance ? lineStart : lineEnd;
    } else {
      return intersectCoordinate;
    }
  }
}
