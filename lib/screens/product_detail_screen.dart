// 상품 상세 화면을 위한 Flutter 위젯 파일
import 'package:flutter/material.dart'; // Flutter UI 라이브러리
import '../models/product.dart';         // 상품 데이터 모델
import '../services/api_service.dart';   // 상품 정보를 받아오는 서비스

/// 상품 상세 화면을 나타내는 StatefulWidget
class ProductDetailScreen extends StatefulWidget {
  final Product product; // 상품 목록에서 전달받은 상품 객체

  // 생성자: product를 반드시 받아야 함
  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

// 실제 화면의 상태를 관리하는 클래스
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _productDetail;   // 서버에서 받아온 상품 상세 정보 저장 변수
  bool _isLoading = true;    // 데이터 로딩 중인지 표시하는 변수
  String? _error;            // 에러 메시지 저장 변수

  // 위젯이 처음 생성될 때 실행되는 함수
  @override
  void initState() {
    super.initState();
    _fetchProductDetail(); // 상품 상세 정보 받아오기 시작
  }

  /// 상품 상세 정보를 서버(또는 Mock)에서 받아오는 비동기 함수
  Future<void> _fetchProductDetail() async {
    // 로딩 시작: 로딩 표시를 위해 상태 변경
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 상품의 고유 번호를 이용해 상세 정보 요청
      final detail =
      await ApiService.getProductDetail(widget.product.Product_Number);
      // 받아온 정보를 화면에 표시하기 위해 상태 변경
      setState(() {
        _productDetail = detail; // 받아온 상품 정보 저장
        _isLoading = false;      // 로딩 끝
      });
    } catch (e) {
      // 에러 발생 시 에러 메시지 표시
      setState(() {
        _error = '상세 정보를 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  // 실제 화면을 그리는 함수
  @override
  Widget build(BuildContext context) {
    // 1. 데이터 로딩 중이면 로딩 스피너만 표시
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. 에러가 있으면 에러 메시지만 표시
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error!)),
      );
    }

    // 3. 정상적으로 상품 상세 정보를 받았으면 화면에 표시
    final p = _productDetail!; // null이 아니라고 확신하고 사용

    return Scaffold(
      appBar: AppBar(title: Text(p.Product_Name)), // 상단에 상품명 표시
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // 화면 여백
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 상품 이미지 표시
            Image.network(
              p.Product_Picture, // 이미지 URL
              width: double.infinity, // 화면 전체 너비
              height: 200,            // 높이 200
              fit: BoxFit.cover,      // 이미지를 꽉 채우기
            ),
            const SizedBox(height: 16), // 여백
            // 상품명 표시
            Text(
              p.Product_Name,
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 상품 가격 표시
            Text(
              '${p.Product_Price}원',
              style: const TextStyle(fontSize: 18, color: Colors.orange),
            ),
            const SizedBox(height: 8),
            // 상품 설명 표시
            Text(p.Product_Info),
            const SizedBox(height: 8),
            // 판매자 위치 표시
            Text('위치: ${p.User_location}'),
            const SizedBox(height: 8),
            // 판매 상태 표시 (판매중/판매완료)
            Text('판매 상태: ${p.Product_State ? '판매중' : '판매완료'}'),
            const SizedBox(height: 8),
            // ✨ [수정] 거리 정보: Product_Location 사용 (없으면 기본 메시지)
            Text('거리: ${p.Product_Location.isNotEmpty ? p.Product_Location : '정보 없음'}'),
          ],
        ),
      ),
      // 화면 오른쪽 아래에 채팅하기 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // To Do : 채팅 시작 기능 (아직 구현 안됨)
        },
        label: const Text('채팅하기'),
        icon: const Icon(Icons.chat),
      ),
    );
  }
}
