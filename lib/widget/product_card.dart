// lib/widget/product_card.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../main.dart'; // ✅ dapaGreen 상수를 사용하기 위해 추가

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // dapaGreen을 import 했으므로 사용 가능합니다.
    final Color primaryColor = dapaGreen[700]!;

    return Card(
      // margin과 elevation을 약간 줄여서 깔끔하게 만듦
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 상품 이미지를 네모난 모서리로 잘라서 표시
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.Product_Picture,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  // 이미지를 불러오지 못할 때는 기본 아이콘을 대신 보여줌
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.white70) // 아이콘 색상 조정
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품 이름
                    Text(
                        product.Product_Name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600) // 글꼴 굵기 조정
                    ),
                    const SizedBox(height: 4), // 간격 조정
                    // 상품 가격 (초록색 계열 강조)
                    Text(
                        '${product.Product_Price}원',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold, // ✅ 굵기 강조
                            color: primaryColor // ✅ 초록색 계열 적용
                        )
                    ),
                    const SizedBox(height: 6),
                    // 판매자 위치 (회색)
                    Text(
                        product.User_location,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]) // 글꼴 크기/색상 조정
                    ),
                  ],
                ),
              ),
              // 오른쪽에 > 아이콘
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}