import 'package:flutter_test/flutter_test.dart';
import 'package:map_tools/map_tools.dart';

void main() {
  test('adds one to input values', () {
    const String testClusterID = 'test_layer_cluster';

    LayerManager manager = LayerManager();
    manager.registerClusterType(testClusterID);

    var beforeSuggestion = manager.suggestedLayerPosition(testClusterID);
    expect(beforeSuggestion.empty, 'Should be empty in the beginning');

    LayerClusterItem item = const LayerClusterItem('source_1', ['layer_1']);
    manager.addClusterItem(item, testClusterID);

    var afterSuggestion = manager.suggestedLayerPosition(testClusterID);
    expect(!afterSuggestion.empty, 'Should be the insert layer');
  });
}
