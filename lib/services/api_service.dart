import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/chat_room.dart';
import '../screens/chat_detail_screen.dart';


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';
  //static const String baseUrl = 'http://10.0.2.2:5000';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 📋 모든 상품 목록을 서버에서 가져오는 함수
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('상품 목록을 불러올 수 없습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다: $e');
    }
  }

  // 🆕 새로운 상품을 서버에 등록하는 함수
  static Future<Product> createProduct(Map<String, dynamic> productData) async {
    productData['Product_State'] = true; // 판매중 상태 기본값

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: json.encode(productData),
      );
      if (response.statusCode == 201) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('상품을 등록할 수 없습니다.');
      }
    } catch (e) {
      throw Exception('상품 등록 중 오류: $e');
    }
  }

  // 🔍 상품 상세 정보를 가져오는 함수
  static Future<Product> getProductDetail(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$productId'), headers: headers);
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('상품 정보를 불러올 수 없습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다: $e');
    }
  }

  // 👤 특정 사용자 ID로 프로필 정보를 가져오는 함수
  static Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      // API 경로: /users/{user_id}
      final response = await http.get(Uri.parse('$baseUrl/users/$userId'), headers: headers);

      if (response.statusCode == 200) {
        // 백엔드가 단일 사용자 객체를 반환하므로 Map<String, dynamic>으로 디코딩
        return json.decode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 404) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      } else {
        throw Exception('사용자 정보를 불러올 수 없습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다: $e');
    }
  }

  // 📋 내 채팅방 목록을 가져오는 함수
  static Future<List<ChatRoom>> fetchChatRooms(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chats?userId=$userId'), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        throw Exception('채팅 목록을 불러올 수 없습니다.');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다: $e');
    }
  }

  // 🗨️ 특정 채팅방의 모든 메시지를 가져오는 함수
  static Future<List<ChatMessage>> fetchMessages(String chatRoomId, String currentUserId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chats/$chatRoomId/messages'), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => ChatMessage.fromJson(json, currentUserId)).toList();
      } else {
        throw Exception('메시지 목록을 불러올 수 없습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('서버와 연결할 수 없습니다: $e');
    }
  }

  // 💬 채팅 메시지를 전송하는 함수
  static Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String message,
  }) async {
    try {
      final requestBody = {
        'Message_Chat': chatRoomId,
        'Message_User': senderId,
        'Message_Text': message,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: headers,
        body: json.encode(requestBody),
      );
      if (response.statusCode != 201) {
        throw Exception('메시지를 전송할 수 없습니다.');
      }
    } catch (e) {
      throw Exception('메시지 전송 중 오류: $e');
    }
  }

  // 📍 특정 지역 근처의 상품들을 가져오는 함수
  static Future<List<Product>> fetchProductsByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/nearby?lat=$latitude&lng=$longitude&radius=$radiusKm'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('근처 상품을 찾을 수 없습니다.');
      }
    } catch (e) {
      throw Exception('위치 기반 검색 중 오류: $e');
    }
  }
}