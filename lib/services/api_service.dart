// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/chat_room.dart';

/// 🔥 백엔드와 소통하는 모든 함수들이 여기 있습니다!
/// 프론트엔드는 이 클래스의 함수들을 호출해서 데이터를 받아옵니다.
class ApiService {
  // TODO: 실제 서버 주소로 변경해야 합니다!
  static const String baseUrl = 'https://your-backend-server.com/api';

  // HTTP 요청 시 사용할 공통 헤더
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ========================================
  // 🏠 상품 관련 API 함수들
  // ========================================

  /// 📋 모든 상품 목록을 서버에서 가져오는 함수
  /// 사용 위치: home_page.dart의 initState()에서 호출
  static Future<List<Product>> fetchProducts() async {
    try {
      print('🔄 서버에서 상품 목록 가져오는 중...');

      // GET 요청을 서버에 보냅니다
      final response = await http.get(
                    //지정한 api주소로 보냅니다.
        Uri.parse('$baseUrl/products'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // ✅ 성공: JSON 데이터를 Product 객체 리스트로 변환
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Product> products = jsonData
            .map((json) => Product.fromJson(json))
            .toList();

        print('✅ 상품 ${products.length}개 가져오기 성공!');
        return products;

      } else {
        // ❌ 실패: 에러 메시지 출력
        print('❌ 상품 목록 가져오기 실패: ${response.statusCode}');
        throw Exception('상품 목록을 불러올 수 없습니다.');
      }

    } catch (e) {
      // 🚨 네트워크 오류 등의 예외 처리
      print('🚨 네트워크 오류: $e');
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  /// 🆕 새로운 상품을 서버에 등록하는 함수
  /// 사용 위치: sell_item_screen.dart의 등록 버튼 클릭 시
  static Future<Product> createProduct(Product product) async {
    try {
      print('🔄 새 상품 등록 중...');

      // POST 요청으로 상품 데이터를 서버에 전송
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: json.encode(product.toJson()), // Product 객체를 JSON으로 변환
      );

      if (response.statusCode == 201) { // 201 = Created
        // ✅ 성공: 서버가 생성한 상품 정보 반환
        final jsonData = json.decode(response.body);
        final createdProduct = Product.fromJson(jsonData);

        print('✅ 상품 등록 성공! ID: ${createdProduct.Product_Number}');
        return createdProduct;

      } else {
        print('❌ 상품 등록 실패: ${response.statusCode}');
        throw Exception('상품을 등록할 수 없습니다.');
      }

    } catch (e) {
      print('🚨 상품 등록 오류: $e');
      throw Exception('상품 등록 중 오류가 발생했습니다.');
    }
  }

  /// 🔍 상품 상세 정보를 가져오는 함수
  /// 사용 위치: product_detail_screen.dart에서 추가 정보 필요 시
  static Future<Product> getProductDetail(int productId) async {
    try {
      print('🔄 상품 $productId 상세정보 가져오는 중...');

      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final product = Product.fromJson(jsonData);

        print('✅ 상품 상세정보 가져오기 성공!');
        return product;

      } else {
        throw Exception('상품 정보를 불러올 수 없습니다.');
      }

    } catch (e) {
      print('🚨 상품 상세정보 오류: $e');
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  /// ✏️ 상품 정보를 수정하는 함수
  /// 사용 위치: 상품 수정 화면에서 호출
  static Future<Product> updateProduct(Product product) async {
    try {
      print('🔄 상품 ${product.Product_Number} 수정 중...');

      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.Product_Number}'),
        headers: headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final updatedProduct = Product.fromJson(jsonData);

        print('✅ 상품 수정 성공!');
        return updatedProduct;

      } else {
        throw Exception('상품을 수정할 수 없습니다.');
      }

    } catch (e) {
      print('🚨 상품 수정 오류: $e');
      throw Exception('상품 수정 중 오류가 발생했습니다.');
    }
  }

  /// 🗑️ 상품을 삭제하는 함수
  /// 사용 위치: 상품 관리 화면에서 삭제 버튼 클릭 시
  static Future<void> deleteProduct(int productId) async {
    try {
      print('🔄 상품 $productId 삭제 중...');

      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      );

      if (response.statusCode == 204) { // 204 = No Content
        print('✅ 상품 삭제 성공!');
      } else {
        throw Exception('상품을 삭제할 수 없습니다.');
      }

    } catch (e) {
      print('🚨 상품 삭제 오류: $e');
      throw Exception('상품 삭제 중 오류가 발생했습니다.');
    }
  }

  // ========================================
  // 💬 채팅 관련 API 함수들
  // ========================================

  /// 📋 내 채팅방 목록을 가져오는 함수
  /// 사용 위치: home_page.dart의 initState()와 채팅 탭 클릭 시
  static Future<List<ChatRoom>> fetchChatRooms(int userId) async {
    try {
      print('🔄 사용자 $userId의 채팅방 목록 가져오는 중...');

      final response = await http.get(
        Uri.parse('$baseUrl/chats?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<ChatRoom> chatRooms = jsonData
            .map((json) => ChatRoom.fromJson(json))
            .toList();

        print('✅ 채팅방 ${chatRooms.length}개 가져오기 성공!');
        return chatRooms;

      } else {
        throw Exception('채팅 목록을 불러올 수 없습니다.');
      }

    } catch (e) {
      print('🚨 채팅방 목록 오류: $e');
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  /// 💌 새로운 채팅방을 생성하는 함수
  /// 사용 위치: product_detail_screen.dart에서 첫 채팅 시작 시
  static Future<ChatRoom> createChatRoom({
    required int productId,
    required int buyerId,
    required int sellerId,
    required String firstMessage,
  }) async {
    try {
      print('🔄 새 채팅방 생성 중...');

      final requestBody = {
        'product_id': productId,
        'buyer_id': buyerId,
        'seller_id': sellerId,
        'first_message': firstMessage,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/chats'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final chatRoom = ChatRoom.fromJson(jsonData);

        print('✅ 채팅방 생성 성공! ID: ${chatRoom.Chat_Number}');
        return chatRoom;

      } else {
        throw Exception('채팅방을 생성할 수 없습니다.');
      }

    } catch (e) {
      print('🚨 채팅방 생성 오류: $e');
      throw Exception('채팅방 생성 중 오류가 발생했습니다.');
    }
  }

  /// 💬 채팅 메시지를 전송하는 함수
  /// 사용 위치: chat_detail_screen.dart에서 메시지 전송 시
  static Future<void> sendMessage({
    required int chatRoomId,
    required int senderId,
    required String message,
  }) async {
    try {
      print('🔄 메시지 전송 중...');

      final requestBody = {
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        print('✅ 메시지 전송 성공!');
      } else {
        throw Exception('메시지를 전송할 수 없습니다.');
      }

    } catch (e) {
      print('🚨 메시지 전송 오류: $e');
      throw Exception('메시지 전송 중 오류가 발생했습니다.');
    }
  }

  // ========================================
  // 🌍 위치 관련 API 함수들 (지도 화면용)
  // ========================================

  /// 📍 특정 지역 근처의 상품들을 가져오는 함수
  /// 사용 위치: map_screen.dart에서 지도에 마커 표시 시
  static Future<List<Product>> fetchProductsByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0, // 기본 반경 5km
  }) async {
    try {
      print('🔄 위치 기반 상품 검색 중... (반경 ${radiusKm}km)');

      final response = await http.get(
        Uri.parse('$baseUrl/products/nearby?lat=$latitude&lng=$longitude&radius=$radiusKm'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Product> products = jsonData
            .map((json) => Product.fromJson(json))
            .toList();

        print('✅ 근처 상품 ${products.length}개 찾음!');
        return products;

      } else {
        throw Exception('근처 상품을 찾을 수 없습니다.');
      }

    } catch (e) {
      print('🚨 위치 기반 검색 오류: $e');
      throw Exception('위치 기반 검색 중 오류가 발생했습니다.');
    }
  }

  // ========================================
  // 🔍 검색 관련 API 함수들
  // ========================================

  /// 🔍 키워드로 상품을 검색하는 함수
  /// 사용 위치: 검색 화면에서 검색어 입력 시
  static Future<List<Product>> searchProducts(String keyword) async {
    try {
      print('🔄 "$keyword" 검색 중...');

      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=${Uri.encodeComponent(keyword)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Product> products = jsonData
            .map((json) => Product.fromJson(json))
            .toList();

        print('✅ 검색 결과 ${products.length}개 찾음!');
        return products;

      } else {
        throw Exception('검색 중 오류가 발생했습니다.');
      }

    } catch (e) {
      print('🚨 검색 오류: $e');
      throw Exception('검색 중 오류가 발생했습니다.');
    }
  }

  // ========================================
  // ⚡ 유틸리티 함수들
  // ========================================

  /// 🔄 서버 연결 상태를 확인하는 함수
  /// 사용 위치: 앱 시작 시 또는 오류 발생 시
  static Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('🚨 서버 연결 확인 실패: $e');
      return false;
    }
  }

  /// 🔐 사용자 인증 토큰을 갱신하는 함수 (추후 로그인 기능용)
  /// 사용 위치: 로그인/회원가입 완료 후
  static Future<String?> refreshAuthToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: headers,
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['access_token'];
      } else {
        return null;
      }
    } catch (e) {
      print('🚨 토큰 갱신 오류: $e');
      return null;
    }
  }
}
