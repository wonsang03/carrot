import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widget/product_card.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> filteredProducts;
  final void Function(Product) onProductTap;
  final void Function(String) onSearch;

  const SearchScreen({
    Key? key,
    required this.filteredProducts,
    required this.onProductTap,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

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
                    onSubmitted: widget.onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => widget.onSearch(_searchController.text),
                  child: const Text('검색'),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.filteredProducts.isEmpty
                ? Center(
              child: Text(
                '검색 결과가 없습니다.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: widget.filteredProducts.length,
              itemBuilder: (_, i) {
                final product = widget.filteredProducts[i];
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

