import 'dart:io'; // File 타입을 사용하기 위해 dart:io 라이브러리를 import 합니다.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // image_picker 패키지를 import 합니다.

// TODO: 나중에 실제 사용자 정보를 담을 User 모델을 import 해야 합니다.
// import '../models/user.dart';

// 1. StatefulWidget으로 변경합니다.
//    화면의 상태(사용자가 선택한 이미지)를 기억하고, 상태가 변경될 때 화면을 다시 그려야 하기 때문입니다.
class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // 2. 사용자가 선택한 이미지 파일을 저장할 상태 변수를 선언합니다.
  //    null일 수 있으므로 `File?` 타입으로 선언합니다.
  File? _pickedImageFile;

  // 3. 이미지 선택(갤러리/카메라) 로직을 처리하는 함수를 만듭니다.
  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    // imagePicker.pickImage를 호출하여 갤러리 또는 카메라를 엽니다.
    final pickedImage = await imagePicker.pickImage(
      source: source,      // source 매개변수로 갤러리(ImageSource.gallery) 또는 카메라(ImageSource.camera)를 지정합니다.
      imageQuality: 80,    // 이미지 품질을 80%로 설정합니다.
      maxWidth: 600,       // 이미지의 최대 너비를 600px로 제한하여 파일 크기를 줄입니다.
    );

    // 사용자가 이미지를 선택하지 않고 그냥 창을 닫은 경우, 아무 작업도 하지 않습니다.
    if (pickedImage == null) {
      return;
    }

    // `setState`를 호출하여 선택된 이미지 파일의 경로로 `File` 객체를 생성하고
    // `_pickedImageFile` 상태를 업데이트합니다. 이로 인해 화면이 다시 그려집니다.
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    // TODO: 여기에서 선택된 이미지 파일(_pickedImageFile)을 실제 서버에 업로드하는 로직을 추가해야 합니다.
    // 예: await ApiService.uploadProfileImage(_pickedImageFile);
  }

  // 4. "갤러리" 또는 "카메라" 선택 다이얼로그를 보여주는 함수를 만듭니다.
  void _showImageSourceDialog() {
    // showModalBottomSheet: 화면 하단에서 스르륵 올라오는 형태의 다이얼로그를 표시합니다.
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min, // 내용물의 크기만큼만 다이얼로그 높이를 차지하도록 설정합니다.
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('갤러리에서 선택'),
            onTap: () {
              Navigator.of(ctx).pop(); // 다이얼로그를 먼저 닫습니다.
              _pickImage(ImageSource.gallery); // 갤러리를 여는 함수를 호출합니다.
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('카메라로 촬영'),
            onTap: () {
              Navigator.of(ctx).pop(); // 다이얼로그를 먼저 닫습니다.
              _pickImage(ImageSource.camera); // 카메라를 여는 함수를 호출합니다.
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // StatefulWidget에서는 `widget.`을 통해 부모 위젯의 프로퍼티에 접근할 수 있습니다.
    // UserProfileScreen에서 사용할 데이터 추출 (null-safety 및 타입 캐스팅 고려)
    String userId = widget.user['User_ID']?.toString() ?? '사용자 ID 없음';
    String userLocation = widget.user['User_Location']?.toString() ?? '위치 정보 없음';
    // [수정] User_Number의 타입이 int 또는 String 어떤 것이 와도 안전하게 처리하도록 강제 형변환(as int?)을 제거합니다.
    String userNumber = widget.user['User_Number']?.toString() ?? '정보 없음';
    int userPoint = widget.user['User_point'] is int ? widget.user['User_point'] : (widget.user['User_point'] is String ? int.tryParse(widget.user['User_point'] ?? '0') ?? 0 : 0);
    String? networkImageUrl = widget.user['imageUrl']?.toString();
    // email 필드는 HomePage의 _prepareUserProfileData에서 현재 주석 처리되어 있으므로 여기서는 기본값을 사용하거나 표시하지 않음.
    // String userEmail = widget.user['email']?.toString() ?? '이메일 정보 없음';

    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 5. CircleAvatar를 GestureDetector로 감싸서 탭 이벤트를 감지할 수 있도록 합니다.
            GestureDetector(
              onTap: _showImageSourceDialog, // 탭하면 이미지 소스 선택 다이얼로그를 표시합니다.
              child: CircleAvatar(
                radius: 50,
                // 6. _pickedImageFile 상태에 따라 다른 이미지를 표시합니다.
                //    사용자가 새로 선택한 이미지가 있으면 FileImage로, 없으면 기존 networkImageUrl로 표시합니다.
                backgroundImage: _pickedImageFile != null
                    ? FileImage(_pickedImageFile!) // 사용자가 선택한 파일 이미지를 표시
                    : (networkImageUrl != null && networkImageUrl.isNotEmpty
                        ? NetworkImage(networkImageUrl) // 기존 네트워크 URL 이미지를 표시
                        : null), // 둘 다 없으면 배경색만 표시
                backgroundColor: Colors.grey[200], // 이미지 없을 때 배경색
                child: (_pickedImageFile == null && (networkImageUrl == null || networkImageUrl.isEmpty))
                    ? const Icon(Icons.person, size: 50, color: Colors.grey) // 기본 아이콘
                    : null,
              ),
            ),
            const SizedBox(height: 20), // 프로필 이미지와 사용자 ID 사이의 간격
            Text(userId, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center), // 사용자 ID 표시
            const SizedBox(height: 12), // 사용자 ID와 정보 목록 사이의 간격

            // 프로필 정보들을 헬퍼 위젯을 사용하여 표시
            _buildProfileInfoRow(Icons.person_pin_circle_outlined, '고유번호', userNumber),
            _buildProfileInfoRow(Icons.location_on_outlined, '위치', userLocation),
            _buildProfileInfoRow(Icons.thermostat_outlined, '매너온도', '$userPoint °C'),

            //일단 유지
            // email 필드가 필요하다면 아래 주석 해제 및 HomePage에서 데이터 제공 필요
            // _buildProfileInfoRow(Icons.email_outlined, '이메일', userEmail),

            const Spacer(), // 정보 목록과 하단 버튼 사이의 공간을 채움 (버튼을 하단으로 밀어냄)
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // 버튼 배경색
                foregroundColor: Colors.white, // 버튼 글자 및 아이콘 색상
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // 버튼 내부 여백
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold) // 버튼 글자 스타일
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃 기능은 준비 중입니다.')),
                );
              },
            ),
            const SizedBox(height: 20), // 화면 하단 여백
          ],
        ),
      ),
    );
  }

  // 프로필 정보 행(Row)을 만드는 헬퍼 위젯 함수
  // - icon: 정보 왼쪽에 표시될 아이콘 데이터 (예: Icons.location_on_outlined)
  // - label: 정보의 종류를 나타내는 문자열 (예: "위치")
  // - value: 실제 정보 값을 나타내는 문자열 (예: "서울시 강남구")
  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    // Padding 위젯: Row 주변에 상하로 8.0의 여백을 줍니다.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // Row 위젯: 자식 위젯들을 가로로 나란히 배치합니다.
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center; // 이전 중앙 정렬 주석 처리 (아래 Expanded로 인해 레이블과 값 정렬이 더 중요)
        crossAxisAlignment: CrossAxisAlignment.start, // 아이콘과 텍스트를 상단 기준으로 정렬
        children: [
          // Icon 위젯: 전달받은 icon 데이터를 화면에 아이콘으로 표시합니다.
          Icon(icon, color: Colors.grey[700], size: 20),
          // SizedBox 위젯: 아이콘과 레이블 텍스트 사이에 가로로 12.0의 고정된 간격을 만듭니다.
          const SizedBox(width: 12),
          // Text 위젯: 레이블 문자열(예: "위치:")을 표시합니다.
          Text(
            '$label:', // 전달받은 label 뒤에 콜론(:)을 붙입니다.
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          // SizedBox 위젯: 레이블 텍스트와 값 텍스트 사이에 가로로 8.0의 고정된 간격을 만듭니다.
          const SizedBox(width: 8),
          // Expanded 위젯: 남은 가로 공간을 모두 차지하도록 자식 위젯(Text)을 확장합니다.
          // 이렇게 하면 정보 값(value)이 길어져도 화면 밖으로 넘어가지 않고, 다음 줄로 자동 줄바꿈되거나 잘립니다 (ellipsis).
          Expanded(
            // Text 위젯: 실제 정보 값(value)을 표시합니다.
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.start, // 텍스트를 시작점(왼쪽) 기준으로 정렬합니다.
              overflow: TextOverflow.ellipsis, // 텍스트가 너무 길어서 한 줄에 다 안 보일 경우, 말줄임표(...)로 표시합니다.
            ),
          ),
        ],
      ),
    );
  }
}
