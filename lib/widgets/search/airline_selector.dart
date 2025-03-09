import 'package:flutter/material.dart';

class AirlineSelector extends StatelessWidget {
  final List<String> selectedAirlines;
  final Function(String, bool) onAirlineToggled;
  final Color accentColor;

  const AirlineSelector({
    Key? key,
    required this.selectedAirlines,
    required this.onAirlineToggled,
    required this.accentColor,
  }) : super(key: key);

  static const List<String> allAirlines = [
    'AMERICAN AIRLINES',
    'GOL',
    'IBERIA',
    'INTERLINE',
    'LATAM',
    'AZUL',
    'TAP',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Companhias Aéreas",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              allAirlines.map((airline) => _buildAirlineChip(airline)).toList(),
        ),
      ],
    );
  }

  Widget _buildAirlineChip(String airline) {
    bool isSelected = selectedAirlines.contains(airline);

    return FilterChip(
      label: Text(airline),
      selected: isSelected,
      checkmarkColor: Colors.white,
      selectedColor: accentColor,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 12,
      ),
      onSelected: (bool selected) {
        onAirlineToggled(airline, selected);
      },
    );
  }
}
