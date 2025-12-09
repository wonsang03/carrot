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
                  // ✅ 상품 이미지 - 16:9 비율로 고정
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: p.Product_Picture.isNotEmpty
                          ? Image.network(
                              p.Product_Picture,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(dapaGreen[500]!),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                                      const SizedBox(height: 8),
                                      Text(
                                        '이미지를 불러올 수 없습니다',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[600]),
                              ),
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: sellerImageUrl.isNotEmpty && sellerImageUrl != 'https://via.placeholder.com/150'
                                      ? NetworkImage(sellerImageUrl)
                                      : null,
                                  child: sellerImageUrl.isEmpty || sellerImageUrl == 'https://via.placeholder.com/150'
                                      ? Icon(Icons.person, size: 24, color: Colors.grey[600])
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sellerNickname,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              sellerLocation,
                                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // 매너 온도
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: dapaGreen[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: dapaGreen[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$sellerPoint°C',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: dapaGreen[700],
                                        ),
                                      ),
                                      Text(
                                        '매너온도',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // 2. 상품명 및 가격
                        Text(
                          p.Product_Name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${p.Product_Price.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          )}원',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: dapaGreen[700],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 3. 상품 설명
                        if (p.Product_Info.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              p.Product_Info,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // 4. 상품 정보
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                Icons.sell_outlined,
                                '판매 상태',
                                p.Product_State ? '판매중' : '판매완료',
                                p.Product_State ? dapaGreen[700]! : Colors.grey[600]!,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.location_on_outlined,
                                '위치',
                                p.User_location.isNotEmpty ? p.User_location : '위치 정보 없음',
                                Colors.grey[700]!,
                              ),
                              if (p.Product_Location.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.straighten_outlined,
                                  '거리',
                                  p.Product_Location,
                                  Colors.grey[700]!,
                                ),
                              ],
                            ],
                          ),
                        ),
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

  // 정보 행을 만드는 헬퍼 위젯
  Widget _buildInfoRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}