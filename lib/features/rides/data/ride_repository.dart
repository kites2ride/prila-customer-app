import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer/core/network/api_client.dart';

final rideRepositoryProvider = Provider<RideRepository>(
  (ref) => RideRepository(ref.watch(dioProvider)),
);

class RideRepository {
  RideRepository(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> estimate({
    required String serviceType,
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    required double dropLat,
    required double dropLng,
    required String dropName,
    String? couponCode,
    bool shakti = false,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rides/estimate',
        data: {
          'serviceType': serviceType,
          'pickup': {'lat': pickupLat, 'lng': pickupLng, 'name': pickupName},
          'drop': {'lat': dropLat, 'lng': dropLng, 'name': dropName},
          if (couponCode != null) 'couponCode': couponCode,
          'shakti': shakti,
          'paymentMethod': 'cash',
        },
      );
      return res.data ?? {};
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> book({
    required String quoteId,
    required String idempotencyKey,
    String? payAt,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rides',
        data: {
          'quoteId': quoteId,
          'idempotencyKey': idempotencyKey,
          'paymentMethod': 'cash',
          'payAt': ?payAt, // parcels only: 'pickup' | 'drop'
        },
      );
      return res.data ?? {};
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>?> active() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/rides/active');
      return res.data?['ride'] as Map<String, dynamic>?;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> get(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/rides/$id');
      return res.data ?? {};
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> cancel(String id, String reasonCode) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rides/$id/cancel',
        data: {'reasonCode': reasonCode},
      );
      return res.data ?? {};
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> rate(String id, int rating, List<String> tags) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rides/$id/rate',
        data: {'rating': rating, 'tags': tags},
      );
      return res.data ?? {};
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> history() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/rides', queryParameters: {'page': 1, 'limit': 20});
      final items = res.data?['items'] as List? ?? [];
      return items.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
