import 'package:flutter/material.dart';

class ConnectionPreview extends StatelessWidget {
  final List<Map<String, dynamic>> conexoes;
  final Color accentColor;

  const ConnectionPreview({
    Key? key,
    required this.conexoes,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              conexoes
                  .map((c) => '${c['Origem']} → ${c['Destino']}')
                  .join(' | '),
              style: TextStyle(
                fontSize: 13,
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
