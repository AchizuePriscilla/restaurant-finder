abstract class VenueEvent {
  const VenueEvent();
}

class LocationObservingStarted extends VenueEvent {
  const LocationObservingStarted();
}

class ToggleFavouriteVenue extends VenueEvent {
  const ToggleFavouriteVenue(this.venueId);

  final String venueId;
}
