import 'dart:convert';
import 'dart:io'; // ✨ [추가] 파일 처리를 위해 필요
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // ✨ 파일 타입 지정을 위해 필요
import '../models/product.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';


class ApiService {
  // 플랫폼에 따라 서버 URL 자동 설정
  static String get baseUrl {
    if (kIsWeb) {
      // 웹에서는 상대 경로 또는 실제 서버 주소 사용
      return 'http://127.0.0.1:5000';
    } else if (Platform.isAndroid) {
      // 안드로이드 에뮬레이터
      return 'http://10.0.2.2:5000';
    } else {
      // iOS, Windows, Linux, macOS 등
      return 'http://127.0.0.1:5000';
    }
  }
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 📋 모든 상품 목록을 서버에서 가져오는 함수
  static Future<List<Product>> fetchProducts() async {
    try {
      print('🔄 서버 연결 시도: $baseUrl/products');
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('서버 연결 시간이 초과되었습니다. 서버가 실행 중인지 확인해주세요.');
        },
      );
      
      print('📡 응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ 상품 ${jsonData.length}개 로드 성공');
        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        print('❌ 서버 응답 오류: ${response.statusCode} - ${response.body}');
        throw Exception('상품 목록을 불러올 수 없습니다. (상태 코드: ${response.statusCode})');
      }
    } catch (e) {
      print('❌ 상품 로딩 실패: $e');
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception('서버에 연결할 수 없습니다.\n서버가 실행 중인지 확인해주세요.\n\n서버 주소: $baseUrl');
      }
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
      print('🔄 사용자 프로필 로드 시도: $baseUrl/users/$userId');
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('서버 연결 시간이 초과되었습니다.');
        },
      );

      print('📡 사용자 프로필 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 백엔드가 단일 사용자 객체를 반환하므로 Map<String, dynamic>으로 디코딩
        final userData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ 사용자 프로필 로드 성공');
        return userData;
      } else if (response.statusCode == 404) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      } else {
        throw Exception('사용자 정보를 불러올 수 없습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 사용자 프로필 로딩 실패: $e');
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception('서버에 연결할 수 없습니다.\n서버가 실행 중인지 확인해주세요.');
      }
      throw Exception('서버와 연결할 수 없습니다: $e');
    }
  }

  // ✨ [추가] 이미지를 업로드하고 URL을 반환하는 범용 함수
  static Future<String> uploadImage(File imageFile, {String type = 'product'}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      
      // 업로드 타입 지정 ('profile' 또는 'product')
      request.fields['type'] = type;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        throw Exception('이미지 업로드 실패: ${response.body}');
      }

      final responseData = json.decode(response.body);
      return responseData['url']; // 업로드된 이미지 URL 반환

    } catch (e) {
      throw Exception('이미지 업로드 중 오류: $e');
    }
  }

  // ✨ [기존] 사용자 프로필 이미지 업로드 및 업데이트 함수
  static Future<void> updateUserProfileImage(String userId, File imageFile) async {
    try {
      // 1. 이미지 업로드 (프로필 타입)
      final imageUrl = await uploadImage(imageFile, type: 'profile');

      // 2. 사용자 정보 업데이트 요청 (PUT /users/{user_id})
      final updateResponse = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: json.encode({'User_Image': imageUrl}),
      );

      if (updateResponse.statusCode != 200) {
        throw Exception('사용자 정보 업데이트 실패');
      }

    } catch (e) {
      throw Exception('프로필 이미지 변경 중 오류: $e');
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

  // 📢 특정 채팅방의 메시지를 모두 '읽음'으로 표시하는 함수 (기존 함수 유지)
  static Future<void> markChatAsRead(String chatRoomId) async {
    try {
      // 서버의 POST /chats/<chat_id>/read 엔드포인트를 호출
      final response = await http.post(
        Uri.parse('$baseUrl/chats/$chatRoomId/read'),
        headers: headers,
      );
      // 서버에서 200 (OK) 코드를 기대합니다.
      if (response.statusCode != 200) {
        throw Exception('메시지 읽음 처리에 실패했습니다: ${response.statusCode}');
      }
      // 읽음 처리에 성공하면 아무것도 반환하지 않습니다.
    } catch (e) {
      // 읽음 처리는 필수 기능이 아니므로, 오류가 발생하더라도 앱의 흐름을 막지 않도록 경고만 남깁니다.
      print('Warning: 읽음 처리 API 호출 중 오류 발생: $e');
    }
  }
}
