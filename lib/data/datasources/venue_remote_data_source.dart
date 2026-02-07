import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/value_objects/lat_lng.dart';
import '../errors/api_exception.dart';
import '../models/venue_dto.dart';

abstract class VenueRemoteDataSource {
  Future<List<VenueDto>> fetchNearbyVenues(LatLng location);
}

class VenueRemoteDataSourceImpl implements VenueRemoteDataSource {
  VenueRemoteDataSourceImpl({
    required http.Client client,
  }) : _client = client;

  final http.Client _client;

  @override
  Future<List<VenueDto>> fetchNearbyVenues(LatLng location) async {
    final uri = Uri.parse(
      'https://restaurant-api.wolt.com/v1/pages/restaurants',
    ).replace(
      queryParameters: {
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected status code',
        statusCode: response.statusCode,
      );
    }

    final root = _decodeJson(response.body);
    final sections = _asList(root?['sections']);

    final results = <VenueDto>[];
    for (final section in sections) {
      final sectionMap = _asMap(section);
      final items = _asList(sectionMap?['items']);
      for (final item in items) {
        final itemMap = _asMap(item);
        if (itemMap == null) {
          continue;
        }
        final dto = VenueDto.fromApiItem(itemMap);
        if (dto != null) {
          results.add(dto);
        }
      }
    }

    return List<VenueDto>.unmodifiable(results);
  }

  static Map<String, dynamic>? _decodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  static List<Object?> _asList(Object? value) {
    if (value is List) {
      return value;
    }
    return const [];
  }
}
