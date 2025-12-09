// lib/screens/user_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart'; // DapaGreen 상수를 사용하기 위해 import
import '../services/api_service.dart'; // ✨ API 서비스를 import

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _pickedImageFile;
  bool _isUploading = false; // ✨ 업로드 중인지 확인하는 상태 변수

  // ✨ [수정] ApiService의 함수를 호출하여 이미지 업로드 및 프로필 갱신
  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true; // 로딩 시작
    });

    // 업데이트할 대상 ID (UUID가 있으면 우선 사용, 없으면 User_ID 사용)
    final String userId = widget.user['User_Number']?.toString() ?? widget.user['User_ID'].toString();

    try {
      // ✨ ApiService의 updateUserProfileImage 함수 호출 (통신 로직 분리)
      await ApiService.updateUserProfileImage(userId, imageFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 사진이 성공적으로 변경되었습니다!')),
        );
      }
    } catch (e) {
      print('❌ 프로필 변경 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false; // 로딩 종료
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 600,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    
    // ✨ 이미지를 선택하자마자 서버로 업로드 시작
    _uploadImage(_pickedImageFile!);
  }

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

  @override
  Widget build(BuildContext context) {
    String userId = widget.user['User_ID']?.toString() ?? '사용자 ID 없음';
    String userLocation = widget.user['User_Location']?.toString() ?? '위치 정보 없음';

    double userPoint = 0.0;
    if (widget.user['User_point'] is num) {
      userPoint = (widget.user['User_point'] as num).toDouble();
    } else if (widget.user['User_point'] is String) {
      userPoint = double.tryParse(widget.user['User_point']) ?? 0.0;
    }

    String? networkImageUrl = widget.user['imageUrl']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // 프로필 이미지
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: _isUploading 
                            ? SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(dapaGreen[500]!),
                                ),
                              )
                            : _pickedImageFile != null
                                ? Image.file(
                                    _pickedImageFile!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : (networkImageUrl != null && networkImageUrl.isNotEmpty)
                                    ? Image.network(
                                        networkImageUrl,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.person, size: 60, color: Colors.grey[600]);
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(dapaGreen[500]!),
                                            ),
                                          );
                                        },
                                      )
                                    : Icon(Icons.person, size: 60, color: Colors.grey[600]),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: dapaGreen[500],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 사용자 이름
              Text(
                userId,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 정보 카드
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileInfoRow(Icons.location_on_outlined, '위치', userLocation),
                    const Divider(height: 32, thickness: 1, color: Colors.grey),
                    _buildProfileInfoRow(
                      Icons.thermostat_outlined,
                      '매너온도',
                      '${userPoint.toStringAsFixed(1)} °C',
                      color: dapaGreen[700],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              // 로그아웃 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('로그아웃'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그아웃 기능은 준비 중입니다.')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 헬퍼 위젯 함수에 color 매개변수 추가
  Widget _buildProfileInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? Colors.grey[700])!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color ?? Colors.grey[700],
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color ?? Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}