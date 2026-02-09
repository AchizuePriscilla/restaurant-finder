import 'package:equatable/equatable.dart';

import 'package:restaurant_finder/domain/entities/venue.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

class VenueState extends Equatable {
  const VenueState({
    required this.currentLocation,
    required this.venues,
    required this.isLoading,
    required this.errorMessage,
  });

  final LatLng? currentLocation;
  final List<Venue> venues;
  final bool isLoading;
  final String? errorMessage;

  factory VenueState.initial() {
    return const VenueState(
      currentLocation: null,
      venues: <Venue>[],
      isLoading: false,
      errorMessage: null,
    );
  }

  VenueState copyWith({
    LatLng? currentLocation,
    List<Venue>? venues,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return VenueState(
      currentLocation: currentLocation ?? this.currentLocation,
      venues: List<Venue>.unmodifiable(venues ?? this.venues),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentLocation,
        venues,
        isLoading,
        errorMessage,
      ];
}
