import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restaurant_finder/domain/providers/location_provider.dart';
import 'package:restaurant_finder/domain/usecases/apply_favourites_to_venues.dart';
import 'package:restaurant_finder/domain/usecases/get_venues_for_location.dart';
import 'package:restaurant_finder/domain/usecases/toggle_favourite.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';
import 'package:restaurant_finder/presentation/state/venue_state.dart';
import 'package:restaurant_finder/presentation/bloc/venue_event.dart';
import 'package:restaurant_finder/presentation/utils/error_message.dart';

class VenueBloc extends Bloc<VenueEvent, VenueState> {
  VenueBloc({
    required LocationProvider locationProvider,
    required GetVenuesForLocation getVenuesForLocation,
    required ApplyFavouritesToVenues applyFavouritesToVenues,
    required ToggleFavouriteUseCase toggleFavouriteUseCase,
  }) : _locationProvider = locationProvider,
       _getVenuesForLocation = getVenuesForLocation,
       _applyFavouritesToVenues = applyFavouritesToVenues,
       _toggleFavouriteUseCase = toggleFavouriteUseCase,
       super(VenueState.initial()) {
    on<LocationObservingStarted>(_onStarted);
    on<ToggleFavouriteVenue>(_onToggleFavourite);
  }

  static const int _venueLimit = 15;

  final LocationProvider _locationProvider;
  final GetVenuesForLocation _getVenuesForLocation;
  final ApplyFavouritesToVenues _applyFavouritesToVenues;
  final ToggleFavouriteUseCase _toggleFavouriteUseCase;

  bool _started = false;

  Future<void> _onStarted(
    LocationObservingStarted event,
    Emitter<VenueState> emit,
  ) async {
    if (_started) {
      return;
    }
    _started = true;
    await emit.onEach<LatLng>(
      _locationProvider.locationStream(),
      onData: (location) => _handleLocation(location, emit),
      onError: (error, _) => _handleLocationError(error, emit),
    );
  }

  Future<void> _onToggleFavourite(
    ToggleFavouriteVenue event,
    Emitter<VenueState> emit,
  ) async {
    final result = await _toggleFavouriteUseCase(event.venueId);

    await result.fold(
      (failure) async {
        final message = messageForError(
          failure,
          fallback: 'Failed to toggle favourite.',
        );
        emit(state.copyWith(errorMessage: message));
      },
      (_) async {
        final updated = state.venues
            .map(
              (venue) => venue.id == event.venueId
                  ? venue.copyWith(isFavourite: !venue.isFavourite)
                  : venue,
            )
            .toList(growable: false);
        emit(state.copyWith(venues: updated, clearErrorMessage: true));
      },
    );
  }

  Future<void> _handleLocation(
    LatLng location,
    Emitter<VenueState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final result = await _getVenuesForLocation(location, limit: _venueLimit);

    await result.fold(
      (failure) async {
        final message = messageForError(
          failure,
          fallback: 'Failed to fetch venues.',
        );
        emit(state.copyWith(isLoading: false, errorMessage: message));
      },
      (venues) async {
        final favouritesResult = await _applyFavouritesToVenues(venues);
        await favouritesResult.fold(
          (failure) async {
            final message = messageForError(
              failure,
              fallback: 'Failed to fetch venues.',
            );
            emit(state.copyWith(isLoading: false, errorMessage: message));
          },
          (venuesWithFavourites) async {
            emit(
              state.copyWith(
                currentLocation: location,
                venues: venuesWithFavourites,
                isLoading: false,
                clearErrorMessage: true,
              ),
            );
          },
        );
      },
    );
  }

  void _handleLocationError(Object error, Emitter<VenueState> emit) {
    emit(
      state.copyWith(isLoading: false, errorMessage: 'Location stream error.'),
    );
  }
}
