import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/repositories/favourite_repository.dart';

class ToggleFavouriteUseCase {
  ToggleFavouriteUseCase(this._favouriteRepository);

  final FavouriteRepository _favouriteRepository;

  Future<Result<void>> call(String venueId) {
    return _favouriteRepository.toggleFavourite(venueId);
  }
}
