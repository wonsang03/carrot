// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widget/product_card.dart';
import '../main.dart'; // DapaGreen 사용을 위해 import

class SearchScreen extends StatefulWidget {
  final List<Product> filteredProducts;
  final void Function(Product) onProductTap;

  const SearchScreen({
    Key? key,
    required this.filteredProducts,
    required this.onProductTap,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _displayedProducts = [];

  @override
  void initState() {
    super.initState();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _displayedProducts = [];
      });
    } else {
      final List<Product> searchResults = widget.filteredProducts
          .where((product) =>
          product.Product_Name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _displayedProducts = searchResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ AppBar는 main.dart 테마를 따름
        elevation: 1,
        title: const Text('상품 검색', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // ✅ 패딩 조정
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '상품 이름으로 검색',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // ✅ 모서리를 둥글게 조정
                        borderSide: BorderSide.none, // ✅ 테두리 선 제거
                      ),
                      filled: true,
                      fillColor: Colors.grey[100], // ✅ 배경색 추가
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onSubmitted: _performSearch,
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ 버튼 색상 및 스타일 조정
                ElevatedButton(
                  onPressed: () => _performSearch(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('검색'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _displayedProducts.isEmpty
                ? Center(
              child: Text(
                _searchController.text.isNotEmpty
                    ? '검색 결과가 없습니다.'
                    : '검색할 상품을 찾아보세요.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: _displayedProducts.length,
              itemBuilder: (_, i) {
                final product = _displayedProducts[i];
                return ProductCard(
                  product: product,
                  onTap: () => widget.onProductTap(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}