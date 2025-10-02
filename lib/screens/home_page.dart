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

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          filteredProducts: allProducts, // SearchScreen에 전체 상품 목록 전달
          onProductTap: _onProductTap,
          // onSearch 콜백 제거
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
          currentUserId: userId,
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

    List<Product> productsToShow = allProducts;
    if (_currentIndex == 0) {
      productsToShow = allProducts; 
    }

    switch (_currentIndex) {
      case 0:
        return HomeScreen(products: productsToShow, onProductTap: _onProductTap);
      case 1:
        return MapScreen(products: allProducts, onProductTap: _onProductTap);
      case 2:
      // ✨ [수정된 부분]
      // 더 이상 존재하지 않는 더미 데이터를 호출하는 대신, 임시 화면을 표시하여 오류를 해결했습니다.
      // TODO: 로그인 기능 구현 후, 실제 사용자 정보를 UserProfileScreen에 전달해야 합니다.
        return ChatListScreen(onRoomTap: _onChatRoomTap);
      case 3: // "나의 정보" 탭
        // TODO: 로그인 기능 구현 후, 실제 사용자 정보를 UserProfileScreen에 전달해야 합니다. (이 주석은 유지)
        // 1. UserProfileScreen에 전달할 임시 사용자 데이터를 만듭니다.
        //추후 실제 데이터로 전송예정
        final Map<String, dynamic> tempUserData = {
          'name': '김당근 (임시 프론트엔드)',
          'email': 'frontend.dev@example.com',
          'imageUrl': 'https://placehold.co/200x200/FF9800/FFFFFF?text=🥕',
          'location': '프론트엔드 임시 마을'
        };
        // 2. UserProfileScreen 위젯을 생성하고, 임시 데이터를 'user' 파라미터로 전달합니다.
        return UserProfileScreen(user: tempUserData);
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
