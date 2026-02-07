import 'dart:async';
import 'dart:developer' as developer;

import '../../domain/repositories/location_provider.dart';
import '../../domain/value_objects/lat_lng.dart';

class LocationProviderImpl implements LocationProvider {
  LocationProviderImpl({
    Duration interval = const Duration(seconds: 10),
    List<LatLng>? coordinates,
  })  : _interval = interval,
        _coordinates = List<LatLng>.unmodifiable(
          coordinates ?? _defaultCoordinates,
        );

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

  Timer? _timer;
  StreamController<LatLng>? _controller;
  int _index = 0;

  @override
  Stream<LatLng> locationStream() {
    _controller ??= StreamController<LatLng>(
      onListen: _start,
      onCancel: _stop,
    );
    return _controller!.stream;
  }

  void _start() {
    _emitCurrent();
    _timer = Timer.periodic(_interval, (_) => _emitNext());
  }

  void _emitCurrent() {
    if (_coordinates.isEmpty) {
      return;
    }
    final current = _coordinates[_index];
    developer.log(
      'Location emitted: index=$_index '
      'lat=${current.latitude} lon=${current.longitude}',
      name: 'LocationProviderImpl',
    );
    _controller?.add(current);
  }

  void _emitNext() {
    if (_coordinates.isEmpty) {
      return;
    }
    _index += 1;
    if (_index >= _coordinates.length) {
      _index = 0;
      developer.log(
        'Location loop reset',
        name: 'LocationProviderImpl',
      );
    }
    _emitCurrent();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}
