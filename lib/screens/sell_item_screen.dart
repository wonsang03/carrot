import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// 상품 등록 화면을 나타내는 위젯입니다.
class SellItemScreen extends StatefulWidget {
  const SellItemScreen({Key? key}) : super(key: key);

  @override
  State<SellItemScreen> createState() => _SellItemScreenState();
}

// 상품 등록 화면의 상태를 관리하는 클래스입니다.
class _SellItemScreenState extends State<SellItemScreen> {
  final _formKey = GlobalKey<FormState>(); // 폼의 상태를 관리하는 키
  final _nameCtrl = TextEditingController(); // 상품명 입력 컨트롤러
  final _priceCtrl = TextEditingController(); // 가격 입력 컨트롤러
  final _descCtrl = TextEditingController(); // 설명 입력 컨트롤러
  final _imageCtrl = TextEditingController(); // 이미지 URL 입력 컨트롤러
  bool _isSubmitting = false; // 등록 버튼을 눌렀을 때 처리 중인지 여부

  // 상품 등록 함수
  Future<void> _submit() async {
    // 폼의 입력값이 올바른지 검사
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSubmitting = true; }); // 등록 중임을 표시
    try {
      // 상품 객체 생성 (Product_Number는 0으로 넣지만 실제로는 서버에서 자동으로 번호를 할당함)
      // 서버에서 자동으로 번호를 할당한다면 0이나 null을 넣어도 괜찮아요.
      final newProduct = Product(
        Product_Number: 0, // 서버에서 실제 번호를 할당하므로 임시로 0을 넣음
        Product_Name: _nameCtrl.text, // 입력한 상품명
        Product_Price: int.tryParse(_priceCtrl.text) ?? 0, // 입력한 가격 (숫자로 변환)
        Product_Picture: _imageCtrl.text, // 입력한 이미지 URL
        Product_Info: _descCtrl.text, // 입력한 설명
        Product_State: true, // 판매 중 상태
        User_Number: 1, // 실제 로그인한 사용자 번호로 바꿔야 함
        User_location: '내 위치', // 실제 위치 정보로 바꿀 수 있음
      );
      // 서버에 상품 등록 요청
      await ApiService.createProduct(newProduct);
      // 등록 성공 시 이전 화면으로 돌아가서 상품 목록을 새로고침
      if (mounted) Navigator.pop(context, 'refresh');
    } catch (e) {
      // 등록 실패 시 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상품 등록 실패: $e')),
      );
    } finally {
      setState(() { _isSubmitting = false; }); // 등록 처리 끝
    }
  }

  @override
  void dispose() {
    // 입력 컨트롤러 정리 (메모리 누수 방지)
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 등록')), // 상단에 제목 표시
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 전체에 여백
        child: Form(
          key: _formKey, // 폼의 상태를 관리
          child: ListView(
            children: [
              // 상품명 입력
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '상품명'),
                validator: (v) => v == null || v.isEmpty ? '상품명을 입력하세요' : null,
              ),
              // 가격 입력
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number, // 숫자 키보드
                validator: (v) => v == null || v.isEmpty ? '가격을 입력하세요' : null,
              ),
              // 설명 입력
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: '설명'),
                maxLines: 3, // 여러 줄 입력 가능
                validator: (v) => v == null || v.isEmpty ? '설명을 입력하세요' : null,
              ),
              // 이미지 URL 입력
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(labelText: '이미지 URL'),
                validator: (v) => v == null || v.isEmpty ? '이미지 URL을 입력하세요' : null,
              ),
              const SizedBox(height: 24), // 버튼과 입력창 사이 간격
              // 등록 버튼
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit, // 처리 중엔 버튼 비활성화
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white) // 처리 중엔 로딩 표시
                    : const Text('등록하기'), // 평소엔 '등록하기' 글자 표시
              ),
            ],
          ),
        ),
      ),
    );
  }
}
