// lib/screens/sell_item_screen.dart
// 📤 상품 등록 화면 - 개발용 고정 사용자 적용 버전

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/global_state.dart';  // ⭐ 개발용 사용자 정보

/// 상품 등록 화면을 나타내는 위젯
/// 개발 단계에서는 사용자 1번으로 고정하여 모든 상품을 등록합니다.
class SellItemScreen extends StatefulWidget {
  const SellItemScreen({Key? key}) : super(key: key);

  @override
  State<SellItemScreen> createState() => _SellItemScreenState();
}

/// 상품 등록 화면의 상태를 관리하는 클래스
class _SellItemScreenState extends State<SellItemScreen> {
  // ===== 📝 폼 관련 컨트롤러들 =====
  final _formKey = GlobalKey<FormState>();      // 폼의 상태를 관리하는 키
  final _nameCtrl = TextEditingController();    // 상품명 입력 컨트롤러
  final _priceCtrl = TextEditingController();   // 가격 입력 컨트롤러
  final _descCtrl = TextEditingController();    // 설명 입력 컨트롤러
  final _imageCtrl = TextEditingController();   // 이미지 URL 입력 컨트롤러

  // ===== 🔄 상태 관리 변수들 =====
  bool _isSubmitting = false;                   // 등록 버튼을 눌렀을 때 처리 중인지 여부

  /// 위젯이 처음 생성될 때 실행
  @override
  void initState() {
    super.initState();
    print('📤 SellItemScreen 초기화');
    print('👤 현재 사용자: ${GlobalState.User_Name} (번호: ${GlobalState.User_Number})');
  }

  /// 📤 상품 등록 함수 (⭐ 개발용 사용자 정보 자동 적용)
  Future<void> _submit() async {
    print('\n📤 [_submit] 시작 - 새 상품 등록 시도');

    // 폼의 입력값이 올바른지 검사
    if (!_formKey.currentState!.validate()) {
      print('❌ 폼 검증 실패');
      return;
    }

    // 등록 중임을 표시
    setState(() {
      _isSubmitting = true;
    });

    try {
      // ⭐ 상품 객체 생성 (개발용 사용자 정보 자동 적용)
      final newProduct = Product(
        Product_Number: "0",                                    // 서버에서 자동으로 할당
        Product_Name: _nameCtrl.text.trim(),                    // 사용자 입력 상품명
        Product_Price: int.tryParse(_priceCtrl.text.trim()) ?? 0,  // 가격
        Product_Picture: _imageCtrl.text.trim(),                // 이미지 URL
        Product_Info: _descCtrl.text.trim(),                    // 상품 설명
        Product_State: true,                                    // 판매 중 상태
        User_Number: GlobalState.User_Number,                   // ⭐ 개발용 고정 사용자 번호 (1)
        User_Location: GlobalState.User_Location,               // ⭐ 개발용 고정 위치 (대문자 L)
      );

      print('📦 생성된 상품 정보: ${newProduct.toString()}');

      // ⭐ 서버에 상품 등록 요청
      final Product createdProduct = await ApiService.createProduct(newProduct);
      print('✅ 상품 등록 성공! 번호: ${createdProduct.Product_Number}');

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 상품 "${createdProduct.Product_Name}"이(가) 성공적으로 등록되었습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // 등록 성공 시 이전 화면으로 돌아가서 상품 목록을 새로고침
        Navigator.pop(context, 'refresh');
      }
    } catch (e) {
      print('💥 상품 등록 실패: $e');

      // 등록 실패 시 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 상품 등록 실패: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // 등록 처리 끝
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 🧹 메모리 정리 (컨트롤러들을 dispose하여 메모리 누수 방지)
  @override
  void dispose() {
    print('🧹 SellItemScreen 정리');
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  /// 🎨 UI를 그리는 build 함수
  @override
  Widget build(BuildContext context) {
    print('🎨 SellItemScreen build');

    return Scaffold(
      // ===== 📱 상단 앱바 =====
      appBar: AppBar(
        title: Text('상품 등록'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            print('⬅️ 뒤로가기 버튼 클릭');
            Navigator.of(context).pop();
          },
        ),
      ),

      // ===== 📄 메인 콘텐츠 =====
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ===== 👤 현재 사용자 정보 표시 (개발용) =====
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '개발 모드 정보',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('판매자: ${GlobalState.User_Name}'),
                    Text('사용자 번호: ${GlobalState.User_Number} (고정)'),  // ⭐ 항상 1
                    Text('위치: ${GlobalState.User_Location}'),            // ⭐ 대문자 L
                  ],
                ),
              ),
              SizedBox(height: 24),

              // ===== 📝 상품명 입력 =====
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: '상품명',
                  hintText: '판매할 상품의 이름을 입력하세요',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? '상품명을 입력하세요' : null,
                textInputAction: TextInputAction.next,  // 다음 입력창으로 이동
              ),
              SizedBox(height: 16),

              // ===== 💰 가격 입력 =====
              TextFormField(
                controller: _priceCtrl,
                decoration: InputDecoration(
                  labelText: '가격',
                  hintText: '판매 가격을 입력하세요 (원)',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,     // 숫자 키보드
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return '가격을 입력하세요';
                  }
                  final price = int.tryParse(v.trim());
                  if (price == null || price <= 0) {
                    return '올바른 가격을 입력하세요';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16),

              // ===== 📝 설명 입력 =====
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: '상품 설명',
                  hintText: '상품에 대한 자세한 설명을 입력하세요',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,                           // 여러 줄 입력 가능
                validator: (v) => v == null || v.trim().isEmpty ? '상품 설명을 입력하세요' : null,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16),

              // ===== 📸 이미지 URL 입력 =====
              TextFormField(
                controller: _imageCtrl,
                decoration: InputDecoration(
                  labelText: '이미지 URL',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return '이미지 URL을 입력하세요';
                  }
                  if (!Uri.tryParse(v.trim())!.hasAbsolutePath) {
                    return '올바른 URL을 입력하세요';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 32),

              // ===== 🔘 등록 버튼 =====
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,  // 처리 중엔 버튼 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  '등록하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // ===== ℹ️ 도움말 텍스트 =====
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 등록 팁',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 상품명은 구체적이고 명확하게 작성해주세요\n'
                          '• 실제 판매 가격을 입력해주세요\n'
                          '• 상품의 상태, 사용 기간 등을 자세히 설명해주세요\n'
                          '• 고화질의 실제 상품 이미지 URL을 사용해주세요',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
