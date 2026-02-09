import 'package:restaurant_finder/domain/repositories/favourite_repository.dart';

class ToggleFavouriteUseCase {
  ToggleFavouriteUseCase(this._favouriteRepository);

  final FavouriteRepository _favouriteRepository;

  Future<void> call(String venueId) {
    return _favouriteRepository.toggleFavourite(venueId);
  }
}
