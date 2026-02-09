import 'package:restaurant_finder/data/models/wolt_api_response_dto.dart';
import 'package:restaurant_finder/data/network/api_client.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';

abstract class VenueRemoteDataSource {
  Future<List<RestaurantItemDto>> fetchNearbyVenues(LatLng location);
}

class VenueRemoteDataSourceImpl implements VenueRemoteDataSource {
  VenueRemoteDataSourceImpl({
    required ApiClient client,
  }) : _client = client;

  final ApiClient _client;

  @override
  Future<List<RestaurantItemDto>> fetchNearbyVenues(LatLng location) async {
    final results = <RestaurantItemDto>[];
    final root = await _client.getJson(
      '',
      queryParameters: {
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
      },
    );
    final apiResponse = WoltApiResponseDto.fromJson(root);
    for (final section in apiResponse.sections) {
      for (final item in section.items) {
        if (item.venue != null) {
          results.add(item);
        }
      }
    }

    return List<RestaurantItemDto>.unmodifiable(results);
  }
}
