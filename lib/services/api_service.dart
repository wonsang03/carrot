// lib/services/api_service.dart
// 🔥 백엔드(Supabase + Flask)와 소통하는 모든 함수들
// ⭐ 함수명을 통일하고 개발용 사용자 정보를 적용
// 📌 ChatDetailScreen에서 sendMessage 호출을 위해 sendMessage 메서드 추가

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/chat_room.dart';
import 'global_state.dart';  // ⭐ 개발용 사용자 정보 사용

class ApiService {
  // ===== 🌐 서버 설정 =====
  static const String baseUrl = 'http://127.0.0.1:5000';  // Flask 서버 주소

  // HTTP 요청 시 사용할 공통 헤더 (한글 깨짐 방지 포함)
  static const Map<String, String> headers = {
    'Content-Type': 'application/json; charset=utf-8',  // ⭐ UTF-8 추가
    'Accept': 'application/json',
  };

  // 요청 타임아웃 시간
  static const Duration timeoutDuration = Duration(seconds: 10);

  // ========================================
  // 💌 채팅 관련 API 함수들
  // ========================================

  /// 💌 새 메시지 전송 API
  /// @param chatNumber 채팅방 번호 (String)
  /// @param senderId 전송자 사용자 번호 (int)
  /// @param content 전송할 메시지 내용 (String)
  /// @return bool 전송 성공 여부 (true: 성공, false: 실패)
  static Future<bool> sendMessage({
    required String chatNumber,
    required int senderId,
    required String content,
  }) async {
    print('\n💌 [sendMessage] 메시지 전송 시작');
    print('🎯 채팅방 번호: $chatNumber');
    print('👤 발신자 ID: $senderId');
    print('✉️ 메시지 내용: $content');

    final url = '$baseUrl/chats/$chatNumber/messages';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          'sender_id': senderId,  // Supabase 컬럼명과 일치
          'message': content,     // 메시지 내용
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 201) {
        print('✅ sendMessage 성공: HTTP ${response.statusCode}');
        return true;
      } else {
        print('❌ sendMessage 실패: HTTP ${response.statusCode}');
        print('🔍 응답 본문: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 sendMessage 예외 발생: $e');
      return false;
    }
  }

  // ========================================
  // 🏠 상품 관련 API 함수들
  // ========================================

  /// 📋 모든 상품 목록을 서버에서 가져오는 함수
  /// @return List<Product> 상품 목록
  static Future<List<Product>> fetchProducts() async {
    print('\n🔄 [fetchProducts] 시작 - 상품 목록 요청');
    print('📡 요청 URL: $baseUrl/products');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: headers,
      ).timeout(timeoutDuration);

      print('📨 응답 상태: ${response.statusCode}');
      print('📊 응답 크기: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        // ⭐ UTF-8 디코딩으로 한글 깨짐 방지
        final String responseBody = utf8.decode(response.bodyBytes);
        print('📝 디코딩 완료 (${responseBody.length} 문자)');

        final List<dynamic> jsonData = json.decode(responseBody);
        print('✅ JSON 파싱 성공: ${jsonData.length}개 상품');

        // JSON을 Product 객체 리스트로 변환
        final List<Product> products = [];
        for (int i = 0; i < jsonData.length; i++) {
          try {
            final productJson = jsonData[i];
            print('🔄 상품 $i 변환 중: ${productJson['Product_Name']}');

            final Product product = Product.fromJson(productJson);
            products.add(product);
            print('✅ 상품 $i 변환 완료');
          } catch (e) {
            print('❌ 상품 $i 변환 실패: $e');
            // 하나 실패해도 나머지는 계속 처리
          }
        }

        print('🎉 상품 목록 로딩 완료: ${products.length}개');
        return products;
      } else {
        print('❌ 서버 오류: ${response.statusCode}');
        print('🔍 오류 내용: ${response.body}');
        throw Exception('상품 목록을 불러올 수 없습니다 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('💥 fetchProducts 예외: $e');
      rethrow;
    }
  }

  /// 🔍 특정 상품의 상세 정보를 가져오는 함수 ⭐ 함수명 통일
  /// @param productId 상품 번호 (String 타입)
  /// @return Product 상품 상세 정보
  static Future<Product> fetchProductDetail(String productId) async {
    print('\n🔍 [fetchProductDetail] 시작 - 상품 상세 정보 요청');
    print('🎯 대상 상품 번호: $productId');
    print('📡 요청 URL: $baseUrl/products/$productId');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      ).timeout(timeoutDuration);

      print('📨 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ⭐ UTF-8 디코딩
        final String responseBody = utf8.decode(response.bodyBytes);
        print('📝 응답 내용: $responseBody');

        final Map<String, dynamic> jsonData = json.decode(responseBody);
        print('✅ JSON 파싱 성공');

        final Product product = Product.fromJson(jsonData);
        print('🎉 상품 상세 정보 로딩 완료: ${product.Product_Name}');

        return product;
      } else {
        print('❌ 서버 오류: ${response.statusCode}');
        throw Exception('상품 상세 정보를 불러올 수 없습니다 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('💥 fetchProductDetail 예외: $e');
      rethrow;
    }
  }

  /// ⭐ 기존 getProductDetail 함수를 fetchProductDetail로 리다이렉트 (호환성)
  static Future<Product> getProductDetail(String productId) async {
    print('🔄 getProductDetail 호출 → fetchProductDetail로 리다이렉트');
    return await fetchProductDetail(productId);
  }

  /// 📤 새 상품을 서버에 등록하는 함수
  /// @param product 등록할 상품 정보
  /// @return Product 등록된 상품 정보 (서버에서 할당된 번호 포함)
  static Future<Product> createProduct(Product product) async {
    print('\n📤 [createProduct] 시작 - 새 상품 등록');
    print('🎯 등록할 상품: ${product.Product_Name}');
    print('📡 요청 URL: $baseUrl/products');

    try {
      // Product 객체를 JSON으로 변환
      final Map<String, dynamic> productData = product.toJson();

      // ⭐ 개발용 사용자 정보 자동 적용
      productData['User_Number'] = GlobalState.User_Number;      // 항상 1
      productData['User_Location'] = GlobalState.User_Location;  // 개발용 위치

      print('📤 전송할 데이터: $productData');

      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: json.encode(productData),
      ).timeout(Duration(seconds: 15));  // 업로드는 15초 타임아웃

      print('📨 응답 상태: ${response.statusCode}');

      if (response.statusCode == 201) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = json.decode(responseBody);
        print('✅ 상품 등록 성공!');
        print('🔍 등록된 상품 번호: ${jsonData['Product_Number']}');

        final Product createdProduct = Product.fromJson(jsonData);
        print('🎉 새 상품 등록 완료: ${createdProduct.toString()}');

        return createdProduct;
      } else {
        print('❌ 상품 등록 실패: ${response.statusCode}');
        print('🔍 오류 내용: ${response.body}');
        throw Exception('상품 등록에 실패했습니다 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('💥 createProduct 예외: $e');
      rethrow;
    }
  }

  /// ✏️ 상품 정보를 수정하는 함수
  /// @param product 수정할 상품 정보
  /// @return Product 수정된 상품 정보
  static Future<Product> updateProduct(Product product) async {
    print('\n✏️ [updateProduct] 시작 - 상품 수정');
    print('🎯 수정할 상품: ${product.Product_Number}');

    try {
      final Map<String, dynamic> productData = product.toJson();

      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.Product_Number}'),
        headers: headers,
        body: json.encode(productData),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = json.decode(responseBody);
        final Product updatedProduct = Product.fromJson(jsonData);
        print('✅ 상품 수정 성공!');
        return updatedProduct;
      } else {
        throw Exception('상품을 수정할 수 없습니다 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('💥 updateProduct 예외: $e');
      rethrow;
    }
  }

  /// 🗑️ 상품을 삭제하는 함수
  /// @param productId 삭제할 상품 번호
  static Future<void> deleteProduct(String productId) async {
    print('\n🗑️ [deleteProduct] 시작 - 상품 삭제');
    print('🎯 삭제할 상품: $productId');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 204) {
        print('✅ 상품 삭제 성공!');
      } else {
        throw Exception('상품을 삭제할 수 없습니다 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('💥 deleteProduct 예외: $e');
      rethrow;
    }
  }

  // ========================================
  // 📋 채팅방 관련 API 함수들
  // ========================================

  /// 📋 특정 사용자의 채팅방 목록을 가져오는 함수
  /// @param userId 사용자 ID
  /// @return List<ChatRoom> 채팅방 목록
  static Future<List<ChatRoom>> fetchChatRooms(String userId) async {
    print('\n💬 [fetchChatRooms] 시작 - 채팅방 목록 요청');
    print('🎯 사용자 ID: $userId');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats?userId=$userId'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);
        print('✅ 채팅방 목록 로딩 완료: ${jsonData.length}개');

        final List<ChatRoom> chatRooms = jsonData
            .map((json) {
          try {
            return ChatRoom.fromJson(json);
          } catch (e) {
            print('❌ 채팅방 데이터 파싱 오류: $e');
            return null;
          }
        })
            .where((chatRoom) => chatRoom != null)
            .cast<ChatRoom>()
            .toList();

        return chatRooms;
      } else {
        throw Exception('채팅방 목록을 가져올 수 없습니다 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('💥 fetchChatRooms 예외: $e');
      rethrow;
    }
  }

  /// 💌 새로운 채팅방을 생성하는 함수
  static Future<ChatRoom> createChatRoom({
    required String productId,
    required String buyerId,
    required String sellerId,
    required String firstMessage,
  }) async {
    print('\n💌 [createChatRoom] 시작 - 새 채팅방 생성');

    try {
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
      ).timeout(timeoutDuration);

      if (response.statusCode == 201) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = json.
        decode(responseBody);
        final ChatRoom chatRoom = ChatRoom.fromJson(jsonData);
        print('✅ 채팅방 생성 성공! ID: ${chatRoom.Chat_Number}');
        return chatRoom;
      } else {
        throw Exception('채팅방을 생성할 수 없습니다 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('💥 createChatRoom 예외: $e');
      rethrow;
    }
  }

  // ========================================
  // 📍 위치 관련 API 함수들
  // ========================================

  /// 🗺️ 위치 기반으로 근처 상품들을 가져오는 함수
  /// @param latitude 위도
  /// @param longitude 경도
  /// @param radiusKm 검색 반경 (기본 5km)
  /// @return List<Product> 근처 상품 목록
  static Future<List<Product>> fetchProductsByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    print('\n📍 [fetchProductsByLocation] 시작 - 근처 상품 검색');
    print('🎯 위치: ($latitude, $longitude), 반경: ${radiusKm}km');

    try {
      final String url =
          '$baseUrl/products/nearby?lat=$latitude&lng=$longitude&radius=$radiusKm';
      print('📡 요청 URL: $url');

      final response =
      await http.get(Uri.parse(url), headers: headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);
        print('✅ 근처 상품 ${jsonData.length}개 발견');

        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        print('❌ 근처 상품 검색 실패: ${response.statusCode}');
        return [];  // 실패해도 빈 리스트 반환
      }
    } catch (e) {
      print('💥 fetchProductsByLocation 예외: $e');
      return [];  // 오류 시에도 빈 리스트 반환
    }
  }

  // ========================================
  // 🔍 검색 관련 API 함수들
  // ========================================

  /// 🔍 키워드로 상품을 검색하는 함수
  /// @param keyword 검색 키워드
  /// @return List<Product> 검색 결과 상품 목록
  static Future<List<Product>> searchProducts(String keyword) async {
    print('\n🔍 [searchProducts] 시작 - "$keyword" 검색');

    try {
      final response = await http
          .get(Uri.parse(
          '$baseUrl/products/search?q=${Uri.encodeComponent(keyword)}'
      ), headers: headers).timeout(timeoutDuration);

      if (
      response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);
        print('✅ 검색 결과 ${jsonData.length}개 발견');

        return jsonData.map(
                (json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('검색 중 오류가 발생했습니다 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('💥 searchProducts 예외: $e');
      rethrow;
    }
  }

  // ========================================
  // ⚡ 유틸리티 함수들
  // ========================================

  /// 🔄 서버 연결 상태를 확인하는 함수
  /// @return bool 서버가 살아있으면 true
  static Future<bool> checkServerConnection() async {
    try {
      print('🔄 서버 연결 상태 확인 중...');

      final response = await http
          .get(Uri.parse('$baseUrl/health'),
          headers:
          headers).timeout(Duration(seconds: 3));

      bool isAlive =
      (response.statusCode == 200);
      print(isAlive
          ? '✅ 서버 연결 정상'
          : '❌ 서버 연결 실패');
      return isAlive;
    } catch (e) {
      print('💥 서버 연결 확인 실패: $e');
      return false;
    }
  }

  /// 📊 개발용 사용자 정보 출력
  static void printDevelopmentInfo() {
    print('\n📊 개발용 API 서비스 정보');
    print('서버 주소: $baseUrl');
    print('고정 사용자 번호: ${GlobalState.User_Number}');
    print('고정 사용자 이름: ${GlobalState.User_Name}');
    print('고정 사용자 위치: ${GlobalState.User_Location}');
    print('=' * 50);
  }

  /// 🧹 정리
  static void dispose() {
    print('🧹 ApiService 정리 중...');
  }
}
