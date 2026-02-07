import '../entities/venue.dart';
import '../repositories/favourite_repository.dart';
import '../repositories/venue_repository.dart';
import '../value_objects/lat_lng.dart';

class GetVenuesForLocation {
  GetVenuesForLocation(
    this._venueRepository,
    this._favouriteRepository,
  );

  final VenueRepository _venueRepository;
  final FavouriteRepository _favouriteRepository;

  Future<List<Venue>> call(LatLng location) async {
    final venues = await _venueRepository.fetchNearbyVenues(location);
    final favourites = await _favouriteRepository.getFavourites();

    final updatedVenues = venues
        .map(
          (venue) => venue.copyWith(
            isFavourite: favourites.contains(venue.id),
          ),
        )
        .toList(growable: false);

    if (updatedVenues.length <= 15) {
      return updatedVenues;
    }

    return updatedVenues.take(15).toList(growable: false);
  }
}
