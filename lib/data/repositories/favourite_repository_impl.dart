import 'package:shared_preferences/shared_preferences.dart';

import 'package:dartz/dartz.dart';
import 'package:restaurant_finder/domain/core/result.dart';
import 'package:restaurant_finder/domain/errors/failure.dart';
import 'package:restaurant_finder/domain/repositories/favourite_repository.dart';

class FavouriteRepositoryImpl implements FavouriteRepository {
  FavouriteRepositoryImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static const String _favouritesKey = 'favourite_venue_ids';

  @override
  Future<Result<Set<String>>> getFavourites() async {
    try {
      final values =
          _sharedPreferences.getStringList(_favouritesKey) ?? <String>[];
      return Right(values.toSet());
    } catch (error, stackTrace) {
      return Left(
        Failure.unknown(
          message: 'Failed to load favourites.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> toggleFavourite(String venueId) async {
    try {
      final values =
          _sharedPreferences.getStringList(_favouritesKey) ?? <String>[];
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
    } catch (error, stackTrace) {
      return Left(
        Failure.unknown(
          message: 'Failed to toggle favourite.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
    return const Right(null);
  }
}
