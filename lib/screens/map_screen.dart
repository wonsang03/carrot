// map_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/product.dart';
// import '../services/api_service.dart'; // 더 이상 직접 API를 호출하지 않으므로 주석 처리

class MapScreen extends StatefulWidget {
  final List<Product> products; // 홈에서 받아온 전체 상품 목록
  final void Function(Product) onProductTap;
  const MapScreen({Key? key, required this.products, required this.onProductTap}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 지도에 표시할 마커들을 담는 Set입니다. Set을 사용하면 중복된 마커를 자동으로 방지할 수 있습니다.
  final Set<Marker> _markers = {};

  // 지도의 초기 카메라 위치를 강남역으로 설정합니다.
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.4979, 127.0276), // 강남역의 위도, 경도
    zoom: 14.5, // 확대 수준
  );

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  //아직 더미임
  // 상품 목록을 기반으로 지도에 표시할 마커들을 생성하는 함수입니다.
  void _createMarkers() {
    final random = Random();

    for (var product in widget.products) {
      // 중요: 현재 상품 데이터에 위도/경도가 없으므로, UI 확인을 위해 강남역 근처에 임의의 좌표를 생성합니다.
      //       나중에 실제 서비스에서는 상품마다 저장된 실제 좌표를 사용해야 합니다.
      final randomLat = _initialCameraPosition.target.latitude + (random.nextDouble() - 0.5) * 0.02;
      final randomLng = _initialCameraPosition.target.longitude + (random.nextDouble() - 0.5) * 0.02;
      
      final marker = Marker(
        markerId: MarkerId(product.Product_Number.toString()), // 각 마커의 고유 ID
        position: LatLng(randomLat, randomLng), // 마커의 위치 (임시 좌표)
        // 마커를 탭했을 때 표시될 정보 창
        infoWindow: InfoWindow(
          title: product.Product_Name, // 상품명
          snippet: '${product.Product_Price}원', // 상품 가격
          onTap: () => widget.onProductTap(product), // 정보 창을 탭하면 상품 상세 페이지로 이동
        ),
        onTap: () {
          // 마커 자체를 탭했을 때의 동작 (필요 시 추가)
        },
      );

      // 생성된 마커를 _markers Set에 추가합니다.
      _markers.add(marker);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이제 FutureBuilder 대신 GoogleMap 위젯을 직접 반환합니다.
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition, // 초기 카메라 위치 설정
      markers: _markers, // 화면에 표시할 마커들
      myLocationEnabled: true, // 지도에 '내 위치' 버튼 표시
      myLocationButtonEnabled: true,
    );
  }
}
