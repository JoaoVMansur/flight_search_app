import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/flight_model.dart';
import '../../utils/date_formatter.dart';
import '../../utils/price_formatter.dart';
import 'connection_preview.dart';
import 'flight_info_row.dart';
import 'connection_detail.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  final bool isOutbound;
  final bool isSelected;
  final String selectedFareType;
  final bool showMiles;
  final Function() onSelect;
  final Function() onDeselect;
  final Map<String, Color> airlineColors;
  final Color primaryColor;
  final Color accentColor;
  final Color selectedCardColor;
  final Color priceColor;
  final Color cardColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;

  const FlightCard({
    Key? key,
    required this.flight,
    required this.isOutbound,
    required this.isSelected,
    required this.selectedFareType,
    required this.showMiles,
    required this.onSelect,
    required this.onDeselect,
    required this.airlineColors,
    required this.primaryColor,
    required this.accentColor,
    required this.selectedCardColor,
    required this.priceColor,
    required this.cardColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final companhia = flight.companhia;
    final origem = flight.origem;
    final destino = flight.destino;
    final numeroConexoes = flight.numeroConexoes;
    final duracao = flight.duracao;

    final embarqueDateTime = DateFormatter.parseDateTime(flight.embarque);
    final desembarqueDateTime = DateFormatter.parseDateTime(flight.desembarque);

    final priceInfo = flight.getPriceInfo(selectedFareType, showMiles);
    final totalPrice = flight.calculateTotalPrice(selectedFareType, showMiles);

    final Map<String, dynamic> bagagemDespachada = flight.getBaggageInfo(
      selectedFareType,
      showMiles,
      false,
    );
    final Map<String, dynamic> bagagemMao = flight.getBaggageInfo(
      selectedFareType,
      showMiles,
      true,
    );

    num boardingFee = priceInfo['TaxaEmbarque'] ?? 0.0;
    boardingFee =
        boardingFee is int ? boardingFee.toDouble() : boardingFee as double;

    final Color airlineColor = airlineColors[companhia] ?? primaryColor;

    return GestureDetector(
      onTap: isSelected ? onDeselect : onSelect,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isSelected
                  ? BorderSide(color: primaryColor, width: 2)
                  : BorderSide.none,
        ),
        color: isSelected ? selectedCardColor : cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: airlineColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      companhia,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Voo: ${flight.numeroVoo}',
                    style: TextStyle(color: textSecondaryColor),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      DateFormatter.formatDuration(duracao),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(embarqueDateTime),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            origem,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(embarqueDateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          numeroConexoes > 0
                              ? Icons.flight_takeoff
                              : Icons.arrow_forward,
                          color: accentColor,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          numeroConexoes > 0
                              ? '$numeroConexoes ${numeroConexoes == 1 ? 'conexão' : 'conexões'}'
                              : 'Direto',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(desembarqueDateTime),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            destino,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(desembarqueDateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (numeroConexoes > 0 && flight.conexoes != null) ...[
                const SizedBox(height: 12),
                ConnectionPreview(
                  conexoes: flight.conexoes!,
                  accentColor: accentColor,
                ),
              ],

              Divider(height: 32, thickness: 1, color: Colors.grey.shade200),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preço Total - $selectedFareType',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Taxa de embarque: ${PriceFormatter.formatValue(boardingFee, showMiles)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.luggage,
                            size: 16,
                            color: textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Despacho: ${PriceFormatter.formatBagagem(bagagemDespachada)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.backpack,
                            size: 16,
                            color: textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mão: ${PriceFormatter.formatBagagem(bagagemMao)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    PriceFormatter.formatValue(totalPrice, showMiles),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: priceColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (isSelected) ...[
                Divider(height: 24, thickness: 1, color: Colors.grey.shade200),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Detalhes do Voo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (flight.aeronave != null) ...[
                  FlightInfoRow(
                    icon: Icons.airplanemode_active,
                    label: 'Aeronave:',
                    value: flight.aeronave!,
                    textPrimaryColor: textPrimaryColor,
                    textSecondaryColor: textSecondaryColor,
                  ),
                  const SizedBox(height: 8),
                ],

                FlightInfoRow(
                  icon: Icons.class_,
                  label: 'Tipo de Tarifa:',
                  value: selectedFareType,
                  textPrimaryColor: textPrimaryColor,
                  textSecondaryColor: textSecondaryColor,
                ),
                const SizedBox(height: 8),

                FlightInfoRow(
                  icon: Icons.luggage,
                  label: 'Bagagem Despachada:',
                  value: PriceFormatter.formatBagagem(bagagemDespachada),
                  textPrimaryColor: textPrimaryColor,
                  textSecondaryColor: textSecondaryColor,
                ),
                const SizedBox(height: 8),
                FlightInfoRow(
                  icon: Icons.backpack,
                  label: 'Bagagem de Mão:',
                  value: PriceFormatter.formatBagagem(bagagemMao),
                  textPrimaryColor: textPrimaryColor,
                  textSecondaryColor: textSecondaryColor,
                ),
                const SizedBox(height: 16),

                if (numeroConexoes > 0 && flight.conexoes != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações de Conexões',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          flight.conexoes!.length,
                          (index) => ConnectionDetail(
                            connection: flight.conexoes![index],
                            index: index,
                            total: flight.conexoes!.length,
                            accentColor: accentColor,
                            textSecondaryColor: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildPriceBreakdown(
                  priceInfo: priceInfo,
                  flight: flight,
                  showMiles: showMiles,
                  priceColor: priceColor,
                  textPrimaryColor: textPrimaryColor,
                  textSecondaryColor: textSecondaryColor,
                ),
                const SizedBox(height: 16),

                Center(
                  child: OutlinedButton(
                    onPressed: onDeselect,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar Seleção',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else
                Center(
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Selecionar ${isOutbound ? 'Ida' : 'Volta'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.visibility, size: 16),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown({
    required Map<String, dynamic> priceInfo,
    required Flight flight,
    required bool showMiles,
    required Color priceColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
  }) {
    num adultPrice = priceInfo['Adulto'] ?? 0.0;
    num childPrice = priceInfo['Crianca'] ?? 0.0;
    num boardingFee = priceInfo['TaxaEmbarque'] ?? 0.0;

    int adultCount = 1;
    int childCount = 0;
    int infantCount = 0;

    if (flight.passageiros != null) {
      adultCount = flight.passageiros!['Adultos'] ?? 1;
      childCount = flight.passageiros!['Criancas'] ?? 0;
      infantCount = flight.passageiros!['Bebes'] ?? 0;
    } else if (priceInfo.containsKey('NumeroAdultos') ||
        priceInfo.containsKey('NumeroCriancas')) {
      adultCount = priceInfo['NumeroAdultos'] ?? 1;
      childCount = priceInfo['NumeroCriancas'] ?? 0;
      infantCount = priceInfo['NumeroBebes'] ?? 0;
    }

    adultPrice =
        adultPrice is int ? adultPrice.toDouble() : adultPrice as double;
    childPrice =
        childPrice is int ? childPrice.toDouble() : childPrice as double;
    boardingFee =
        boardingFee is int ? boardingFee.toDouble() : boardingFee as double;

    final fareTotal = (adultPrice * adultCount) + (childPrice * childCount);

    final totalBoardingFee = boardingFee * (adultCount + childCount);

    final totalPrice = fareTotal + totalBoardingFee;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priceColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priceColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhamento de Preço',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: priceColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Passageiros: $adultCount adulto(s)${childCount > 0 ? ', $childCount criança(s)' : ''}${infantCount > 0 ? ', $infantCount bebê(s)' : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tarifa Adulto${adultCount > 1 ? ' (x$adultCount)' : ''}:',
                style: TextStyle(color: textSecondaryColor),
              ),
              Text(
                PriceFormatter.formatValue(adultPrice * adultCount, showMiles),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
            ],
          ),

          if (childCount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarifa Criança${childCount > 1 ? ' (x$childCount)' : ''}:',
                  style: TextStyle(color: textSecondaryColor),
                ),
                Text(
                  PriceFormatter.formatValue(
                    childPrice * childCount,
                    showMiles,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa de embarque (${adultCount + childCount} pax):',
                style: TextStyle(color: textSecondaryColor),
              ),
              Text(
                PriceFormatter.formatValue(totalBoardingFee, showMiles),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
            ],
          ),

          if (infantCount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bebês não pagam tarifa ou taxa',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
                const Icon(Icons.child_friendly, size: 16),
              ],
            ),
          ],

          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                PriceFormatter.formatValue(totalPrice, showMiles),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: priceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
