# Restaurant Finder

Architecture, main decisions, and setup.

---

## Architecture

I went with clean architecture for clear separation of concerns: data → domain ← presentation. Presentation and domain don’t import data-layer types, and the domain has no Flutter or HTTP. Data just implements the repository and provider interfaces from the domain.

**Flow:** `LocationProvider` (domain interface) exposes `Stream<LatLng>`. VenueBloc subscribes and calls `GetVenuesForLocation` then `ApplyFavouritesToVenues`. The BLoC never touches repositories—it only gets use cases in the constructor. Toggle favourite goes through `ToggleFavouriteUseCase`. The UI just listens to bloc state.

---

## Decisions

1. **ApiClient** — The data layer depends on `ApiClient.getJson()`; Dio lives only in `DioApiClient`. Because the data source takes an `ApiClient`, tests can pass a mock (see `venue_remote_data_source_test.dart`) and avoid real HTTP. The domain never touches HTTP.

2. **AppDi** — One class builds the dependencies and `MainApp` takes it. In tests I pass optional `venueRepository` and `locationProvider` into `AppDi.create()` and run the same `MainApp`. There aren’t many dependencies, so I create and pass them in one place instead of introducing a DI package like get_it.

3. **LocationProvider** — Domain interface returns `Stream<LatLng>`; data implements it and the BLoC gets it in the constructor. In tests I pass a provider that returns a fixed stream (e.g. `FixedLocationProvider` in the integration test, or a mock in unit tests).

4. **Favourites** — `FavouriteRepository` (interface) persists IDs; `ApplyFavouritesToVenues` merges that into venue lists from `VenueRepository`. The domain never imports SharedPreferences.

5. **One BLoC** — VenueBloc holds loading, venues, error and only calls the use cases it was given (no repository fields in `venue_bloc.dart`).

6. **`Result<T>` / Failure** — Use cases and repos return `Either<Failure, T>`. Exceptions become `Failure` in the data layer (`api_exception_extensions.dart`); user-facing strings live in `error_message.dart`. No try/catch in use cases or bloc for this.

---

## Project structure

```
lib/
├── main.dart, di/app_di.dart
├── domain/          — entities, value_objects, core/result, errors/failure,
│                     providers/location_provider, repositories/*, usecases/*
├── data/            — datasources, models (DTOs), mapper, network (api_client, dio_api_client),
│                     providers/location_provider_impl, repositories/*_impl
└── presentation/    — bloc, state, pages, widgets, utils/error_message
```

---

## Setup

Flutter SDK ^3.9.0.

Wolt base URL is in `AppDi.defaultConfig`. You can override `ApiConfig` in `AppDi.create()` for tests.

```bash
flutter pub get && flutter run
flutter test
flutter test integration_test/favourites_persist_test.dart
```

---

## Dependencies

`flutter_bloc`, `dartz` (Either/Result), `equatable`, `dio` (data layer only), `shared_preferences` (data layer only). Dev: `mocktail`, `bloc_test`, `flutter_lints`, `integration_test`, `fake_async`.

---

## Tests

- **Unit** — Use cases, repos, data sources; mocks for dependencies, no real network or storage.
- **Widget** — `venue_view_model_test` adds events to the bloc and asserts on state (blocTest); `venue_page_widget_test` pumps the page with a bloc, adds events, and asserts on UI.
- **Integration** — `favourites_persist_test` runs the app with a fixed repo and provider (`FixedVenueRepository`, `FixedLocationProvider`), toggles a favourite, restarts with the same SharedPreferences, and checks the favourite is still there.
