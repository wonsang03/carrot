// home_screen.dart

// Flutter에서 UI를 만들기 위한 기본 재료들을 가져옵니다.
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widget/product_card.dart';

// HomeScreen: 외부에서 전달받은 상품 목록을 화면에 표시합니다.
class HomeScreen extends StatefulWidget {
  final List<Product> products; // 외부에서 전달받는 '전체' 또는 '필터링된' 상품 목록 데이터입니다.
  final void Function(Product) onProductTap; // 상품 카드를 눌렀을 때 실행될 함수입니다.

  const HomeScreen({
    Key? key,
    required this.products,
    required this.onProductTap,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // AppBar를 완전히 제거
      body: widget.products.isEmpty
          ? const Center(child: Text('표시할 상품이 없습니다.'))
          : ListView.builder(
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          return ProductCard(
            product: product,
            onTap: () => widget.onProductTap(product),
          );
        },
      ),
    );
  }
}
