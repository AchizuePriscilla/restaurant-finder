import 'package:restaurant_finder/data/models/wolt_api_response_dto.dart';
import 'package:restaurant_finder/domain/entities/venue.dart';

/// Shared test Venue factory. Use for domain and presentation tests.
Venue venueEntity(String id, {bool isFavourite = false}) {
  return Venue(
    id: id,
    name: 'Venue $id',
    description: 'Desc $id',
    imageUrl: '',
    isFavourite: isFavourite,
  );
}

/// Shared test RestaurantItemDto factory. Use for data-layer tests.
RestaurantItemDto restaurantItemDto(
  String id,
  String name,
  String desc,
  String imageUrl,
) {
  return RestaurantItemDto(
    image: ImageDto(url: imageUrl),
    venue: VenueDetailsDto(id: id, name: name, shortDescription: desc),
  );
}
