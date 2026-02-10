import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

abstract class VenueRepository {
  Future<Result<List<Venue>>> fetchNearbyVenues(LatLng location);
}
