import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/favourite_repository.dart';

class FavouriteRepositoryImpl implements FavouriteRepository {
  FavouriteRepositoryImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static const String _favouritesKey = 'favourite_venue_ids';

  @override
  Future<Set<String>> getFavourites() async {
    final values = _sharedPreferences.getStringList(_favouritesKey) ?? <String>[];
    final favourites = values.toSet();
    developer.log(
      'Favourites loaded: count=${favourites.length}',
      name: 'FavouriteRepositoryImpl',
    );
    return favourites;
  }

  @override
  Future<void> toggleFavourite(String venueId) async {
    final values = _sharedPreferences.getStringList(_favouritesKey) ?? <String>[];
    final favourites = values.toSet();
    if (favourites.contains(venueId)) {
      favourites.remove(venueId);
    } else {
      favourites.add(venueId);
    }

    await _sharedPreferences.setStringList(
      _favouritesKey,
      favourites.toList(growable: false),
    );

    developer.log(
      'Favourite toggled: $venueId',
      name: 'FavouriteRepositoryImpl',
    );
  }
}
