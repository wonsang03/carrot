import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/chat_room.dart';
import '../widget/bottom_nav_bar.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'chat_list_screen.dart';
import 'chat_detail_screen.dart';
import 'sell_item_screen.dart';
import 'product_detail_screen.dart';
import 'user_profile_screen.dart'; // UserProfileScreen import 확인
import 'search_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  List<Product> allProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimation();
  }

  Future<void> _initializeData() async {
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      allProducts = await ApiService.fetchProducts();
    } catch (e) {
      setState(() {
        _errorMessage = '데이터를 불러오는 데 실패했습니다.\n서버가 켜져있는지 확인해주세요.';
      });
      allProducts = [];
    }
    setState(() {
      _isLoading = false;
    });
  }

  // 가상의 사용자 프로필 데이터를 준비하는 메서드
  // TODO: 실제 백엔드 API가 준비되면, 이 메서드 내부를 API 호출로 대체해야 합니다.
  Map<String, dynamic> _prepareUserProfileData() {
    // --- 프론트엔드 개발용 임시 사용자 데이터 (백엔드 API 응답 가정) ---
    final Map<String, dynamic> mockUserData = {
      'User_ID': 'devUser_01',                      // 사용자 아이디
      'User_Location': '대파시 개발1동 감자아파트',      // 사용자 위치
      'User_Number': 'RN-20240517-0001',           // 사용자 고유번호 (예시)
      'User_Password': 'securePassword123!',       // 사용자 비밀번호 (실제 표시는 마스킹 필요)
      'User_point': 36.5,                              // 사용자 매너온도 (숫자 타입)
      'imageUrl': 'https://placehold.co/200x200/3498DB/FFFFFF?text=DEV', // 프로필 이미지 URL (UI 표시용)
    };
    // --- 여기까지 임시 데이터 ---

    // (백엔드 연동 시 예시)
    // try {
    //   // final Map<String, dynamic> actualUserData = await ApiService.fetchUserProfile();
    //   // return actualUserData;
    // } catch (e) {
    //   // print('사용자 정보 로딩 실패: $e');
    //   // return {}; // 오류 발생 시 빈 맵 또는 기본값 반환
    // }
    return mockUserData; // 현재는 임시 데이터 반환
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          filteredProducts: allProducts, // SearchScreen에 전체 상품 목록 전달
          onProductTap: _onProductTap,
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('알림'),
        content: const Text('개발예정'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _animationController.forward().then((_) => _animationController.reverse());
  }

  void _onProductTap(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
    if (result == 'refresh') await _loadProducts();
  }

  void _onChatRoomTap(ChatRoom chatRoom, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          chatRoom: chatRoom,
          currentUserId: userId, // 이 userId도 실제 로그인 정보와 연동 필요
        ),
      ),
    );
  }

  Future<void> _onSellButtonPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SellItemScreen()),
    );
    if (result == true || result == 'refresh') await _loadProducts();
  }

  Widget _buildCurrentScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    
    List<Product> productsToShow = allProducts; // 홈 화면에는 전체 상품을 기본으로 표시

    switch (_currentIndex) {
      case 0:
        return HomeScreen(products: productsToShow, onProductTap: _onProductTap);
      case 1:
        return MapScreen(products: allProducts, onProductTap: _onProductTap);
      case 2:
      // ✨ [수정된 부분] -> 이 주석은 ChatListScreen과 UserProfileScreen의 관계에 대한 것이므로 유지
      // 더 이상 존재하지 않는 더미 데이터를 호출하는 대신, 임시 화면을 표시하여 오류를 해결했습니다.
      // TODO: 로그인 기능 구현 후, 실제 사용자 정보를 UserProfileScreen에 전달해야 합니다. -> 이 주석의 컨텍스트는 이제 case 3으로 이동
        return ChatListScreen(onRoomTap: _onChatRoomTap);
      case 3: // "나의 정보" 탭
        // TODO: 로그인 기능 구현 후, _prepareUserProfileData가 실제 사용자 정보를 반환하도록 수정해야 합니다.
        final Map<String, dynamic> userData = _prepareUserProfileData();
        return UserProfileScreen(user: userData);
      default:
        return HomeScreen(products: productsToShow, onProductTap: _onProductTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _currentIndex == 0
          ? AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text('대파마켓', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: _navigateToSearch),
          IconButton(icon: const Icon(Icons.notifications, color: Colors.black), onPressed: _showNotificationDialog),
        ],
      )
          : null,
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        animation: _scaleAnimation,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: _onSellButtonPressed,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}
