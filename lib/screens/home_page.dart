import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/chat_room.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/product_card.dart';
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
    setState(() => _isLoading = true);
    try {
      final products = await ApiService.fetchProducts();
      allProducts = products.isEmpty ? _getDummyProducts() : products;
    } catch (_) {
      allProducts = _getDummyProducts();
    }
    setState(() => _isLoading = false);
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

  List<Product> _getDummyProducts() {
    return [
      Product(
        Product_Number: 1,
        Product_Name: '아이폰 14 Pro 256GB',
        Product_Price: 1200000,
        Product_Picture: 'https://via.placeholder.com/300',
        Product_Info: '아이폰 14 프로 설명',
        User_location: '강남구 역삼동',
        distance: 1.2,
        latitude: 37.5665,
        longitude: 126.9780,
        Product_State: true,
        User_Number: 1,
      ),
      // ... 추가 더미 데이터
    ];
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

  void _onChatRoomTap(ChatRoom chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatDetailScreen(chatRoom: chatRoom)),
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
    if (_isLoading && _currentIndex == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (_currentIndex) {
      case 0:
        return HomeScreen(products: allProducts, onProductTap: _onProductTap);
      case 1:
        return MapScreen(products: allProducts, onProductTap: _onProductTap);
      case 2:
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
