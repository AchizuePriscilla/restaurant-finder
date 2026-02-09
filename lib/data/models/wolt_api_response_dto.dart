import '../network/json_helpers.dart';

class WoltApiResponseDto {
  const WoltApiResponseDto({required this.sections});

  final List<SectionDto> sections;

  static WoltApiResponseDto fromJson(Map<String, dynamic> json) {
    final sections = asList(json['sections'])
        .map((section) => SectionDto.fromJson(asMap(section)))
        .whereType<SectionDto>()
        .toList(growable: false);
    return WoltApiResponseDto(sections: sections);
  }
}

class SectionDto {
  const SectionDto({required this.name, required this.items});

  final String name;
  final List<RestaurantItemDto> items;

  static SectionDto? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final name = asString(json['name']);
    if (name.isEmpty) {
      return null;
    }
    final items = asList(json['items'])
        .map((item) => RestaurantItemDto.fromJson(asMap(item)))
        .whereType<RestaurantItemDto>()
        .toList(growable: false);
    return SectionDto(name: name, items: items);
  }
}

class RestaurantItemDto {
  const RestaurantItemDto({required this.image, required this.venue});

  final ImageDto image;
  final VenueDetailsDto? venue;

  static RestaurantItemDto? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final imageJson = asMap(json['image']);
    final image = ImageDto.fromJson(imageJson);
    if (image == null) {
      return null;
    }
    final venue = VenueDetailsDto.fromJson(asMap(json['venue']));
    return RestaurantItemDto(image: image, venue: venue);
  }
}

class VenueDetailsDto {
  const VenueDetailsDto({
    required this.id,
    required this.name,
    required this.shortDescription,
  });

  final String id;
  final String name;
  final String shortDescription;

  static VenueDetailsDto? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final id = asString(json['id']);
    final name = asString(json['name']);
    if (id.isEmpty || name.isEmpty) {
      return null;
    }
    final shortDescription = asString(json['short_description']);
    return VenueDetailsDto(
      id: id,
      name: name,
      shortDescription: shortDescription,
    );
  }
}

class ImageDto {
  const ImageDto({required this.url});

  final String url;

  static ImageDto? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final url = asString(json['url']);
    return ImageDto(url: url);
  }
}
