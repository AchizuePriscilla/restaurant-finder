import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_finder/data/repositories/favourite_repository_impl.dart';
import 'package:restaurant_finder/domain/core/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('toggleFavourite adds id and toggling again removes it', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = FavouriteRepositoryImpl(sharedPreferences: prefs);

    final Result<void> firstResult =
        await repository.toggleFavourite('venue_1');
    final Result<Set<String>> firstFavourites = await repository.getFavourites();
    expect(firstResult.isRight(), isTrue);
    expect(firstFavourites.isRight(), isTrue);
    firstFavourites.fold(
      (_) => fail('Expected favourites result to be Right'),
      (favourites) {
        expect(favourites.contains('venue_1'), isTrue);
      },
    );

    final Result<void> secondResult =
        await repository.toggleFavourite('venue_1');
    final Result<Set<String>> secondFavourites =
        await repository.getFavourites();
    expect(secondResult.isRight(), isTrue);
    expect(secondFavourites.isRight(), isTrue);
    secondFavourites.fold(
      (_) => fail('Expected favourites result to be Right'),
      (favourites) {
        expect(favourites.contains('venue_1'), isFalse);
      },
    );
  });

  test('favourites persist across repository instances', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = FavouriteRepositoryImpl(sharedPreferences: prefs);

    final Result<void> result = await repository.toggleFavourite('venue_2');

    final newPrefs = await SharedPreferences.getInstance();
    final newRepository = FavouriteRepositoryImpl(sharedPreferences: newPrefs);
    final Result<Set<String>> favourites =
        await newRepository.getFavourites();
    expect(result.isRight(), isTrue);
    expect(favourites.isRight(), isTrue);
    favourites.fold(
      (_) => fail('Expected favourites result to be Right'),
      (set) {
        expect(set.contains('venue_2'), isTrue);
      },
    );
  });
}
