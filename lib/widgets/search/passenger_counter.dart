import 'package:flutter/material.dart';

class PassengerCounter extends StatelessWidget {
  final String label;
  final String description;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color accentColor;

  const PassengerCounter({
    Key? key,
    required this.label,
    required this.description,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: onDecrement,
                isEnabled: count > (label == "Adultos" ? 1 : 0),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onTap: onIncrement,
                isEnabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? accentColor : Colors.grey.shade400,
        ),
      ),
    );
  }
}
