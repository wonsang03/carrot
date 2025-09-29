import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final Animation<double> animation;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      height: w * 0.2,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, Icons.home, "홈"),
          _navItem(1, Icons.map, "지도"),
          _navItem(2, Icons.chat, "채팅"),
          _navItem(3, Icons.person, "나의 정보"),
        ],
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final isSel = idx == currentIndex;
    return GestureDetector(
      onTap: () => onTap(idx),
      child: ScaleTransition(
        scale: isSel ? animation : const AlwaysStoppedAnimation(1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSel ? Colors.orange : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSel ? Colors.orange : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
