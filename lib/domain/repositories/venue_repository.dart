import '../entities/venue.dart';
import '../value_objects/lat_lng.dart';

abstract class VenueRepository {
  Future<List<Venue>> fetchNearbyVenues(LatLng location);
}
