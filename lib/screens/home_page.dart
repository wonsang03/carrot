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
  // --- 수정된 부분 1: 에러 메시지를 저장할 상태 변수 추가 ---
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

  // --- 수정된 부분 2: API 호출 실패 시 에러 메시지를 설정하도록 변경 ---
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // 로딩 시작 시 에러 메시지 초기화
    });
    try {
      // 서버에서 실제 상품 목록을 요청합니다.
      allProducts = await ApiService.fetchProducts();
      // 참고: 서버 응답이 비어있는 경우에 대한 처리를 추가할 수 있습니다.
      // if (allProducts.isEmpty) {
      //   setState(() => _errorMessage = '등록된 상품이 없습니다.');
      // }
    } catch (e) {
      // 에러가 발생하면, 더미 데이터를 보여주는 대신 에러 메시지를 상태에 저장합니다.
      setState(() {
        _errorMessage = '데이터를 불러오는 데 실패했습니다.\n서버가 켜져있는지 확인해주세요.';
      });
      allProducts = []; // 에러 발생 시 상품 목록을 비웁니다.
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

  // --- 수정된 부분 3: 에러 메시지가 있을 때 화면에 표시하는 로직 추가 ---
  Widget _buildCurrentScreen() {
    // 1. 로딩 중일 때 로딩 인디케이터 표시
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // 2. 에러 메시지가 있을 때 에러 메시지 표시
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
    // 3. 정상 상태일 때 각 탭에 맞는 화면 표시
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