// lib/screens/product_detail_screen.dart
// 📱 상품 상세 화면 - 상수 생성자 오류 및 아이콘 오류 수정 버전

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// 상품 상세 화면을 나타내는 StatefulWidget
/// ⭐ fetchProductDetail 함수 사용으로 통일
class ProductDetailScreen extends StatefulWidget {
  final Product product;  // 상품 목록에서 전달받은 기본 상품 정보

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

/// 실제 화면의 상태를 관리하는 클래스
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _productDetail;     // 서버에서 받아온 상품 상세 정보
  bool _isLoading = true;      // 데이터 로딩 중인지 표시
  String? _error;              // 에러 메시지 저장

  /// 위젯이 처음 생성될 때 실행
  @override
  void initState() {
    super.initState();
    print('🔄 ProductDetailScreen 초기화 - 상품번호: ${widget.product.Product_Number}');
    _fetchProductDetail();
  }

  /// ⭐ 상품 상세 정보를 서버에서 받아오는 함수 (수정됨)
  Future<void> _fetchProductDetail() async {
    print('\n🔍 [_fetchProductDetail] 시작');
    print('🎯 요청할 상품 번호: ${widget.product.Product_Number}');

    // 로딩 상태로 설정
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ⭐ ApiService의 fetchProductDetail 함수 사용 (함수명 통일)
      final Product detail = await ApiService.fetchProductDetail(
          widget.product.Product_Number  // String 타입으로 전달
      );

      // 성공: 받아온 상세 정보로 UI 업데이트
      print('✅ 상품 상세 정보 로딩 성공: ${detail.Product_Name}');
      setState(() {
        _productDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      // 에러 발생 시 에러 메시지 표시
      print('💥 상품 상세 정보 로딩 실패: $e');
      setState(() {
        _error = '상품 정보를 불러오는데 실패했습니다.\n오류: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// 🔄 재시도 함수
  void _retryLoading() {
    print('🔄 사용자가 재시도 요청');
    _fetchProductDetail();
  }

  /// 💬 채팅하기 버튼 클릭 시
  void _startChat() {
    print('💬 채팅하기 버튼 클릭 - 상품: ${_productDetail?.Product_Name}');

    if (_productDetail != null) {
      // TODO: 실제 채팅 화면으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('채팅 기능은 준비 중입니다.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 🎨 메인 UI를 구성하는 build 함수
  @override
  Widget build(BuildContext context) {
    print('🎨 ProductDetailScreen build - 로딩상태: $_isLoading');

    return Scaffold(
      // ===== 📱 상단 앱바 =====
      appBar: AppBar(
        title: Text(
          _productDetail?.Product_Name ?? widget.product.Product_Name,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            print('⬅️ 뒤로가기 버튼 클릭');
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // 좋아요 버튼
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              print('❤️ 좋아요 버튼 클릭');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('좋아요 기능은 준비 중입니다.')),
              );
            },
          ),
          // 공유 버튼
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              print('📤 공유 버튼 클릭');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('공유 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
      ),

      // ===== 📄 메인 콘텐츠 =====
      body: _buildBody(),

      // ===== 💬 하단 채팅 버튼 =====
      floatingActionButton: _isLoading || _error != null
          ? null  // 로딩 중이거나 에러 시에는 버튼 숨김
          : FloatingActionButton.extended(
        onPressed: _startChat,
        backgroundColor: Colors.orange,
        icon: Icon(Icons.chat, color: Colors.white),
        label: Text('채팅하기', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 🏗️ 메인 콘텐츠 영역 구성
  Widget _buildBody() {
    // 1. 로딩 중
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange), // remove const
            ),
            SizedBox(height: 16),
            Text(
              '상품 정보를 불러오는 중...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 2. 에러 발생
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red), // remove const
              SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retryLoading,
                icon: Icon(Icons.refresh),
                label: Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '목록으로 돌아가기',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. 정상 상태: 상품 상세 정보 표시
    return _buildProductDetailUI();
  }

  /// 📋 상품 상세 정보 UI
  Widget _buildProductDetailUI() {
    final p = _productDetail!;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 80), // 하단 버튼 공간 확보
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== 📸 상품 이미지 =====
          _buildProductImage(p),

          // ===== 📝 상품 기본 정보 =====
          _buildProductInfo(p),

          // ===== 👤 판매자 정보 =====
          _buildSellerInfo(p),

          // ===== 📄 상품 설명 =====
          _buildProductDescription(p),

          // ===== 📊 추가 정보 =====
          _buildAdditionalInfo(p),
        ],
      ),
    );
  }

  /// 📸 상품 이미지 섹션
  Widget _buildProductImage(Product product) {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey[200],
      child: product.Product_Picture.isNotEmpty
          ? Image.network(
        product.Product_Picture,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ 이미지 로딩 실패: $error');
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 64, color: Colors.grey),
              SizedBox(height: 8),
              Text('이미지를 불러올 수 없습니다', style: TextStyle(color: Colors.grey)),
            ],
          );
        },
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text('이미지 없음', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 📝 상품 기본 정보 섹션
  Widget _buildProductInfo(Product product) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품명
          Text(
            product.Product_Name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),

          // 가격
          Text(
            product.getFormattedPrice(), // ⭐ 포맷팅된 가격
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 8),

          // 판매 상태
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: product.Product_State ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              product.Product_State ? '판매중' : '판매완료',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 👤 판매자 정보 섹션
  Widget _buildSellerInfo(Product product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 판매자 프로필 아이콘
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange.withOpacity(0.2),
            child: Text(
              '개', // ⭐ 개발자 표시
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          SizedBox(width: 12),

          // 판매자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '개발자 (고정)', // ⭐ 개발용 표시
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product.User_Location, // ⭐ 대문자 L
                        style: TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.thermostat, size: 16, color: Colors.orange), // 아이콘 수정
                    SizedBox(width: 4),
                    Text(
                      '매너온도 42°C', // ⭐ 개발용 고정 온도
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📄 상품 설명 섹션
  Widget _buildProductDescription(Product product) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상품 설명',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            product.Product_Info.isNotEmpty
                ? product.Product_Info
                : '상품 설명이 없습니다.',
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  /// 📊 추가 정보 섹션
  Widget _buildAdditionalInfo(Product product) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('상품 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildInfoRow('상품 번호', product.Product_Number),
          _buildInfoRow('판매자 번호', product.User_Number.toString()),
          if (product.distance > 0) _buildInfoRow('거리', product.getFormattedDistance()),
        ],
      ),
    );
  }

  /// 정보 행을 만드는 헬퍼 함수
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.black87, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  /// 🧹 메모리 정리
  @override
  void dispose() {
    print('🧹 ProductDetailScreen 정리');
    super.dispose();
  }
}
