// search_screen.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widget/product_card.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> allProducts;
  final void Function(Product) onProductTap;

  const SearchScreen({
    Key? key,
    required this.allProducts,
    required this.onProductTap,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];    // 최근 검색어 저장
  List<Product> filteredProducts = []; // 검색 결과
  bool _hasSearched = false;           // 검색 버튼 클릭 여부

  @override
  void initState() {
    super.initState();
    filteredProducts = widget.allProducts; // 처음에는 모든 상품 표시
  }

  // 🔍 상품 검색 및 기록 저장 함수 (검색 버튼 클릭 시)
  void _onSearchButtonPressed() {
    final query = _searchController.text.trim();
    setState(() {
      _hasSearched = true;
      if (query.isEmpty) {
        filteredProducts = widget.allProducts;
      } else {
        filteredProducts = widget.allProducts
            .where((p) => p.Product_Name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        // 최근 검색어에 추가 (중복 제거)
        if (query.isNotEmpty) {
          recentSearches.remove(query);
          recentSearches.insert(0, query);
          if (recentSearches.length > 5) {
            recentSearches = recentSearches.sublist(0, 5);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '상품 검색',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 🔍 검색 입력창 및 버튼
          Container(
            padding: const EdgeInsets.all(16),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearchButtonPressed,
                  child: const Text('검색'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // 변경된 속성명
                    foregroundColor: Colors.white, // 변경된 속성명
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 🔖 최근 검색어 목록 (검색 버튼 클릭 후 항상 표시)
          if (recentSearches.isNotEmpty) ...[
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text('최근 검색어', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: recentSearches.map((word) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = word;
                      _onSearchButtonPressed();
                    },
                    child: Chip(
                      label: Text(word),
                      onDeleted: () {
                        setState(() => recentSearches.remove(word));
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 8),
          // 📦 검색 결과 또는 안내 메시지
          Expanded(
            child: !_hasSearched
                ? Center(
              child: Text(
                '검색어를 입력 후 검색 버튼을 눌러주세요.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
                : filteredProducts.isEmpty
                ? Center(
              child: Text(
                '검색 결과가 없습니다.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (_, i) {
                final product = filteredProducts[i];
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
