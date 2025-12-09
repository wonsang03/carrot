// lib/utils/distance_calculator.dart

import 'dart:math';
import '../models/product.dart';

/// 두 지점 간의 거리를 계산하는 유틸리티 클래스
class DistanceCalculator {
  /// Haversine 공식을 사용하여 두 지점 간의 거리를 계산 (단위: km)
  /// 
  /// [lat1, lon1]: 첫 번째 지점의 위도, 경도
  /// [lat2, lon2]: 두 번째 지점의 위도, 경도
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // 유효하지 않은 좌표인 경우 매우 큰 값 반환
    if (lat1 == 0.0 && lon1 == 0.0) return 999999.0;
    if (lat2 == 0.0 && lon2 == 0.0) return 999999.0;

    const double earthRadius = 6371; // 지구 반지름 (km)

    // 위도와 경도를 라디안으로 변환
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    // Haversine 공식
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// 각도를 라디안으로 변환
  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// 사용자 위치를 기준으로 상품 목록을 거리순으로 정렬
  /// 
  /// [products]: 정렬할 상품 목록
  /// [userLat]: 사용자의 위도
  /// [userLon]: 사용자의 경도
  static List<Product> sortByDistance(
    List<Product> products,
    double userLat,
    double userLon,
  ) {
    // 각 상품에 대해 거리를 계산하고 정렬
    final productsWithDistance = products.map((product) {
      final distance = calculateDistance(
        userLat,
        userLon,
        product.latitude,
        product.longitude,
      );
      return {
        'product': product,
        'distance': distance,
      };
    }).toList();

    // 거리순으로 정렬
    productsWithDistance.sort((a, b) => 
      (a['distance'] as double).compareTo(b['distance'] as double)
    );

    return productsWithDistance
        .map((item) => item['product'] as Product)
        .toList();
  }

  /// 거리를 포맷팅하여 문자열로 반환 (예: "1.2km", "500m")
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()}m';
    } else {
      return '${distanceKm.toStringAsFixed(1)}km';
    }
  }
}

