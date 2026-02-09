import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

abstract class VenueRepository {
  Future<List<Venue>> fetchNearbyVenues(LatLng location);
}
