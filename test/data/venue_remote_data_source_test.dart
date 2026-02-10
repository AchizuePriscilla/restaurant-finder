import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:restaurant_finder/data/datasources/venue_remote_data_source.dart';
import 'package:restaurant_finder/data/errors/api_exception.dart';
import 'package:restaurant_finder/data/network/api_client.dart';
import 'package:restaurant_finder/domain/value_objects/lat_lng.dart';
import '../helpers/mocks.dart';

class _StubApiClient implements ApiClient {
  _StubApiClient(this.response);

  final Map<String, dynamic> response;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async =>
      response;
}

void main() {
  late MockApiClient mockApiClient;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockApiClient = MockApiClient();
  });

  const location = LatLng(latitude: 60.17, longitude: 24.94);

  test('throws ApiException for malformed JSON', () async {
    final apiException = ApiException(
      message: 'Invalid JSON response',
      type: ApiExceptionType.parsing,
    );
    when(() => mockApiClient.getJson(any(), queryParameters: any(named: 'queryParameters')))
        .thenThrow(apiException);

    final dataSource = VenueRemoteDataSourceImpl(client: mockApiClient);

    expect(
      () => dataSource.fetchNearbyVenues(location),
      throwsA(
        isA<ApiException>().having(
          (error) => error.type,
          'type',
          ApiExceptionType.parsing,
        ),
      ),
    );

    final queryParams = {
      'lat': location.latitude.toString(),
      'lon': location.longitude.toString(),
    };
    verify(() => mockApiClient.getJson('', queryParameters: queryParams))
        .called(1);
  });

  test('parses venues and skips invalid items', () async {
    final fixture =
        File('test/fixtures/restaurants_response.json').readAsStringSync();
    final json = jsonDecode(fixture) as Map<String, dynamic>;
    final client = _StubApiClient(json);

    final dataSource = VenueRemoteDataSourceImpl(client: client);
    final result = await dataSource.fetchNearbyVenues(location);

    expect(result, isNotEmpty);
    expect(result.length, 2);
    expect(result.first.venue?.id, 'venue_1');
    expect(result.first.venue?.name, 'Sushi Place');
    expect(result.first.venue?.shortDescription, 'Fresh nigiri and rolls');
    expect(result.first.image.url, 'https://images.example.com/venue_1.jpg');
    expect(result[1].venue?.id, 'venue_2');
    expect(result[1].venue?.name, 'Burger Joint');
    expect(result[1].venue?.shortDescription, 'Smash burgers and fries');
    expect(result[1].image.url, 'https://images.example.com/venue_2.jpg');
  });
}
