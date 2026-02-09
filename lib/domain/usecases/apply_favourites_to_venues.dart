import '../entities/venue.dart';
import '../repositories/favourite_repository.dart';

class ApplyFavouritesToVenues {
  ApplyFavouritesToVenues(this._favouriteRepository);

  final FavouriteRepository _favouriteRepository;

  Future<List<Venue>> call(List<Venue> venues) async {
    final favourites = await _favouriteRepository.getFavourites();
    return venues
        .map(
          (venue) => venue.copyWith(isFavourite: favourites.contains(venue.id)),
        )
        .toList(growable: false);
  }
}
