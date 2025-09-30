import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/chat_room.dart';
import '../widget/bottom_nav_bar.dart';
import '../services/api_service.dart';
import '../services/global_state.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimation();
  }

  Future<void> _initializeData() async {
    GlobalState.setDummyUser();
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
          allProducts: allProducts,
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

  // ✨ [수정된 부분 1] _onChatRoomTap 함수가 userId 파라미터를 추가로 받도록 변경
  void _onChatRoomTap(ChatRoom chatRoom, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // ✨ [수정된 부분 2] ChatDetailScreen에 chatRoom과 함께 userId를 전달
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProducts,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }
    switch (_currentIndex) {
      case 0:
        return HomeScreen(products: allProducts, onProductTap: _onProductTap);
      case 1:
        return MapScreen(products: allProducts, onProductTap: _onProductTap);
      case 2:
      // ✨ [수정된 부분 3] ChatListScreen에 수정된 _onChatRoomTap 함수를 전달
        return ChatListScreen(onRoomTap: _onChatRoomTap);
      case 3:
        return const UserProfileScreen();
      default:
        return HomeScreen(products: allProducts, onProductTap: _onProductTap);
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
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0,
        title: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                '대파마켓',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: _navigateToSearch,
              tooltip: '상품 검색',
            ),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: _showNotificationDialog,
              tooltip: '알림',
            ),
          ],
        ),
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
