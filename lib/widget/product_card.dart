// lib/widgets/product_card.dart
// 🎴 상품 카드 위젯 - 데이터 통일 버전

import 'package:flutter/material.dart';
import '../models/product.dart';

/// ProductCard 위젯은 상품 하나의 정보를 카드 형태로 예쁘게 보여주는 역할을 합니다.
/// 여러 상품을 리스트로 보여줄 때, 각 상품마다 이 위젯을 사용하면 됩니다.
/// ⭐ User_location → User_Location 변경사항 반영
class ProductCard extends StatelessWidget {
  final Product product;           // 보여줄 상품 정보
  final VoidCallback? onTap;       // 카드 클릭 시 실행할 함수 (예: 상세 화면 이동)

  const ProductCard({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🎴 ProductCard build - 상품: ${product.Product_Name}');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),  // 카드 바깥쪽 여백
      elevation: 2,                                                     // 그림자 깊이 (카드가 살짝 떠보임)
      child: InkWell(
        onTap: () {
          print('🖱️ 상품 카드 클릭: ${product.Product_Name}');
          onTap?.call();  // null이 아닐 때만 실행
        },
        // 클릭 시 물결 효과
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),  // 카드 안쪽 여백
          child: Row(
            children: [
              // ===== 📸 상품 이미지 =====
              ClipRRect(
                borderRadius: BorderRadius.circular(8),  // 이미지 모서리 둥글게
                child: _buildProductImage(),
              ),
              const SizedBox(width: 16),  // 이미지와 정보 사이 간격

              // ===== 📝 상품 정보 =====
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,  // 왼쪽 정렬
                  children: [
                    // 상품 이름
                    Text(
                      product.Product_Name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,  // 긴 제목은 ... 으로 표시
                    ),
                    const SizedBox(height: 6),

                    // 상품 가격 (포맷팅된 가격 사용) ⭐ 수정
                    Text(
                      product.getFormattedPrice(),  // "1,000,000원" 형식
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 판매자 위치 ⭐ User_location → User_Location 변경 반영
                    Text(
                      product.User_Location.isNotEmpty
                          ? product.User_Location
                          : '위치 정보 없음',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // ===== 📊 추가 정보 행 =====
                    Row(
                      children: [
                        // 판매 상태 표시
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: product.Product_State
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: product.Product_State
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            product.Product_State ? '판매중' : '판매완료',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: product.Product_State
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 거리 정보 (있을 경우)
                        if (product.distance > 0) ...[
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.getFormattedDistance(),  // "1.5km" 또는 "500m"
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],

                        const Spacer(),  // 남은 공간 모두 차지

                        // 판매자 번호 표시 (개발용) ⭐ 추가
                        if (product.User_Number == 1) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '개발',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ===== ▶️ 화살표 아이콘 =====
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📸 상품 이미지를 빌드하는 헬퍼 함수
  Widget _buildProductImage() {
    return SizedBox(
      width: 80,
      height: 80,
      child: product.Product_Picture.isNotEmpty
          ? Image.network(
        product.Product_Picture,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          // 로딩 중일 때 표시할 위젯
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ 상품 이미지 로딩 실패: ${product.Product_Name} - $error');

          // 이미지 로딩 실패 시 표시할 위젯
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 24,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 4),
                Text(
                  '이미지\n없음',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        },
      )
          : Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 28,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              '이미지\n없음',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}