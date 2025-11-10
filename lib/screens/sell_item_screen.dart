import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  // 이미지 URL 컨트롤러는 더 이상 필요 없으므로 삭제합니다.
  // final _imageCtrl = TextEditingController();

  // 사용자가 선택한 이미지 파일을 저장할 상태 변수입니다.
  File? _pickedImageFile;
  bool _isSubmitting = false;

  // 갤러리/카메라에서 이미지를 선택하는 로직을 처리하는 함수입니다.
  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source, imageQuality: 80, maxWidth: 800);

    if (pickedImage == null) return;

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
  }

  // 이미지 소스(갤러리/카메라) 선택 다이얼로그를 보여주는 함수입니다.
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('갤러리에서 선택'),
            onTap: () {
              Navigator.of(ctx).pop();
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('카메라로 촬영'),
            onTap: () {
              Navigator.of(ctx).pop();
              _pickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    // Form 유효성 검사 외에, 이미지 파일이 선택되었는지도 확인합니다.
    if (!_formKey.currentState!.validate() || _pickedImageFile == null) {
      if (_pickedImageFile == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상품 이미지를 등록해주세요.')),
        );
      }
      return;
    }
    setState(() { _isSubmitting = true; });

    try {
      // 이 값은 실제 로그인된 사용자의 UUID로 교체되어야 합니다.
      const String currentUserId = '8ac96703-506e-40fe-9ad2-5ba09d9896d5';

      // TODO: 백엔드에 이미지 '파일' 업로드 기능 구현 후, 이 부분을 수정해야 합니다.
      // 1. _pickedImageFile을 서버(예: Supabase Storage)에 업로드합니다.
      // 2. 업로드 후 반환받은 이미지의 public URL을 'Product_Picture' 값으로 사용합니다.
      // 현재는 백엔드가 URL만 받으므로, 임시 URL을 사용합니다.
      final imageUrl = 'https://placehold.co/600x400.png?text=업로드+예정';

      await ApiService.createProduct({
        'Product_Name': _nameCtrl.text,
        'Product_Price': int.tryParse(_priceCtrl.text) ?? 0,
        'Product_Picture': imageUrl, // 선택된 이미지 파일의 URL을 전달 (현재는 임시값)
        'Product_Info': _descCtrl.text,
        'Product_Owner': currentUserId,
      });

      if (mounted) Navigator.pop(context, 'refresh');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상품 등록 실패: $e')),);
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
    // _imageCtrl은 삭제되었으므로 dispose 호출도 제거합니다.
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
              // 이미지 선택 UI 입니다.
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pickedImageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_pickedImageFile!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('이미지 추가하기', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
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
              // 이미지 URL 입력란은 제거되었습니다.
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
