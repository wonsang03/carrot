// lib/screens/home_page.dart

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
import 'user_profile_screen.dart';
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
  // 임시로 로그인된 사용자 ID를 저장
  String get currentUserId => _userProfileData['User_Number'] ?? '8ac96703-506e-40fe-9ad2-5ba09d9896d5';


  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimation();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadProducts(),
        _loadUserProfile(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = '데이터를 불러오는 데 실패했습니다.\\n서버가 켜져있는지 확인해주세요.';
      });
      allProducts = [];
      _userProfileData = {};
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProducts() async {
    try {
      allProducts = await ApiService.fetchProducts();
    } catch (e) {
      print('상품 로딩 실패: $e');
      throw Exception('상품 로딩 실패');
    }
  }

  Future<void> _loadUserProfile() async {
    const String tempUserId = 'admin';

    try {
      final userData = await ApiService.fetchUserProfile(tempUserId);

      // ✅ [수정] 서버에서 이미 'imageUrl'을 설정했으므로, 임시 URL 생성 로직을 제거합니다.
      _userProfileData = userData;

    } catch (e) {
      print('사용자 정보 로딩 실패: $e');
      throw Exception('사용자 정보 로딩 실패');
    }
  }


  //기능 부분
  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          filteredProducts: allProducts,
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
    if (result == 'refresh') {
      setState(() { _isLoading = true; });
      await _loadProducts();
      setState(() { _isLoading = false; });
    }
  }

  // Navigation 오류 처리 (try-catch) 및 await 제거
  void _onChatRoomTap(ChatRoom chatRoom, String tempUserId) {
    final actualUserId = currentUserId;

    try {
      // await를 제거하여 화면 전환이 블로킹되는 것을 방지합니다.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatRoom: chatRoom,
            currentUserId: actualUserId,
          ),
        ),
      );
    } catch (e) {
      print('=====================================================');
      print('❌❌ NAVIGATION PUSH EXCEPTION ❌❌');
      print('Error Details: $e');
      print('=====================================================');
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('화면 전환 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _onSellButtonPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SellItemScreen()),
    );
    if (result == true || result == 'refresh') {
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

    List<Product> productsToShow = allProducts;

    switch (_currentIndex) {
      case 0:
        return HomeScreen(products: productsToShow, onProductTap: _onProductTap);
      case 1:
        return MapScreen(products: allProducts, onProductTap: _onProductTap);
      case 2:
        return ChatListScreen(onRoomTap: _onChatRoomTap);
      case 3:
        if (_userProfileData.isEmpty) {
          return const Center(child: Text('사용자 정보를 불러오는 데 실패했습니다.'));
        }
        return UserProfileScreen(user: _userProfileData);
      default:
        return HomeScreen(products: productsToShow, onProductTap: _onProductTap);
    }
  }

  //디자인 부분
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _currentIndex == 0
          ? AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text('대파마켓', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _navigateToSearch),
          IconButton(icon: const Icon(Icons.notifications), onPressed: _showNotificationDialog),
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
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}