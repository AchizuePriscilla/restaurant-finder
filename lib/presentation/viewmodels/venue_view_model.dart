import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/venue.dart';
import '../../domain/repositories/location_provider.dart';
import '../../domain/usecases/get_venues_for_location.dart';
import '../../domain/usecases/toggle_favourite.dart';
import '../../domain/value_objects/lat_lng.dart';
import '../providers/dependencies.dart';
import '../state/venue_state.dart';

class VenueViewModel extends Notifier<VenueState> {
  late final LocationProvider _locationProvider;
  late final GetVenuesForLocation _getVenuesForLocation;
  late final ToggleFavourite _toggleFavourite;

  StreamSubscription<LatLng>? _subscription;
  int _requestId = 0;
  bool _started = false;

  @override
  VenueState build() {
    _locationProvider = ref.read(locationProviderProvider);
    _getVenuesForLocation = ref.read(getVenuesForLocationProvider);
    _toggleFavourite = ref.read(toggleFavouriteProvider);
    Future.microtask(_start);
    ref.onDispose(_dispose);
    return VenueState.initial();
  }

  void _start() {
    if (_started) {
      return;
    }
    _started = true;
    _subscription = _locationProvider.locationStream().listen(
      _handleLocation,
      onError: _handleError,
      cancelOnError: false,
    );
  }

  Future<void> toggleFavourite(String venueId) async {
    try {
      await _toggleFavourite(venueId);
      final updated = _toggleVenueFavourite(state.venues, venueId);
      state = state.copyWith(
        venues: updated,
        clearErrorMessage: true,
      );
      developer.log(
        'Favourite toggled: $venueId',
        name: 'VenueViewModel',
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Failed to toggle favourite.',
      );
      developer.log(
        'Favourite toggle failed: $venueId',
        name: 'VenueViewModel',
        error: error,
      );
    }
  }

  Future<void> _handleLocation(LatLng location) async {
    developer.log(
      'Location received: lat=${location.latitude} lon=${location.longitude}',
      name: 'VenueViewModel',
    );

    state = state.copyWith(
      currentLocation: location,
      isLoading: true,
      clearErrorMessage: true,
    );

    final requestId = ++_requestId;
    developer.log(
      'Venue fetch start',
      name: 'VenueViewModel',
    );

    try {
      final venues = await _getVenuesForLocation(location);
      if (requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        venues: venues,
        isLoading: false,
        clearErrorMessage: true,
      );
      developer.log(
        'Venue fetch success: count=${venues.length}',
        name: 'VenueViewModel',
      );
    } catch (error) {
      if (requestId != _requestId) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch venues.',
      );
      developer.log(
        'Venue fetch failed',
        name: 'VenueViewModel',
        error: error,
      );
    }
  }

  void _handleError(Object error) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Location stream error.',
    );
    developer.log(
      'Location stream error',
      name: 'VenueViewModel',
      error: error,
    );
  }

  List<Venue> _toggleVenueFavourite(List<Venue> venues, String venueId) {
    return venues
        .map(
          (venue) => venue.id == venueId
              ? venue.copyWith(isFavourite: !venue.isFavourite)
              : venue,
        )
        .toList(growable: false);
  }

  Future<void> _dispose() async {
    final sub = _subscription;
    _subscription = null;
    await sub?.cancel();
  }
}
