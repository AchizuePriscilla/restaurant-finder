import '../../domain/entities/venue.dart';

class VenueDto {
  const VenueDto({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String shortDescription;
  final String imageUrl;

  static VenueDto? fromApiItem(Map<String, dynamic> itemJson) {
    final venueJson = _asMap(itemJson['venue']);
    if (venueJson == null) {
      return null;
    }

    final id = _asString(venueJson['id']).trim();
    final name = _asString(venueJson['name']).trim();
    if (id.isEmpty || name.isEmpty) {
      return null;
    }

    final shortDescription =
        _asString(venueJson['short_description']).trim();
    final imageJson = _asMap(itemJson['image']);
    final imageUrl = _asString(imageJson?['url']).trim();

    return VenueDto(
      id: id,
      name: name,
      shortDescription: shortDescription,
      imageUrl: imageUrl,
    );
  }

  Venue toDomain({required bool isFavourite}) {
    return Venue(
      id: id,
      name: name,
      description: shortDescription,
      imageUrl: imageUrl,
      isFavourite: isFavourite,
    );
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  static String _asString(Object? value) {
    if (value is String) {
      return value;
    }
    return '';
  }
}
