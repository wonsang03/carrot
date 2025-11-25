// lib/models/product.dart

/// 🥕 서버에서 받아오는 상품 정보를 담는 클래스입니다.
class Product {
  final String Product_Number;      // 상품 고유 번호 (String으로 통일)
  final String Product_Name;
  final int Product_Price;
  final String Product_Picture;
  final String Product_Info;
  final bool Product_State;

  final String User_Number;         // 판매자 고유 번호 (String으로 통일)
  final String Product_Owner;       // 제품 주인 (String으로 통일)
  final String User_location;

  final String Product_Location;
  final double distance;
  final double latitude;
  final double longitude;

  // 생성자: 서버에서 받은 값으로 객체를 만듭니다.
  Product({
    required this.Product_Number,
    required this.Product_Name,
    required this.Product_Price,
    required this.Product_Picture,
    required this.Product_Info,
    required this.Product_State,
    required this.User_Number,
    required this.Product_Owner,
    required this.User_location,
    this.Product_Location = '',
    this.distance = 0.0,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  /// 서버에서 받은 JSON 데이터를 Product 객체로 변환하는 함수
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // ✅ String 타입으로 변환
      Product_Number: json['Product_Number']?.toString() ?? '',
      Product_Name: json['Product_Name'] ?? '',
      Product_Price: json['Product_Price'] ?? 0,
      Product_Picture: json['Product_Picture'] ?? '',
      Product_Info: json['Product_Info'] ?? '',
      Product_State: json['Product_State'] ?? false,

      // ✅ String 타입으로 변환
      User_Number: json['User_Number']?.toString() ?? '',
      Product_Owner : json['Product_Owner']?.toString() ?? '',

      User_location: json['User_location'] ?? '',
      Product_Location: json['Product_Location'] ?? '',

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
      'Product_Owner': Product_Owner,
      'User_location': User_location,
      'Product_Location': Product_Location,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}