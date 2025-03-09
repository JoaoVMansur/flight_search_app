import 'package:flutter/material.dart';
import '../../models/flight_model.dart';
import '../../utils/price_formatter.dart';

class SummaryFooter extends StatelessWidget {
  final Flight? selectedOutboundFlight;
  final Flight? selectedReturnFlight;
  final String selectedFareType;
  final bool showMiles;
  final Color primaryColor;
  final Color accentColor;
  final Color priceColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final VoidCallback onContinue;

  const SummaryFooter({
    Key? key,
    this.selectedOutboundFlight,
    this.selectedReturnFlight,
    required this.selectedFareType,
    required this.showMiles,
    required this.primaryColor,
    required this.accentColor,
    required this.priceColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double outboundPrice = 0;
    double outboundFee = 0;
    double returnPrice = 0;
    double returnFee = 0;

    if (selectedOutboundFlight != null) {
      final priceInfo = selectedOutboundFlight!.getPriceInfo(
        selectedFareType,
        showMiles,
      );

      if (priceInfo.isNotEmpty) {
        num adultPrice = priceInfo['Adulto'] ?? 0.0;
        num childPrice = priceInfo['Crianca'] ?? 0.0;
        num boardingFeeRate = priceInfo['TaxaEmbarque'] ?? 0.0;

        int adultCount = 1;
        int childCount = 0;

        if (selectedOutboundFlight!.passageiros != null) {
          adultCount = selectedOutboundFlight!.passageiros!['Adultos'] ?? 1;
          childCount = selectedOutboundFlight!.passageiros!['Criancas'] ?? 0;
        } else if (priceInfo.containsKey('NumeroAdultos') ||
            priceInfo.containsKey('NumeroCriancas')) {
          adultCount = priceInfo['NumeroAdultos'] ?? 1;
          childCount = priceInfo['NumeroCriancas'] ?? 0;
        }

        adultPrice =
            adultPrice is int ? adultPrice.toDouble() : adultPrice as double;
        childPrice =
            childPrice is int ? childPrice.toDouble() : childPrice as double;
        boardingFeeRate =
            boardingFeeRate is int
                ? boardingFeeRate.toDouble()
                : boardingFeeRate as double;

        outboundPrice = (adultPrice * adultCount) + (childPrice * childCount);
        outboundFee = boardingFeeRate * (adultCount + childCount);
      }
    }

    if (selectedReturnFlight != null) {
      final priceInfo = selectedReturnFlight!.getPriceInfo(
        selectedFareType,
        showMiles,
      );

      if (priceInfo.isNotEmpty) {
        num adultPrice = priceInfo['Adulto'] ?? 0.0;
        num childPrice = priceInfo['Crianca'] ?? 0.0;
        num boardingFeeRate = priceInfo['TaxaEmbarque'] ?? 0.0;

        int adultCount = 1;
        int childCount = 0;

        if (selectedReturnFlight!.passageiros != null) {
          adultCount = selectedReturnFlight!.passageiros!['Adultos'] ?? 1;
          childCount = selectedReturnFlight!.passageiros!['Criancas'] ?? 0;
        } else if (priceInfo.containsKey('NumeroAdultos') ||
            priceInfo.containsKey('NumeroCriancas')) {
          adultCount = priceInfo['NumeroAdultos'] ?? 1;
          childCount = priceInfo['NumeroCriancas'] ?? 0;
        }

        adultPrice =
            adultPrice is int ? adultPrice.toDouble() : adultPrice as double;
        childPrice =
            childPrice is int ? childPrice.toDouble() : childPrice as double;
        boardingFeeRate =
            boardingFeeRate is int
                ? boardingFeeRate.toDouble()
                : boardingFeeRate as double;

        returnPrice = (adultPrice * adultCount) + (childPrice * childCount);
        returnFee = boardingFeeRate * (adultCount + childCount);
      }
    }

    final totalPrice = outboundPrice + returnPrice;
    final totalFee = outboundFee + returnFee;
    final grandTotal = totalPrice + totalFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Tarifa: $selectedFareType',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Taxa: ${PriceFormatter.formatValue(totalFee, showMiles)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total da Viagem:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  Text(
                    'Tarifas + taxas de embarque',
                    style: TextStyle(fontSize: 12, color: textSecondaryColor),
                  ),
                ],
              ),
              Text(
                PriceFormatter.formatValue(grandTotal, showMiles),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: priceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continuar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
