import 'package:flutter/material.dart';
import '../models/product.dart';

// ProductCard 위젯은 상품 하나의 정보를 카드 형태로 예쁘게 보여주는 역할을 합니다.
// 여러 상품을 리스트로 보여줄 때, 각 상품마다 이 위젯을 사용하면 됩니다.
class ProductCard extends StatelessWidget {
  final Product product;         // 보여줄 상품 정보
  final VoidCallback? onTap;     // 카드 클릭 시 실행할 함수 (예: 상세 화면 이동)
  const ProductCard({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // 카드 바깥쪽 여백
      elevation: 2, // 그림자 깊이 (카드가 살짝 떠보임)
      child: InkWell(
        onTap: onTap, // 카드 전체를 터치할 수 있게 만듦
        child: Padding(
          padding: const EdgeInsets.all(12.0), // 카드 안쪽 여백
          child: Row(
            children: [
              // 상품 이미지를 네모난 모서리로 잘라서 표시
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // 이미지 모서리 둥글게
                child: Image.network(
                  product.Product_Picture, // 상품 이미지 주소
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover, // 이미지를 카드에 꽉 채움
                  // 이미지를 불러오지 못할 때는 기본 아이콘을 대신 보여줌
                  errorBuilder: (context, error, stackTrace) =>
                      Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.image)),
                ),
              ),
              const SizedBox(width: 16), // 이미지와 정보 사이 간격
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    // 상품 이름
                    Text(product.Product_Name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    // 상품 가격 (오렌지색)
                    Text('${product.Product_Price}원', style: const TextStyle(fontSize: 16, color: Colors.orange)),
                    const SizedBox(height: 6),
                    // 판매자 위치 (회색)
                    Text(product.User_location, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              // 오른쪽에 > 아이콘 (상세 화면으로 이동할 수 있다는 표시)
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
