// home_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widget/product_card.dart';

class HomeScreen extends StatelessWidget {
  final List<Product> products; // 상품 목록 데이터
  final void Function(Product) onProductTap; // 상품 클릭 시 실행할 함수

  const HomeScreen({
    Key? key,
    required this.products,
    required this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 제거하여 '상품목록' 텍스트가 보이지 않도록 함
      appBar: null,
      body: products.isEmpty
      // 상품이 없을 때 안내 메시지
          ? const Center(child: Text('등록된 상품이 없습니다.'))
      // 상품이 있을 때 목록 표시
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          // 상품 정보를 카드 형태로 보여줌
          return ProductCard(
            product: product,
            onTap: () => onProductTap(product),
          );
        },
      ),
    );
  }
}
