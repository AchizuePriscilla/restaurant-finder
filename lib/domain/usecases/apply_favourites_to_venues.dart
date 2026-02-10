import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/repositories/favourite_repository.dart';

class ApplyFavouritesToVenues {
  ApplyFavouritesToVenues(this._favouriteRepository);

  final FavouriteRepository _favouriteRepository;

  Future<Result<List<Venue>>> call(List<Venue> venues) async {
    final favouritesResult = await _favouriteRepository.getFavourites();
    return favouritesResult.map(
      (favourites) => venues
          .map(
            (venue) => venue.copyWith(
              isFavourite: favourites.contains(venue.id),
            ),
          )
          .toList(growable: false),
    );
  }
}
