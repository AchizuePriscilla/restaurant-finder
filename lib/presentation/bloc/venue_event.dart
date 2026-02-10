import 'package:equatable/equatable.dart';

abstract class VenueEvent extends Equatable {
  const VenueEvent();

  @override
  List<Object?> get props => [];
}

class LocationObservingStarted extends VenueEvent {
  const LocationObservingStarted();
}

class ToggleFavouriteVenue extends VenueEvent {
  const ToggleFavouriteVenue(this.venueId);

  final String venueId;

  @override
  List<Object?> get props => [venueId];
}
