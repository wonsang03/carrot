import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SellItemScreen extends StatefulWidget {
  const SellItemScreen({Key? key}) : super(key: key);

  @override
  State<SellItemScreen> createState() => _SellItemScreenState();
}

class _SellItemScreenState extends State<SellItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSubmitting = true; });

    try {
      // 이 값은 실제 로그인된 사용자의 UUID로 교체되어야 합니다.
      const String currentUserId = '8ac96703-506e-40fe-9ad2-5ba09d9896d5';

      // ✨ [수정] 요청하신 대로 Product_Info (상품 설명) 필드를 다시 추가했습니다.
      await ApiService.createProduct({
        'Product_Name': _nameCtrl.text,
        'Product_Price': int.tryParse(_priceCtrl.text) ?? 0,
        'Product_Picture': _imageCtrl.text,
        'Product_Info': _descCtrl.text, // 사용자가 입력한 설명을 포함
        'Product_Owner': currentUserId,
      });

      if (mounted) Navigator.pop(context, 'refresh');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상품 등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 등록')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '상품명'),
                validator: (v) => v == null || v.isEmpty ? '상품명을 입력하세요' : null,
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? '가격을 입력하세요' : null,
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: '설명'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? '설명을 입력하세요' : null,
              ),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(labelText: '이미지 URL'),
                validator: (v) => v == null || v.isEmpty ? '이미지 URL을 입력하세요' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('등록하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

