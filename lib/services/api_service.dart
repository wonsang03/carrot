// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/chat_room.dart';
// chat_detail_screen.dart 파일의 경로에 맞게 수정해야 할 수 있습니다.
import '../screens/chat_detail_screen.dart';

/// 🔥 백엔드와 소통하는 모든 함수들이 여기 있습니다!
/// 프론트엔드는 이 클래스의 함수들을 호출해서 데이터를 받아옵니다.
class ApiService {
  // 윈도우 데스크톱에서 테스트하므로 127.0.0.1 사용
  static const String baseUrl = 'http://127.0.0.1:5000';

  // HTTP 요청 시 사용할 공통 헤더
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ========================================
  // 🏠 상품 관련 API 함수들
  // ========================================

  /// 📋 모든 상품 목록을 서버에서 가져오는 함수
  static Future<List<Product>> fetchProducts() async {
    try {
      print('🔄 서버에서 상품 목록 가져오는 중...');
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        // 한글 깨짐 방지를 위해 utf8 디코딩
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        final List<Product> products = jsonData
            .map((json) => Product.fromJson(json))
            .toList();
        print('✅ 상품 ${products.length}개 가져오기 성공!');
        return products;
      } else {
        print('❌ 상품 목록 가져오기 실패: ${response.statusCode}');
        throw Exception('상품 목록을 불러올 수 없습니다.');
      }
    } catch (e) {
      print('🚨 네트워크 오류: $e');
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  /// 🆕 새로운 상품을 서버에 등록하는 함수
  static Future<Product> createProduct(Product product) async {
    try {
      print('🔄 새 상품 등록 중...');
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: json.encode(product.toJson()),
      );
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final createdProduct = Product.fromJson(jsonData);
        print('✅ 상품 등록 성공! ID: ${createdProduct.Product_Number}');
        return createdProduct;
      } else {
        throw Exception('상품을 등록할 수 없습니다.');
      }
    } catch (e) {
      print('🚨 상품 등록 오류: $e');
      throw Exception('상품 등록 중 오류가 발생했습니다.');
    }
  }

  /// 🔍 상품 상세 정보를 가져오는 함수
  static Future<Product> getProductDetail(String productId) async {
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
  static Future<void> deleteProduct(String productId) async {
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
  static Future<List<ChatRoom>> fetchChatRooms(String userId) async {
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
  static Future<ChatRoom> createChatRoom({
    required String productId,
    required String buyerId,
    required String sellerId,
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
  static Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
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

  /// 🗨️ 특정 채팅방의 모든 메시지를 가져오는 함수 (✨ 새로 추가된 부분)
  static Future<List<ChatMessage>> fetchMessages(String chatRoomId, String currentUserId) async {
    try {
      print('🔄 채팅방 $chatRoomId의 메시지 목록 가져오는 중...');
      // 백엔드에 "GET /chats/{chat_id}/messages" 와 같은 API가 있다고 가정합니다.
      // 이 URL은 실제 백엔드 API 엔드포인트에 맞춰야 합니다.
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatRoomId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        // JSON 데이터를 ChatMessage 객체 리스트로 변환합니다.
        // 이 과정에서 현재 로그인한 유저의 ID와 메시지 발신자 ID를 비교하여 isMe 값을 설정합니다.
        final List<ChatMessage> messages = jsonData
            .map((json) => ChatMessage.fromJson(json, currentUserId))
            .toList();
        print('✅ 메시지 ${messages.length}개 가져오기 성공!');
        return messages;
      } else {
        throw Exception('메시지 목록을 불러올 수 없습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 메시지 목록 오류: $e');
      throw Exception('서버와 연결할 수 없습니다.');
    }
  }

  // ========================================
  // 🌍 위치 관련 API 함수들 (지도 화면용)
  // ========================================

  /// 📍 특정 지역 근처의 상품들을 가져오는 함수
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