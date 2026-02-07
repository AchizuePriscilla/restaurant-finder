import '../repositories/favourite_repository.dart';

class ToggleFavourite {
  ToggleFavourite(this._favouriteRepository);

  final FavouriteRepository _favouriteRepository;

  Future<void> call(String venueId) {
    return _favouriteRepository.toggleFavourite(venueId);
  }
}
