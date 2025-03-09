import 'package:flutter/material.dart';

class AirportSelector extends StatelessWidget {
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final List<String> airports;
  final Color accentColor;

  const AirportSelector({
    Key? key,
    required this.departureController,
    required this.arrivalController,
    required this.airports,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Seu Itinerário",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textValue) {
            return airports.where(
              (String value) =>
                  value.toLowerCase().contains(textValue.text.toLowerCase()),
            );
          },
          onSelected: (String selectedValue) {
            departureController.text = selectedValue;
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            focusNode,
            onFieldSubmitted,
          ) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Origem',
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: Icon(Icons.flight_takeoff, color: accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                hintText: 'De onde você vai partir?',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe a origem';
                }
                return null;
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_downward, color: accentColor),
          ),
        ),
        const SizedBox(height: 16),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textValue) {
            return airports.where(
              (String value) =>
                  value.toLowerCase().contains(textValue.text.toLowerCase()),
            );
          },
          onSelected: (String selectedValue) {
            arrivalController.text = selectedValue;
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            focusNode,
            onFieldSubmitted,
          ) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Destino',
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: Icon(Icons.flight_land, color: accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                hintText: 'Para onde você vai?',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o destino';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }
}
