class ValueRange {
  const ValueRange(this.location, this.length);
  final int location;
  final int length;

  int max() {
    return location + length;
  }

  bool contains(int location) {
    return (!(location < this.location) && (location - this.location) < length)
        ? true
        : false;
  }

  @override
  int get hashCode => location.hashCode ^ length.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ValueRange &&
            runtimeType == other.runtimeType &&
            location == other.location &&
            length == other.length;
  }
}

class TileCollectionRange {
  const TileCollectionRange(this.zoom, this.x, this.y);

  final int zoom;
  final ValueRange x;
  final ValueRange y;

  @override
  int get hashCode => zoom.hashCode ^ x.hashCode ^ y.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TileCollectionRange &&
            runtimeType == other.runtimeType &&
            zoom == other.zoom &&
            x == other.x &&
            y == other.y;
  }
}

class TileCollection {
  const TileCollection({required this.range, required this.tileCodes});

  final TileCollectionRange range;
  final List<String> tileCodes;

  bool containsTileCode(String tileCode) {
    return tileCodes.contains(tileCode);
  }

  String? tileCodeAt(int x, int y) {
    if (!range.x.contains(x) || !range.y.contains(y)) return null;

    int column = x - range.x.location;
    int row = y - range.y.location;
    return tileCodes[column + row * range.x.length];
  }

  List<String> intersect(List<String> codes) {
    Set<String> results = tileCodes.toSet().intersection(codes.toSet());
    return results.toList();
  }

  List<String> minus(List<String> codes) {
    Set<String> results = tileCodes.toSet().difference(codes.toSet());
    return results.toList();
  }

  TileChanges changesFrom(TileCollection? from) {
    List<String> entered = [];
    List<String> exited = [];
    List<String> remained = [];
    if (from == null) {
      entered = tileCodes;
    } else {
      List<String> intersectTileCodes = from.intersect(tileCodes);
      if (intersectTileCodes.isEmpty) {
        entered = tileCodes;
        exited = from.tileCodes;
      } else {
        exited = from.minus(intersectTileCodes);
        entered = minus(intersectTileCodes);
        remained = intersectTileCodes;
      }
    }

    return TileChanges(entered: entered, exited: exited, remains: remained);
  }

  @override
  int get hashCode => range.hashCode ^ tileCodes.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TileCollection &&
            runtimeType == other.runtimeType &&
            range == other.range &&
            tileCodes == other.tileCodes;
  }
}

class TileChanges {
  const TileChanges(
      {required this.entered, required this.exited, required this.remains});

  final List<String> entered;
  final List<String> exited;
  final List<String> remains;
}
