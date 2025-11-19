import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/product.dart';

class MapScreen extends StatefulWidget {
  final List<Product> products; // 홈에서 받아온 전체 상품 목록
  final void Function(Product) onProductTap;

  const MapScreen({Key? key, required this.products, required this.onProductTap}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 지도에 표시할 마커들을 담는 Set
  final Set<Marker> _markers = {};
  
  // 정렬된 상품 리스트
  List<Product> _sortedProducts = [];

  // 지도의 초기 카메라 위치 (목포대)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(34.80878889, 126.3944194),
    zoom: 14.5,
  );

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // 🛠️ 데이터 설정 및 마커 생성
  void _initializeData() {
    // 1. 상품 리스트 복사
    List<Product> tempList = List.from(widget.products);

    // 2. 거리순 정렬 (distance 필드 사용)
    // distance가 0인 경우(데이터 없음)는 뒤로 갈 수도 있음.
    tempList.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {
      _sortedProducts = tempList;
      _createMarkers(); // 마커 생성
    });
  }

  // 마커 생성 함수
  void _createMarkers() {
    _markers.clear();
    for (var product in _sortedProducts) {
      // 위도 경도가 유효한 경우에만 마커 생성 (0.0, 0.0은 제외)
      if (product.latitude == 0.0 && product.longitude == 0.0) continue;

      final marker = Marker(
        markerId: MarkerId(product.Product_Number),
        position: LatLng(product.latitude, product.longitude),
        infoWindow: InfoWindow(
          title: product.Product_Name,
          snippet: '${product.Product_Price}원',
          onTap: () => widget.onProductTap(product),
        ),
      );
      _markers.add(marker);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('동네 지도'),
      ),
      body: Column(
        children: [
          // 🗺️ 상단: 구글 맵 (화면의 50%)
          Expanded(
            flex: 1,
            child: GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          
          // 📋 하단: 거리순 상품 목록 (화면의 50%)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "근처 상품 목록",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _sortedProducts.length,
                      itemBuilder: (context, index) {
                        final product = _sortedProducts[index];

                        return InkWell(
                          onTap: () => widget.onProductTap(product),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                            ),
                            child: Row(
                              children: [
                                // 상품 이미지
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: (product.Product_Picture.isNotEmpty)
                                        ? Image.network(
                                            product.Product_Picture,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.image_not_supported, color: Colors.grey),
                                          )
                                        : Container(
                                            color: Colors.grey,
                                            child: const Icon(Icons.camera_alt, color: Colors.white),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // 상품 정보
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.Product_Name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.Product_Price}원',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // ✨ [수정] 서버에서 받은 위치 정보 문자열(Product_Location) 표시
                                      // 값이 비어있으면 '위치 정보 없음' 표시
                                      Text(
                                        product.Product_Location.isNotEmpty 
                                          ? product.Product_Location 
                                          : '위치 정보 없음',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
