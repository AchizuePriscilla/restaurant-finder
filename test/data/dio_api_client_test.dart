import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:restaurant_finder/data/errors/api_exception.dart';
import 'package:restaurant_finder/data/network/dio_api_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DioApiClient client;

  setUp(() {
    mockDio = MockDio();
    client = DioApiClient(dio: mockDio);
  });

  test('maps Dio timeout error to ApiException.timeout', () async {
    when(
      () => mockDio.get<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    expect(
      () => client.getJson(''),
      throwsA(
        isA<ApiException>().having(
          (e) => e.type,
          'type',
          ApiExceptionType.timeout,
        ),
      ),
    );
  });

  test('maps Dio badResponse to ApiException.network', () async {
    when(
      () => mockDio.get<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      ),
    );

    expect(
      () => client.getJson(''),
      throwsA(
        isA<ApiException>()
            .having((e) => e.type, 'type', ApiExceptionType.network)
            .having((e) => e.statusCode, 'statusCode', 500),
      ),
    );
  });

  test('maps Dio connectionError to ApiException.network', () async {
    when(
      () => mockDio.get<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(
      () => client.getJson(''),
      throwsA(
        isA<ApiException>().having(
          (e) => e.type,
          'type',
          ApiExceptionType.network,
        ),
      ),
    );
  });

  test('throws ApiException.parsing when response data is not a Map', () async {
    final response = Response<Object?>(
      requestOptions: RequestOptions(path: ''),
      data: 'not a map',
    );

    when(
      () => mockDio.get<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => response);

    expect(
      () => client.getJson(''),
      throwsA(
        isA<ApiException>().having(
          (e) => e.type,
          'type',
          ApiExceptionType.parsing,
        ),
      ),
    );
  });
}

