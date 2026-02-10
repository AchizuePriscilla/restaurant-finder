import 'dart:async';
import 'dart:developer' as developer;

import 'package:restaurant_finder/domain/providers/location_provider.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

class LocationProviderImpl implements LocationProvider {
  LocationProviderImpl({
    Duration interval = const Duration(seconds: 10),
    List<LatLng>? coordinates,
  })  : _interval = interval,
        _coordinates = coordinates != null
            ? List<LatLng>.unmodifiable(coordinates)
            : _defaultCoordinates;

  static const List<LatLng> _defaultCoordinates = [
    LatLng(latitude: 60.169418, longitude: 24.931618),
    LatLng(latitude: 60.169818, longitude: 24.932906),
    LatLng(latitude: 60.170005, longitude: 24.935105),
    LatLng(latitude: 60.169108, longitude: 24.936210),
    LatLng(latitude: 60.168355, longitude: 24.934869),
    LatLng(latitude: 60.167560, longitude: 24.932562),
    LatLng(latitude: 60.168254, longitude: 24.931532),
    LatLng(latitude: 60.169012, longitude: 24.930341),
    LatLng(latitude: 60.170085, longitude: 24.929569),
  ];

  final Duration _interval;
  final List<LatLng> _coordinates;

  @override
  Stream<LatLng> locationStream() async* {
    if (_coordinates.isEmpty) {
      developer.log(
        'No coordinates configured — stream completing immediately',
        name: 'LocationProviderImpl',
      );
      return;
    }

    var index = 0;

    while (true) {
      final current = _coordinates[index];
      developer.log(
        'Location emitted: index=$index '
        'lat=${current.latitude} lon=${current.longitude}',
        name: 'LocationProviderImpl',
      );
      yield current;

      index = (index + 1) % _coordinates.length;
      if (index == 0) {
        developer.log('Location loop reset', name: 'LocationProviderImpl');
      }

      await Future.delayed(_interval);
    }
  }
}
