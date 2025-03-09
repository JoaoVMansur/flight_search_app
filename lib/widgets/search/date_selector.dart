import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final TextEditingController departureDateController;
  final TextEditingController returnDateController;
  final String selectedTripType;
  final Function() onSelectDepartureDate;
  final Function() onSelectReturnDate;
  final Color accentColor;
  final Color primaryColor;

  const DateSelector({
    Key? key,
    required this.departureDateController,
    required this.returnDateController,
    required this.selectedTripType,
    required this.onSelectDepartureDate,
    required this.onSelectReturnDate,
    required this.accentColor,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Datas",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: departureDateController,
          decoration: InputDecoration(
            labelText: 'Data de Ida',
            filled: true,
            fillColor: Colors.grey.shade100,
            prefixIcon: Icon(Icons.calendar_today, color: accentColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            hintText: 'Selecione a data',
          ),
          readOnly: true,
          onTap: onSelectDepartureDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecione a data de ida';
            }
            return null;
          },
        ),
        if (selectedTripType == 'RoundTrip')
          Column(
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: returnDateController,
                decoration: InputDecoration(
                  labelText: 'Data de Volta',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: Icon(Icons.calendar_today, color: accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: 'Selecione a data',
                ),
                readOnly: true,
                onTap: onSelectReturnDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione a data de volta';
                  }
                  return null;
                },
              ),
            ],
          ),
      ],
    );
  }
}
