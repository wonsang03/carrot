// lib/models/product.dart

/// 🥕 서버에서 받아오는 상품 정보를 담는 클래스입니다.
/// 서버에서 받은 JSON 데이터를 Product 객체로 변환하거나,
/// Product 객체를 JSON으로 바꿔서 서버에 보낼 때 사용합니다.
class Product {
  final String Product_Number;      // 상품 고유 번호 (서버에서 부여)
  final String Product_Name;     // 상품명
  final int Product_Price;       // 가격
  final String Product_Picture;  // 이미지 URL
  final String Product_Info;     // 상품 설명
  final bool Product_State;      // 판매 상태 (true: 판매중, false: 완료)
  final int User_Number;         // 판매자 고유 번호
  final String User_location;    // 판매자 위치
  final double distance;        // 거리 (옵션)
  final double latitude;        // 위도 (옵션)
  final double longitude;       // 경도 (옵션)

  // 생성자: 서버에서 받은 값으로 객체를 만듭니다.
  Product({
    required this.Product_Number,
    required this.Product_Name,
    required this.Product_Price,
    required this.Product_Picture,
    required this.Product_Info,
    required this.Product_State,
    required this.User_Number,
    required this.User_location,
    this.distance = 0.0,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  /// 서버에서 받은 JSON 데이터를 Product 객체로 변환하는 함수
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      Product_Number: json['Product_Number'] ?? 0,
      Product_Name: json['Product_Name'] ?? '',
      Product_Price: json['Product_Price'] ?? 0,
      Product_Picture: json['Product_Picture'] ?? '',
      Product_Info: json['Product_Info'] ?? '',
      Product_State: json['Product_State'] ?? false,
      User_Number: json['User_Number'] ?? 0,
      User_location: json['User_location'] ?? '',
      distance: (json['distance'] ?? 0.0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  /// Product 객체를 JSON으로 변환해서 서버에 보낼 때 사용
  Map<String, dynamic> toJson() {
    return {
      'Product_Number': Product_Number,
      'Product_Name': Product_Name,
      'Product_Price': Product_Price,
      'Product_Picture': Product_Picture,
      'Product_Info': Product_Info,
      'Product_State': Product_State,
      'User_Number': User_Number,
      'User_location': User_location,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
