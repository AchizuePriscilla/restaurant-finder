import 'package:restaurant_finder/domain/core/result.dart';

abstract class FavouriteRepository {
  Future<Result<Set<String>>> getFavourites();
  Future<Result<void>> toggleFavourite(String venueId);
}
