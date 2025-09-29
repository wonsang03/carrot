// lib/models/product.dart
// 🥕 상품 정보를 담는 클래스 - Supabase DB와 완전히 통일된 구조

class Product {
  // ===== 🔑 기본 상품 정보 (Supabase Product 테이블과 동일) =====
  final String Product_Number;       // 상품 고유 번호 (Primary Key) ⭐ String으로 수정
  final String Product_Name;         // 상품명
  final int Product_Price;           // 가격 (원 단위)
  final String Product_Picture;      // 상품 이미지 URL
  final String Product_Info;         // 상품 설명
  final bool Product_State;          // 판매 상태 (true: 판매중, false: 판매완료)
  final int User_Number;             // 판매자 사용자 번호 (Foreign Key) ⭐ 개발용으로 1 고정
  final String User_Location;        // 판매자 위치 ⭐ User_location → User_Location 수정

  // ===== 📍 추가 정보 =====
  final double distance;             // 현재 위치에서의 거리 (km)

  // ===== 🏗️ 생성자 =====
  Product({
    required this.Product_Number,    // 상품 번호 (필수)
    required this.Product_Name,      // 상품명 (필수)
    required this.Product_Price,     // 가격 (필수)
    required this.Product_Picture,   // 이미지 URL (필수)
    required this.Product_Info,      // 상품 설명 (필수)
    required this.Product_State,     // 판매 상태 (필수)
    required this.User_Number,       // 판매자 번호 (필수) ⭐ 개발용으로 1 사용
    required this.User_Location,     // 판매자 위치 (필수) ⭐ 대문자 L
    this.distance = 0.0,             // 기본값: 거리 0km
  });

  /// ===== 📥 JSON을 Product 객체로 변환 =====
  /// 서버에서 받은 JSON 데이터를 Dart 객체로 변환할 때 사용
  factory Product.fromJson(Map<String, dynamic> json) {
    print('🔄 Product.fromJson 호출됨');
    print('📦 받은 JSON: $json');

    try {
      return Product(
        // ⭐ 중요: DB 테이블의 컬럼명과 정확히 일치해야 함
        Product_Number: json['Product_Number']?.toString() ?? '0',  // String으로 변환
        Product_Name: json['Product_Name']?.toString() ?? '상품명 없음',
        Product_Price: json['Product_Price'] ?? 0,
        Product_Picture: json['Product_Picture']?.toString() ?? '',
        Product_Info: json['Product_Info']?.toString() ?? '설명 없음',
        Product_State: json['Product_State'] ?? true,
        User_Number: json['User_Number'] ?? 1,        // ⭐ 개발용 기본값 1
        User_Location: json['User_Location']?.toString() ?? '위치 정보 없음',  // ⭐ 대문자 L
        distance: (json['distance'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      print('❌ Product.fromJson 오류: $e');
      print('🔍 문제 JSON: $json');
      rethrow;
    }
  }

  /// ===== 📤 Product 객체를 JSON으로 변환 =====
  /// 서버로 데이터를 보낼 때 사용 (상품 등록, 수정 시)
  Map<String, dynamic> toJson() {
    print('🔄 Product.toJson 호출됨');

    final Map<String, dynamic> data = {
      'Product_Number': Product_Number,
      'Product_Name': Product_Name,
      'Product_Price': Product_Price,
      'Product_Picture': Product_Picture,
      'Product_Info': Product_Info,
      'Product_State': Product_State,
      'User_Number': User_Number,          // ⭐ 개발용으로 항상 1
      'User_Location': User_Location,      // ⭐ 대문자 L
    };

    print('📤 생성된 JSON: $data');
    return data;
  }

  /// ===== 💰 가격을 예쁘게 포맷팅 =====
  /// 예: 1000000 → "1,000,000원"
  String getFormattedPrice() {
    // 천 단위마다 콤마 추가
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedPrice = Product_Price.toString().replaceAllMapped(
        formatter,
            (Match m) => '${m[1]},'
    );
    return '${formattedPrice}원';
  }

  /// ===== 📏 거리를 예쁘게 포맷팅 =====
  String getFormattedDistance() {
    if (distance == 0.0) return '거리 정보 없음';
    if (distance < 1.0) {
      return '${(distance * 1000).round()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }

  /// ===== 🖨️ 디버깅용 문자열 출력 =====
  @override
  String toString() {
    return 'Product{'
        'Product_Number: $Product_Number, '
        'Product_Name: $Product_Name, '
        'Product_Price: ${Product_Price}원, '
        'User_Number: $User_Number, '
        'User_Location: $User_Location, '  // ⭐ 대문자 L
        'Product_State: ${Product_State ? "판매중" : "판매완료"}'
        '}';
  }

  /// ===== ✅ 데이터 유효성 검사 =====
  bool isValid() {
    return Product_Name.isNotEmpty &&
        Product_Price > 0 &&
        User_Number > 0 &&
        Product_Picture.isNotEmpty;
  }

  /// ===== 📋 상품 복사본 만들기 =====
  Product copyWith({
    String? Product_Number,
    String? Product_Name,
    int? Product_Price,
    String? Product_Picture,
    String? Product_Info,
    bool? Product_State,
    int? User_Number,
    String? User_Location,           // ⭐ 대문자 L
    double? distance,
  }) {
    return Product(
      Product_Number: Product_Number ?? this.Product_Number,
      Product_Name: Product_Name ?? this.Product_Name,
      Product_Price: Product_Price ?? this.Product_Price,
      Product_Picture: Product_Picture ?? this.Product_Picture,
      Product_Info: Product_Info ?? this.Product_Info,
      Product_State: Product_State ?? this.Product_State,
      User_Number: User_Number ?? this.User_Number,
      User_Location: User_Location ?? this.User_Location,    // ⭐ 대문자 L
      distance: distance ?? this.distance,
    );
  }
}