import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widget/product_card.dart';

class SearchScreen extends StatefulWidget {
  // filteredProducts는 이제 검색 대상이 되는 '전체' 상품 목록을 의미합니다.
  final List<Product> filteredProducts;
  final void Function(Product) onProductTap;
  // onSearch 콜백은 제거됩니다.

  const SearchScreen({
    Key? key,
    required this.filteredProducts, // 이 이름은 유지하지만, 실제로는 검색 전 '전체' 목록입니다.
    required this.onProductTap,
    // required this.onSearch, // 이 줄 제거
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _displayedProducts = []; // 화면에 실제로 보여줄 상품 목록


  @override
  void initState() {
    super.initState();
  }

  // SearchScreen 내부 검색 로직
  void _performSearch(String query) {
    if (query.isEmpty) {
      // 검색어가 없으면 빈 목록을 보여줌
      setState(() {
        _displayedProducts = []; // 검색어 없으면 결과 없음
      });
    } else {
      // 검색어가 있으면 widget.filteredProducts (원본 전체 목록)에서 필터링
      final List<Product> searchResults = widget.filteredProducts
          .where((product) =>
              product.Product_Name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _displayedProducts = searchResults;
      });
    }
  }

  //구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('상품 검색', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onSubmitted: _performSearch,
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  // 검색 버튼 클릭 시 _performSearch 호출
                  onPressed: () => _performSearch(_searchController.text),
                  child: const Text('검색'),
                ),
              ],
            ),
          ),
          Expanded(
            // _displayedProducts를 기준으로 UI 업데이트
            child: _displayedProducts.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isNotEmpty // 검색어를 입력했는데 결과가 없는 경우
                          ? '검색 결과가 없습니다.'
                          : '검색할 상품을 찾아보세요.', // 초기 또는 검색어 입력 전
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
