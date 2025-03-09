import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String selectedSortOption;
  final String selectedFareType;
  final bool showMiles;
  final Function(String?) onSortOptionChanged;
  final Function(String?) onFareTypeChanged;
  final Function(bool) onShowMilesChanged;
  final Color primaryColor;

  const FilterBar({
    Key? key,
    required this.selectedSortOption,
    required this.selectedFareType,
    required this.showMiles,
    required this.onSortOptionChanged,
    required this.onFareTypeChanged,
    required this.onShowMilesChanged,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Ordenar por',
                    labelStyle: TextStyle(color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: primaryColor.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  value: selectedSortOption,
                  items:
                      [
                        'Preço',
                        'Duração',
                        'Horário de partida',
                        'Horário de chegada',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: Colors.black87),
                          ),
                        );
                      }).toList(),
                  onChanged: onSortOptionChanged,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'BRL',
                      style: TextStyle(
                        fontWeight:
                            showMiles ? FontWeight.normal : FontWeight.bold,
                        color: showMiles ? Colors.grey.shade600 : primaryColor,
                      ),
                    ),
                    Switch(
                      value: showMiles,
                      activeColor: primaryColor,
                      activeTrackColor: primaryColor.withOpacity(0.5),
                      inactiveThumbColor: primaryColor,
                      inactiveTrackColor: primaryColor.withOpacity(0.5),
                      onChanged: onShowMilesChanged,
                    ),
                    Text(
                      'Milhas',
                      style: TextStyle(
                        fontWeight:
                            showMiles ? FontWeight.bold : FontWeight.normal,
                        color: showMiles ? primaryColor : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipo de Tarifa',
              labelStyle: TextStyle(color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            value: selectedFareType,
            items:
                ['Start', 'Econômica', 'Executiva'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.black87)),
                  );
                }).toList(),
            onChanged: onFareTypeChanged,
          ),
        ],
      ),
    );
  }
}
