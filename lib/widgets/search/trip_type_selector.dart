import 'package:flutter/material.dart';

class TripTypeSelector extends StatelessWidget {
  final String selectedTripType;
  final Function(String) onTripTypeChanged;
  final Color accentColor;

  const TripTypeSelector({
    Key? key,
    required this.selectedTripType,
    required this.onTripTypeChanged,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tipo de Viagem",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSelectionButton(
                text: 'Somente Ida',
                icon: Icons.flight_takeoff,
                isSelected: selectedTripType == 'OneWay',
                onTap: () => onTripTypeChanged('OneWay'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectionButton(
                text: 'Ida e Volta',
                icon: Icons.swap_horiz,
                isSelected: selectedTripType == 'RoundTrip',
                onTap: () => onTripTypeChanged('RoundTrip'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionButton({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? accentColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? accentColor : Colors.grey),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? accentColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
