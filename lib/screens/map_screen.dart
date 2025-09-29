// map_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  final List<Product> products; // 홈에서 받아온 상품 목록 (옵션)
  final void Function(Product) onProductTap;
  const MapScreen({Key? key, required this.products, required this.onProductTap}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Product>> futureNearbyProducts;

  @override
  void initState() {
    super.initState();
    // 예시: 강남역 근처 상품 5km 이내 검색
    futureNearbyProducts = ApiService.fetchProductsByLocation(
      latitude: 37.4979,
      longitude: 127.0276,
      radiusKm: 5.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: futureNearbyProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('근처 상품을 불러올 수 없습니다.'));
        } else if (snapshot.hasData) {
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('근처에 상품이 없습니다.'));
          }
          // 실제로는 지도 위에 마커로 표시해야 함? (여기선 리스트로 예시)
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return ListTile(
                title: Text(p.Product_Name),
                subtitle: Text('${p.Product_Price}원'),
                onTap: () => widget.onProductTap(p),
              );
            },
          );
        } else {
          return const Center(child: Text('알 수 없는 오류'));
        }
      },
    );
  }
}
