import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:restaurant_finder/data/providers/location_provider_impl.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

void main() {
  const testCoordinates = [
    LatLng(latitude: 1.0, longitude: 2.0),
    LatLng(latitude: 3.0, longitude: 4.0),
    LatLng(latitude: 5.0, longitude: 6.0),
  ];

  late LocationProviderImpl provider;

  setUp(() {
    provider = LocationProviderImpl(
      interval: const Duration(seconds: 1),
      coordinates: testCoordinates,
    );
  });

  test('emits first coordinate immediately on listen', () {
    fakeAsync((async) {
      final values = <LatLng>[];
      provider.locationStream().listen(values.add);

      async.elapse(Duration.zero);

      expect(values, hasLength(1));
      expect(values.first, testCoordinates[0]);
    });
  });

  test('emits coordinates in sequence at interval', () {
    fakeAsync((async) {
      final values = <LatLng>[];
      provider.locationStream().listen(values.add);

      async.elapse(const Duration(seconds: 3));

      // immediate emission + one per second
      expect(values, hasLength(4));
      expect(values[0], testCoordinates[0]);
      expect(values[1], testCoordinates[1]);
      expect(values[2], testCoordinates[2]);
      expect(values[3], testCoordinates[0]); // loops back
    });
  });

  test('loops back to index 0 after last coordinate', () {
    fakeAsync((async) {
      final values = <LatLng>[];
      provider.locationStream().listen(values.add);

      async.elapse(const Duration(seconds: 6));

      // 7 emissions: indices 0,1,2,0,1,2,0
      expect(values[3], values[0]);
      expect(values[6], values[0]);
    });
  });

  test('stops emitting after stream cancellation', () {
    fakeAsync((async) {
      final values = <LatLng>[];
      final sub = provider.locationStream().listen(values.add);

      async.elapse(const Duration(seconds: 1));
      expect(values, hasLength(2)); // initial + one tick

      sub.cancel();
      async.elapse(const Duration(seconds: 5));

      expect(values, hasLength(2));
    });
  });

  test('re-subscribing produces a fresh independent stream', () {
    fakeAsync((async) {
      final values1 = <LatLng>[];
      final sub1 = provider.locationStream().listen(values1.add);
      async.elapse(const Duration(seconds: 2));
      sub1.cancel();

      final values2 = <LatLng>[];
      provider.locationStream().listen(values2.add);
      async.elapse(Duration.zero);

      expect(values2.first, testCoordinates[0]);
    });
  });

  test('empty coordinates completes stream immediately', () {
    fakeAsync((async) {
      final emptyProvider = LocationProviderImpl(
        interval: const Duration(seconds: 1),
        coordinates: const [],
      );
      final values = <LatLng>[];
      var isDone = false;

      emptyProvider.locationStream().listen(
        values.add,
        onDone: () => isDone = true,
      );

      async.elapse(const Duration(seconds: 5));

      expect(values, isEmpty);
      expect(isDone, isTrue);
    });
  });

  test('multiple independent streams can coexist', () {
    fakeAsync((async) {
      final values1 = <LatLng>[];
      final values2 = <LatLng>[];

      provider.locationStream().listen(values1.add);
      async.elapse(const Duration(seconds: 1));
      provider.locationStream().listen(values2.add);
      async.elapse(const Duration(seconds: 1));

      // The first subscription has been active longer, so it should
      // have produced at least as many values as the second.
      expect(values1.length, greaterThan(values2.length));
    });
  });

  test('uses default coordinates when none provided', () {
    fakeAsync((async) {
      final defaultProvider = LocationProviderImpl(
        interval: const Duration(seconds: 1),
      );
      final values = <LatLng>[];
      defaultProvider.locationStream().listen(values.add);

      async.elapse(Duration.zero);

      expect(values, hasLength(1));
      expect(values.first.latitude, closeTo(60.169, 0.001));
    });
  });
}

