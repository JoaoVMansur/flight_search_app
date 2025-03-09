import 'package:flutter/material.dart';

class SearchFormCard extends StatelessWidget {
  final Widget child;
  final Color cardColor;

  const SearchFormCard({Key? key, required this.child, required this.cardColor})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
