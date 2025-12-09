import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product.dart';
import '../utils/distance_calculator.dart';
import '../main.dart'; // dapaGreen 상수 사용

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
  
  // 사용자 위치
  Position? _userPosition;
  bool _isLoadingLocation = true;
  bool _mapError = false;
  String? _mapErrorMessage;
  
  // 각 상품의 거리 정보를 저장 (상품 ID -> 거리 km)
  final Map<String, double> _productDistances = {};
  
  // GoogleMapController
  GoogleMapController? _mapController;

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
  Future<void> _initializeData() async {
    // 1. 사용자 위치 가져오기
    await _getUserLocation();
    
    // 2. 상품 리스트 복사
    List<Product> tempList = List.from(widget.products);

    // 3. 사용자 위치가 있으면 거리순 정렬, 없으면 기본 정렬
    if (_userPosition != null) {
      tempList = DistanceCalculator.sortByDistance(
        tempList,
        _userPosition!.latitude,
        _userPosition!.longitude,
      );
      
      // 각 상품의 거리 정보 저장
      for (var product in tempList) {
        final distance = DistanceCalculator.calculateDistance(
          _userPosition!.latitude,
          _userPosition!.longitude,
          product.latitude,
          product.longitude,
        );
        _productDistances[product.Product_Number] = distance;
      }
    } else {
      // 위치 정보가 없으면 기존 distance 필드로 정렬
      tempList.sort((a, b) => a.distance.compareTo(b.distance));
    }

    setState(() {
      _sortedProducts = tempList;
      _isLoadingLocation = false;
      _createMarkers(); // 마커 생성
    });
  }
  
  // 사용자 위치 가져오기
  Future<void> _getUserLocation() async {
    try {
      // 위치 서비스 활성화 여부 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ 위치 서비스가 비활성화되어 있습니다.');
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ 위치 권한이 거부되었습니다.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ 위치 권한이 영구적으로 거부되었습니다.');
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _userPosition = position;
      });
      
      print('✅ 사용자 위치: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ 위치 가져오기 실패: $e');
    }
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

  // Windows 플랫폼 체크
  bool get _isWindowsSupported {
    if (kIsWeb) return false;
    return !Platform.isWindows;
  }

  @override
  Widget build(BuildContext context) {
    // Windows에서는 지도가 지원되지 않음
    if (!_isWindowsSupported) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('동네 지도'),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Windows 미지원 메시지
            Container(
              height: 200,
              color: Colors.grey[100],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Windows에서는 지도 기능을\n사용할 수 없습니다',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '지도 기능은 Android 및 iOS에서만\n지원됩니다.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 하단: 거리순 상품 목록
            Expanded(
              child: _buildProductList(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('동네 지도'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🗺️ 상단: 구글 맵 (화면의 50%)
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                if (!_mapError)
                  GoogleMap(
                    initialCameraPosition: _initialCameraPosition,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      print('✅ 지도가 성공적으로 생성되었습니다.');
                      setState(() {
                        _mapController = controller;
                        _mapError = false;
                        _mapErrorMessage = null;
                      });
                    },
                    // 에러 발생 시 처리
                    onCameraMoveStarted: () {
                      print('📷 카메라 이동 시작');
                    },
                    onCameraIdle: () {
                      print('📷 카메라 이동 완료');
                    },
                  )
                else
                  Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '지도를 불러올 수 없습니다',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              _mapErrorMessage ?? 'Google Maps API 키가 설정되지 않았습니다.\n\nandroid/local.properties 파일에\ngoogle.maps.apiKey=YOUR_API_KEY\n를 추가해주세요.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _mapError = false;
                                _mapErrorMessage = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('다시 시도'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dapaGreen[500],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // 지도 로딩 오버레이
                if (_isLoadingLocation && !_mapError)
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              dapaGreen[500]!,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '지도를 불러오는 중...',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "근처 상품 목록",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (_isLoadingLocation)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (_userPosition != null)
                          Text(
                            '내 위치 기준',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
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
                                // 상품 이미지 - 1:1 비율로 고정
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[200],
                                    child: (product.Product_Picture.isNotEmpty)
                                        ? Image.network(
                                            product.Product_Picture,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      dapaGreen[500]!,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              print('❌ 이미지 로딩 실패: ${product.Product_Picture}');
                                              return Container(
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[400],
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.grey[400],
                                              size: 30,
                                            ),
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
                                        '${product.Product_Price.toString().replaceAllMapped(
                                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                          (Match m) => '${m[1]},',
                                        )}원',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: dapaGreen[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // 거리 정보 표시
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _productDistances.containsKey(product.Product_Number)
                                                ? DistanceCalculator.formatDistance(
                                                    _productDistances[product.Product_Number]!
                                                  )
                                                : (product.Product_Location.isNotEmpty
                                                    ? product.Product_Location
                                                    : '위치 정보 없음'),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
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

  // 상품 목록 위젯을 별도 메서드로 분리
  Widget _buildProductList() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "근처 상품 목록",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isLoadingLocation)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_userPosition != null)
                  Text(
                    '내 위치 기준',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
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
                        // 상품 이미지 - 1:1 비율로 고정
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: (product.Product_Picture.isNotEmpty)
                                ? Image.network(
                                    product.Product_Picture,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              dapaGreen[500]!,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('❌ 이미지 로딩 실패: ${product.Product_Picture}');
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[400],
                                          size: 30,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey[400],
                                      size: 30,
                                    ),
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
                                '${product.Product_Price.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                )}원',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: dapaGreen[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // 거리 정보 표시
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _productDistances.containsKey(product.Product_Number)
                                        ? DistanceCalculator.formatDistance(
                                            _productDistances[product.Product_Number]!
                                          )
                                        : (product.Product_Location.isNotEmpty
                                            ? product.Product_Location
                                            : '위치 정보 없음'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
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
    );
  }
}
