import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

abstract class LocationProvider {
  Stream<LatLng> locationStream();
}

