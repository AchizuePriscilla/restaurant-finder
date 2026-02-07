import '../value_objects/lat_lng.dart';

abstract class LocationProvider {
  Stream<LatLng> locationStream();
}
