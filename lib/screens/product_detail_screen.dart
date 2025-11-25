// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../main.dart'; // DapaGreen 상수를 사용하기 위해 import

/// 상품 상세 화면을 나타내는 StatefulWidget
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _productDetail;
  Map<String, dynamic>? _ownerProfile; // ✅ 판매자 정보를 저장할 변수
  bool _isLoading = true;
  String? _error;

  // ✅ AppBar 높이 정의 (Status Bar 높이 포함)
  double get _kToolbarHeight => MediaQuery.of(context).padding.top + kToolbarHeight;

  @override
  void initState() {
    super.initState();
    _fetchProductAndOwnerDetail();
  }

  // ✅ 상품 상세 정보와 판매자 정보를 함께 불러오는 함수
  Future<void> _fetchProductAndOwnerDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await ApiService.getProductDetail(widget.product.Product_Number);

      // ✅ 판매자 ID로 판매자 정보 불러오기
      final ownerId = detail.Product_Owner;
      final ownerData = await ApiService.fetchUserProfile(ownerId);

      setState(() {
        _productDetail = detail;
        _ownerProfile = ownerData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // [User Lookup Failed] 오류가 났다면 ownerProfile은 null
        _error = '상세 정보를 불러올 수 없거나 판매자 정보를 가져올 수 없습니다: $e';
        _isLoading = false;
      });
      print("Error in _fetchProductAndOwnerDetail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('상품 상세'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(child: Text(_error!)),
      );
    }

    final p = _productDetail!;
    final owner = _ownerProfile;
    final sellerNickname = owner?['User_ID'] ?? '알 수 없는 판매자';
    final sellerLocation = owner?['User_Location'] ?? '위치 정보 없음';
    final sellerPoint = (owner?['User_point'] as num? ?? 0.0).toStringAsFixed(1);
    final sellerImageUrl = owner?['imageUrl'] ?? 'https://via.placeholder.com/150';


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 상품 이미지 (짤림 해결)
                  Image.network(
                    p.Product_Picture,
                    width: double.infinity,
                    height: 320, // 높이 조정
                    fit: BoxFit.cover, // 공간을 채우면서 짤림 방지
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 320,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                      ),
                    ),
                  ),

                  // ✅ 컨텐츠 시작 Padding (AppBar 뒤로 숨겨진 컨텐츠가 없도록)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 판매자 정보 섹션
                        if (owner != null) ...[
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(sellerImageUrl),
                                backgroundColor: Colors.grey[200],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sellerNickname, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(sellerLocation, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              // 매너 온도
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$sellerPoint°C',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: dapaGreen[700]),
                                  ),
                                  Text('매너온도', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                          Divider(height: 30, thickness: 1, color: Colors.grey[200]),
                        ],

                        // 2. 상품명 및 가격
                        Text(p.Product_Name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          '${p.Product_Price}원',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: dapaGreen[700]),
                        ),
                        const SizedBox(height: 12),

                        // 3. 상품 설명 및 기타 정보
                        Text(p.Product_Info, style: const TextStyle(fontSize: 16, height: 1.5)),
                        const SizedBox(height: 16),

                        Text('판매 상태: ${p.Product_State ? '판매중' : '판매완료'}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        const SizedBox(height: 4),
                        Text('위치: ${p.User_location}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        const SizedBox(height: 4),
                        Text('거리: ${p.Product_Location.isNotEmpty ? p.Product_Location : '정보 없음'}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // 찜하기 버튼 (아이콘만)
              IconButton(
                icon: const Icon(Icons.favorite_border),
                color: Colors.grey[600],
                onPressed: () {
                  // To Do: 찜하기 기능
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // To Do: 채팅 시작 기능
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dapaGreen[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('채팅하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}