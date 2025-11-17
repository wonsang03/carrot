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

  // 서버에서 받아온 실제 사용자 정보를 저장할 상태 변수
  Map<String, dynamic> _userProfileData = {};

  @override
  void initState() {
    super.initState();
    _initializeData(); // 데이터 초기화
    _setupAnimation();
  }

  Future<void> _initializeData() async {
    // 상품 정보와 사용자 정보를 모두 불러옵니다.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 두 작업을 동시에 실행
      await Future.wait([
        _loadProducts(),
        _loadUserProfile(), // 사용자 정보 로딩 호출
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = '데이터를 불러오는 데 실패했습니다.\n서버가 켜져있는지 확인해주세요.';
      });
      allProducts = []; // 상품 로딩 실패 시
      _userProfileData = {}; // 사용자 정보 로딩 실패 시
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 상품 목록을 불러오는 함수 (별도 분리)
  Future<void> _loadProducts() async {
    try {
      allProducts = await ApiService.fetchProducts();
    } catch (e) {
      print('상품 로딩 실패: $e');
      throw Exception('상품 로딩 실패');
    }
  }

  // 실제 사용자 정보를 서버에서 불러오는 메서드
  Future<void> _loadUserProfile() async {
    // 'admin' ID를 사용합니다.
    const String currentUserId = 'admin';

    try {
      final userData = await ApiService.fetchUserProfile(currentUserId);
      // 프로필 이미지를 위한 임시 필드 추가
      _userProfileData = {
        ...userData,
        'imageUrl': 'https://placehold.co/200x200/3498DB/FFFFFF?text=${userData['User_ID']}'
      };
    } catch (e) {
      print('사용자 정보 로딩 실패: $e');
      throw Exception('사용자 정보 로딩 실패');
    }
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

  // [수정완료] showDialog 호출 방식 오류 수정됨
  void _showNotificationDialog() {
    showDialog(
      context: context, // <-- context: 를 추가하여 문법 오류 해결
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
    if (result == 'refresh') {
      // 상품 목록만 새로고침
      setState(() { _isLoading = true; });
      await _loadProducts();
      setState(() { _isLoading = false; });
    }
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
    if (result == true || result == 'refresh') {
      // 상품 목록만 새로고침
      setState(() { _isLoading = true; });
      await _loadProducts();
      setState(() { _isLoading = false; });
    }
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
        return ChatListScreen(onRoomTap: _onChatRoomTap);
      case 3: // "나의 정보" 탭
      // 실제 서버 데이터를 전달합니다.
        if (_userProfileData.isEmpty) {
          return const Center(child: Text('사용자 정보를 불러오는 데 실패했습니다.'));
        }
        return UserProfileScreen(user: _userProfileData);
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