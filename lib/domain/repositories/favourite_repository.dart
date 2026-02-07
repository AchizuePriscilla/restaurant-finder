abstract class FavouriteRepository {
  Future<Set<String>> getFavourites();
  Future<void> toggleFavourite(String venueId);
}
