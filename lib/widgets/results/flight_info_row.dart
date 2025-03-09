import 'package:flutter/material.dart';

class FlightInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textPrimaryColor;
  final Color textSecondaryColor;

  const FlightInfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSecondaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: textSecondaryColor, fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
