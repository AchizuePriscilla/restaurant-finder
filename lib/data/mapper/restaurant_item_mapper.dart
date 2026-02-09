import '../../domain/entities/venue.dart';
import '../models/wolt_api_response_dto.dart';

extension RestaurantItemDtoMapper on RestaurantItemDto {
  Venue toDomain({bool isFavourite = false}) {
    final venue = this.venue;
    if (venue == null) {
      throw StateError(
        'RestaurantItemDto must have venue to map to domain',
      );
    }
    return Venue(
      id: venue.id,
      name: venue.name,
      description: venue.shortDescription,
      imageUrl: image.url,
      isFavourite: isFavourite,
    );
  }
}
