import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchResultsScreen extends StatefulWidget {
  final Map<String, dynamic> searchResults;

  const SearchResultsScreen({Key? key, required this.searchResults})
    : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _selectedSortOption = 'Preço';
  bool _showMiles = false; // Using boolean for toggle instead of dropdown
  String _selectedFareType = 'Start'; // Default fare type

  // App theme colors
  final Color _primaryColor = const Color(0xFF1976D2); // A deep blue as primary
  final Color _accentColor = const Color(0xFFFF9800); // Orange as accent
  final Color _backgroundColor = const Color(
    0xFFF5F5F5,
  ); // Light gray background
  final Color _cardColor = Colors.white;
  final Color _selectedCardColor = const Color(
    0xFFE3F2FD,
  ); // Light blue for selected card
  final Color _priceColor = const Color(0xFF4CAF50); // Green for prices
  final Color _textPrimaryColor = const Color(
    0xFF212121,
  ); // Dark gray for main text
  final Color _textSecondaryColor = const Color(
    0xFF757575,
  ); // Medium gray for secondary text

  final Map<String, Color> _airlineColors = {
    'AMERICAN AIRLINES': Colors.red.shade700,
    'GOL': Colors.orange.shade700,
    'LATAM': Colors.blue.shade700,
    'AZUL': Colors.blue.shade500,
    'TAP': Colors.green.shade600,
    'IBERIA': Colors.purple.shade600,
    'INTERLINE': Colors.indigo.shade600,
  };

  // Selected flight IDs for outbound and return
  String? _selectedOutboundFlightId;
  String? _selectedReturnFlightId;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> outboundFlights = [];
    final List<Map<String, dynamic>> returnFlights = [];

    // Separate outbound and return flights
    final allFlights = List<Map<String, dynamic>>.from(
      widget.searchResults['Voos'],
    );

    // Using "Sentido" field from API response to distinguish outbound from return
    for (var flight in allFlights) {
      // Make sure each flight has an Id for selection
      if (!flight.containsKey('Id')) {
        flight['Id'] = flight['NumeroVoo'] ?? '';
      }

      if (flight['Sentido'] == 'Ida') {
        outboundFlights.add(flight);
      } else if (flight['Sentido'] == 'Volta') {
        returnFlights.add(flight);
      }
    }

    // Apply sorting to both lists
    _sortFlights(outboundFlights);
    _sortFlights(returnFlights);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Resultados da Busca',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: _primaryColor,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          if (outboundFlights.isNotEmpty) ...[
            _buildSectionHeader('Voos de Ida'),
            Expanded(
              child: ListView.builder(
                itemCount: outboundFlights.length,
                itemBuilder: (context, index) {
                  final voo = outboundFlights[index];
                  return _buildFlightCard(
                    voo,
                    isOutbound: true,
                    isSelected: voo['Id'] == _selectedOutboundFlightId,
                  );
                },
              ),
            ),
          ],
          if (returnFlights.isNotEmpty) ...[
            _buildSectionHeader('Voos de Volta'),
            Expanded(
              child: ListView.builder(
                itemCount: returnFlights.length,
                itemBuilder: (context, index) {
                  final voo = returnFlights[index];
                  return _buildFlightCard(
                    voo,
                    isOutbound: false,
                    isSelected: voo['Id'] == _selectedReturnFlightId,
                  );
                },
              ),
            ),
          ],
          if (outboundFlights.isEmpty && returnFlights.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Nenhum voo encontrado',
                  style: TextStyle(color: _textPrimaryColor, fontSize: 16),
                ),
              ),
            ),
          if (_selectedOutboundFlightId != null ||
              _selectedReturnFlightId != null)
            _buildSummaryFooter(outboundFlights, returnFlights),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: _primaryColor.withOpacity(0.1),
      width: double.infinity,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: _cardColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Ordenar por',
                    labelStyle: TextStyle(color: _primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _primaryColor.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  value: _selectedSortOption,
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
                            style: TextStyle(color: _textPrimaryColor),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedSortOption = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Toggle switch for BRL/Miles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'BRL',
                      style: TextStyle(
                        fontWeight:
                            _showMiles ? FontWeight.normal : FontWeight.bold,
                        color: _showMiles ? _textSecondaryColor : _primaryColor,
                      ),
                    ),
                    Switch(
                      value: _showMiles,
                      activeColor: _primaryColor,
                      activeTrackColor: _primaryColor.withOpacity(0.5),
                      inactiveThumbColor: _primaryColor,
                      inactiveTrackColor: _primaryColor.withOpacity(0.5),
                      onChanged: (value) {
                        setState(() {
                          _showMiles = value;
                        });
                      },
                    ),
                    Text(
                      'Milhas',
                      style: TextStyle(
                        fontWeight:
                            _showMiles ? FontWeight.bold : FontWeight.normal,
                        color: _showMiles ? _primaryColor : _textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dropdown for fare type
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipo de Tarifa',
              labelStyle: TextStyle(color: _primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            value: _selectedFareType,
            items:
                ['Start', 'Econômica', 'Executiva'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: _textPrimaryColor),
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFareType = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard(
    Map<String, dynamic> voo, {
    required bool isOutbound,
    required bool isSelected,
  }) {
    final companhia = voo['Companhia'];
    final origem = voo['Origem']; // This is already the IATA code
    final destino = voo['Destino']; // This is already the IATA code
    final embarque = voo['Embarque'];
    final desembarque = voo['Desembarque'];
    final duracao = voo['Duracao'];
    final numeroConexoes = voo['NumeroConexoes'];
    final flightId = voo['Id'] ?? voo['NumeroVoo'] ?? '';

    // Get prices based on selected type (BRL or Miles)
    final List<Map<String, dynamic>> allPrices =
        _showMiles
            ? List<Map<String, dynamic>>.from(voo['Milhas'])
            : List<Map<String, dynamic>>.from(voo['Valor']);

    // Find price info matching the selected fare type
    final Map<String, dynamic> priceInfo =
        allPrices.isNotEmpty
            ? allPrices.firstWhere(
              (price) =>
                  price['TipoValor'] == _selectedFareType ||
                  price['TipoMilhas'] == _selectedFareType,
              orElse: () => allPrices.first,
            )
            : {};

    // Get the total price and boarding fee with safer conversion and correct calculation
    num adultPrice = 0.0;
    num childPrice = 0.0;
    num boardingFee = 0.0;

    // Passenger counts (default to 1 adult if not specified)
    int adultCount = 1;
    int childCount = 0;
    int infantCount = 0;

    if (priceInfo.isNotEmpty) {
      // Get prices
      adultPrice = priceInfo['Adulto'] ?? 0.0;
      childPrice = priceInfo['Crianca'] ?? 0.0;
      boardingFee = priceInfo['TaxaEmbarque'] ?? 0.0;

      // Get passenger counts if available
      if (voo.containsKey('Passageiros')) {
        adultCount = voo['Passageiros']['Adultos'] ?? 1;
        childCount = voo['Passageiros']['Criancas'] ?? 0;
        infantCount = voo['Passageiros']['Bebes'] ?? 0;
      } else if (priceInfo.containsKey('NumeroAdultos') ||
          priceInfo.containsKey('NumeroCriancas')) {
        // Alternative location for passenger counts
        adultCount = priceInfo['NumeroAdultos'] ?? 1;
        childCount = priceInfo['NumeroCriancas'] ?? 0;
        infantCount = priceInfo['NumeroBebes'] ?? 0;
      }
    }

    // Calculate total price according to the formula:
    // Total = (Price Adult × Adult Qty) + (Price Child × Child Qty) + Boarding Fee × (Adults + Children)
    // Note: Babies don't pay fare or boarding fee

    // Convert to double for consistency
    adultPrice =
        adultPrice is int ? adultPrice.toDouble() : adultPrice as double;
    childPrice =
        childPrice is int ? childPrice.toDouble() : childPrice as double;
    boardingFee =
        boardingFee is int ? boardingFee.toDouble() : boardingFee as double;

    // Calculate fare portion (without boarding fee)
    final fareTotal = (adultPrice * adultCount) + (childPrice * childCount);

    // Calculate total boarding fee (adults and children only, not babies)
    final totalBoardingFee = boardingFee * (adultCount + childCount);

    // Total price is fare + boarding fee
    final totalPrice = fareTotal + totalBoardingFee;

    // Get baggage info
    final Map<String, dynamic> limiteBagagem =
        priceInfo.isNotEmpty
            ? Map<String, dynamic>.from(priceInfo['LimiteBagagem'] ?? {})
            : {};
    final Map<String, dynamic> bagagemDespachada =
        limiteBagagem.containsKey('BagagemDespachada')
            ? Map<String, dynamic>.from(
              limiteBagagem['BagagemDespachada'] ?? {},
            )
            : {};
    final Map<String, dynamic> bagagemMao =
        limiteBagagem.containsKey('BagagemMao')
            ? Map<String, dynamic>.from(limiteBagagem['BagagemMao'] ?? {})
            : {};

    // Format times
    final embarqueDateTime = _parseDateTime(embarque);
    final desembarqueDateTime = _parseDateTime(desembarque);

    final Color airlineColor = _airlineColors[companhia] ?? _primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isOutbound) {
            _selectedOutboundFlightId = isSelected ? null : flightId;
          } else {
            _selectedReturnFlightId = isSelected ? null : flightId;
          }
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isSelected
                  ? BorderSide(color: _primaryColor, width: 2)
                  : BorderSide.none,
        ),
        color: isSelected ? _selectedCardColor : _cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Airline and Flight Number
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
                    'Voo: ${voo['NumeroVoo']}',
                    style: TextStyle(color: _textSecondaryColor),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(duracao),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Route and time
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
                            color: _textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            origem,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(embarqueDateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondaryColor,
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
                          color: _accentColor,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          numeroConexoes > 0
                              ? '$numeroConexoes ${numeroConexoes == 1 ? 'conexão' : 'conexões'}'
                              : 'Direto',
                          style: TextStyle(
                            color: _accentColor,
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
                            color: _textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            destino,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(desembarqueDateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (numeroConexoes > 0) ...[
                const SizedBox(height: 12),
                _buildConnectionsPreview(voo['Conexoes']),
              ],

              Divider(height: 32, thickness: 1, color: Colors.grey.shade200),

              // Prices
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preço Total - ${_selectedFareType}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Taxa de embarque: ${_formatValue(boardingFee, _showMiles)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.luggage,
                            size: 16,
                            color: _textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Despacho: ${_formatBagagem(bagagemDespachada)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _textSecondaryColor,
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
                            color: _textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mão: ${_formatBagagem(bagagemMao)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    _formatValue(totalPrice, _showMiles),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _priceColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // Detailed flight information when selected
              if (isSelected) ...[
                Divider(height: 24, thickness: 1, color: Colors.grey.shade200),

                // Detailed flight section title
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Detalhes do Voo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Aircraft info if available
                if (voo.containsKey('Aeronave') && voo['Aeronave'] != null) ...[
                  _buildInfoRow(
                    Icons.airplanemode_active,
                    'Aeronave:',
                    voo['Aeronave'].toString(),
                  ),
                  const SizedBox(height: 8),
                ],

                // Fare type details
                _buildInfoRow(
                  Icons.class_,
                  'Tipo de Tarifa:',
                  _selectedFareType,
                ),
                const SizedBox(height: 8),

                // Detailed baggage information
                _buildInfoRow(
                  Icons.luggage,
                  'Bagagem Despachada:',
                  _formatBagagem(bagagemDespachada),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.backpack,
                  'Bagagem de Mão:',
                  _formatBagagem(bagagemMao),
                ),
                const SizedBox(height: 16),

                // Detailed connection information
                if (numeroConexoes > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações de Conexões',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          voo['Conexoes'].length,
                          (index) => _buildConnectionDetail(
                            voo['Conexoes'][index],
                            index,
                            voo['Conexoes'].length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Price breakdown
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _priceColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _priceColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhamento de Preço',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _priceColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Passenger counts
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Passageiros: ${adultCount} adulto(s)${childCount > 0 ? ', ${childCount} criança(s)' : ''}${infantCount > 0 ? ', ${infantCount} bebê(s)' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      // Adult fare
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tarifa Adulto${adultCount > 1 ? ' (x$adultCount)' : ''}:',
                            style: TextStyle(color: _textSecondaryColor),
                          ),
                          Text(
                            _formatValue(adultPrice * adultCount, _showMiles),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _textPrimaryColor,
                            ),
                          ),
                        ],
                      ),

                      // Child fare, if applicable
                      if (childCount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tarifa Criança${childCount > 1 ? ' (x$childCount)' : ''}:',
                              style: TextStyle(color: _textSecondaryColor),
                            ),
                            Text(
                              _formatValue(childPrice * childCount, _showMiles),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Boarding fee
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Taxa de embarque (${adultCount + childCount} pax):',
                            style: TextStyle(color: _textSecondaryColor),
                          ),
                          Text(
                            _formatValue(totalBoardingFee, _showMiles),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _textPrimaryColor,
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
                                color: _textSecondaryColor,
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
                            _formatValue(totalPrice, _showMiles),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _priceColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Unselect button
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        if (isOutbound) {
                          _selectedOutboundFlightId = null;
                        } else {
                          _selectedReturnFlightId = null;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      side: BorderSide(color: _primaryColor),
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
                    onPressed: () {
                      setState(() {
                        if (isOutbound) {
                          _selectedOutboundFlightId = flightId;
                        } else {
                          _selectedReturnFlightId = flightId;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
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

  Widget _buildConnectionsPreview(List<dynamic> conexoes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, size: 18, color: _accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              conexoes
                  .map((c) => '${c['Origem']} → ${c['Destino']}')
                  .join(' | '),
              style: TextStyle(
                fontSize: 13,
                color: _accentColor,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse date/time string from API
  DateTime _parseDateTime(String dateTimeStr) {
    final parts = dateTimeStr.split(' ');
    final dateParts = parts[0].split('/');
    // Convert from d/M/yyyy format to yyyy-MM-dd format for DateTime.parse
    final formattedDate =
        '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';
    return DateTime.parse('$formattedDate ${parts[1]}:00');
  }

  // New method for the summary footer
  Widget _buildSummaryFooter(
    List<Map<String, dynamic>> outboundFlights,
    List<Map<String, dynamic>> returnFlights,
  ) {
    double outboundPrice = 0;
    double outboundFee = 0;
    double returnPrice = 0;
    double returnFee = 0;

    // Calculate outbound price if selected
    if (_selectedOutboundFlightId != null) {
      final selectedOutbound = outboundFlights.firstWhere(
        (flight) => flight['Id'] == _selectedOutboundFlightId,
        orElse: () => {},
      );
      if (selectedOutbound.isNotEmpty) {
        final allPrices =
            _showMiles
                ? List<Map<String, dynamic>>.from(selectedOutbound['Milhas'])
                : List<Map<String, dynamic>>.from(selectedOutbound['Valor']);

        if (allPrices.isNotEmpty) {
          final priceInfo = allPrices.firstWhere(
            (price) =>
                price['TipoValor'] == _selectedFareType ||
                price['TipoMilhas'] == _selectedFareType,
            orElse: () => allPrices.first,
          );

          // Get price values
          num adultPrice = priceInfo['Adulto'] ?? 0.0;
          num childPrice = priceInfo['Crianca'] ?? 0.0;
          num boardingFeeRate = priceInfo['TaxaEmbarque'] ?? 0.0;

          // Get passenger counts
          int adultCount = 1;
          int childCount = 0;

          if (selectedOutbound.containsKey('Passageiros')) {
            adultCount = selectedOutbound['Passageiros']['Adultos'] ?? 1;
            childCount = selectedOutbound['Passageiros']['Criancas'] ?? 0;
          } else if (priceInfo.containsKey('NumeroAdultos') ||
              priceInfo.containsKey('NumeroCriancas')) {
            adultCount = priceInfo['NumeroAdultos'] ?? 1;
            childCount = priceInfo['NumeroCriancas'] ?? 0;
          }

          // Convert to double
          adultPrice =
              adultPrice is int ? adultPrice.toDouble() : adultPrice as double;
          childPrice =
              childPrice is int ? childPrice.toDouble() : childPrice as double;
          boardingFeeRate =
              boardingFeeRate is int
                  ? boardingFeeRate.toDouble()
                  : boardingFeeRate as double;

          // Calculate fare and fees
          final double farePortion =
              (adultPrice * adultCount) + (childPrice * childCount);
          outboundFee = boardingFeeRate * (adultCount + childCount);
          outboundPrice = farePortion;
        }
      }
    }

    // Calculate return price if selected
    if (_selectedReturnFlightId != null) {
      final selectedReturn = returnFlights.firstWhere(
        (flight) => flight['Id'] == _selectedReturnFlightId,
        orElse: () => {},
      );
      if (selectedReturn.isNotEmpty) {
        final allPrices =
            _showMiles
                ? List<Map<String, dynamic>>.from(selectedReturn['Milhas'])
                : List<Map<String, dynamic>>.from(selectedReturn['Valor']);

        if (allPrices.isNotEmpty) {
          final priceInfo = allPrices.firstWhere(
            (price) =>
                price['TipoValor'] == _selectedFareType ||
                price['TipoMilhas'] == _selectedFareType,
            orElse: () => allPrices.first,
          );

          // Get price values
          num adultPrice = priceInfo['Adulto'] ?? 0.0;
          num childPrice = priceInfo['Crianca'] ?? 0.0;
          num boardingFeeRate = priceInfo['TaxaEmbarque'] ?? 0.0;

          // Get passenger counts
          int adultCount = 1;
          int childCount = 0;

          if (selectedReturn.containsKey('Passageiros')) {
            adultCount = selectedReturn['Passageiros']['Adultos'] ?? 1;
            childCount = selectedReturn['Passageiros']['Criancas'] ?? 0;
          } else if (priceInfo.containsKey('NumeroAdultos') ||
              priceInfo.containsKey('NumeroCriancas')) {
            adultCount = priceInfo['NumeroAdultos'] ?? 1;
            childCount = priceInfo['NumeroCriancas'] ?? 0;
          }

          // Convert to double
          adultPrice =
              adultPrice is int ? adultPrice.toDouble() : adultPrice as double;
          childPrice =
              childPrice is int ? childPrice.toDouble() : childPrice as double;
          boardingFeeRate =
              boardingFeeRate is int
                  ? boardingFeeRate.toDouble()
                  : boardingFeeRate as double;

          // Calculate fare and fees
          final double farePortion =
              (adultPrice * adultCount) + (childPrice * childCount);
          returnFee = boardingFeeRate * (adultCount + childCount);
          returnPrice = farePortion;
        }
      }
    }

    final totalPrice = outboundPrice + returnPrice;
    final totalFee = outboundFee + returnFee;
    final grandTotal = totalPrice + totalFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
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
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Tarifa: ${_selectedFareType}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Taxa: ${_formatValue(totalFee, _showMiles)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
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
                      color: _textPrimaryColor,
                    ),
                  ),
                  Text(
                    'Tarifas + taxas de embarque',
                    style: TextStyle(fontSize: 12, color: _textSecondaryColor),
                  ),
                ],
              ),
              Text(
                _formatValue(grandTotal, _showMiles),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _priceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle proceed to checkout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
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

  String _formatDuration(String duration) {
    final parts = duration.split(':');
    return '${parts[0]}h ${parts[1]}min';
  }

  String _formatValue(num value, bool isMiles) {
    if (isMiles) {
      return '${NumberFormat("#,###").format(value.round())} milhas';
    } else {
      return 'R\$ ${NumberFormat("##0.00").format(value)}';
    }
  }

  String _formatBagagem(Map<String, dynamic> bagagem) {
    if (bagagem.isEmpty) return 'Não incluso';

    final entries = bagagem.entries.first;
    return '${entries.value}x ${entries.key}';
  }

  void _sortFlights(List<Map<String, dynamic>> voos) {
    switch (_selectedSortOption) {
      case 'Preço':
        voos.sort((a, b) {
          // Safely get price lists, handling potential null values
          List<Map<String, dynamic>> aValues = [];
          List<Map<String, dynamic>> bValues = [];

          try {
            if (_showMiles) {
              if (a.containsKey('Milhas') && a['Milhas'] != null) {
                aValues = List<Map<String, dynamic>>.from(a['Milhas']);
              }
              if (b.containsKey('Milhas') && b['Milhas'] != null) {
                bValues = List<Map<String, dynamic>>.from(b['Milhas']);
              }
            } else {
              if (a.containsKey('Valor') && a['Valor'] != null) {
                aValues = List<Map<String, dynamic>>.from(a['Valor']);
              }
              if (b.containsKey('Valor') && b['Valor'] != null) {
                bValues = List<Map<String, dynamic>>.from(b['Valor']);
              }
            }
          } catch (e) {
            // If any error occurs during list conversion, return a default comparison
            return 0;
          }

          // Default price values
          num aPriceValue = 0;
          num bPriceValue = 0;

          // Get price for first flight
          if (aValues.isNotEmpty) {
            // Try to find matching fare type
            Map<String, dynamic>? aPriceInfo;
            try {
              aPriceInfo = aValues.firstWhere(
                (price) =>
                    (price['TipoValor'] == _selectedFareType) ||
                    (price['TipoMilhas'] == _selectedFareType),
                orElse: () => aValues.first,
              );
            } catch (e) {
              // If error finding price info, use first one if available
              aPriceInfo = aValues.isNotEmpty ? aValues.first : null;
            }

            if (aPriceInfo != null) {
              // Get all price components
              num adultPrice = aPriceInfo['Adulto'] ?? 0;
              num childPrice = aPriceInfo['Crianca'] ?? 0;
              num boardingFee = aPriceInfo['TaxaEmbarque'] ?? 0;

              // Get passenger counts
              int adultCount = 1;
              int childCount = 0;

              if (a.containsKey('Passageiros')) {
                adultCount = a['Passageiros']['Adultos'] ?? 1;
                childCount = a['Passageiros']['Criancas'] ?? 0;
              } else if (aPriceInfo.containsKey('NumeroAdultos') ||
                  aPriceInfo.containsKey('NumeroCriancas')) {
                adultCount = aPriceInfo['NumeroAdultos'] ?? 1;
                childCount = aPriceInfo['NumeroCriancas'] ?? 0;
              }

              // Calculate total price using the formula
              aPriceValue =
                  (adultPrice * adultCount) +
                  (childPrice * childCount) +
                  (boardingFee * (adultCount + childCount));
            }
          }

          // Get price for second flight
          if (bValues.isNotEmpty) {
            Map<String, dynamic>? bPriceInfo;
            try {
              bPriceInfo = bValues.firstWhere(
                (price) =>
                    (price['TipoValor'] == _selectedFareType) ||
                    (price['TipoMilhas'] == _selectedFareType),
                orElse: () => bValues.first,
              );
            } catch (e) {
              bPriceInfo = bValues.isNotEmpty ? bValues.first : null;
            }

            if (bPriceInfo != null) {
              // Get all price components
              num adultPrice = bPriceInfo['Adulto'] ?? 0;
              num childPrice = bPriceInfo['Crianca'] ?? 0;
              num boardingFee = bPriceInfo['TaxaEmbarque'] ?? 0;

              // Get passenger counts
              int adultCount = 1;
              int childCount = 0;

              if (b.containsKey('Passageiros')) {
                adultCount = b['Passageiros']['Adultos'] ?? 1;
                childCount = b['Passageiros']['Criancas'] ?? 0;
              } else if (bPriceInfo.containsKey('NumeroAdultos') ||
                  bPriceInfo.containsKey('NumeroCriancas')) {
                adultCount = bPriceInfo['NumeroAdultos'] ?? 1;
                childCount = bPriceInfo['NumeroCriancas'] ?? 0;
              }

              // Calculate total price using the formula
              bPriceValue =
                  (adultPrice * adultCount) +
                  (childPrice * childCount) +
                  (boardingFee * (adultCount + childCount));
            }
          }

          // Compare prices
          return aPriceValue.compareTo(bPriceValue);
        });
        break;

      case 'Duração':
        voos.sort((a, b) {
          final aDuration = _parseDuration(a['Duracao']);
          final bDuration = _parseDuration(b['Duracao']);
          return aDuration.compareTo(bDuration);
        });
        break;

      case 'Horário de partida':
        voos.sort((a, b) {
          final aEmbarque = _parseDateTime(a['Embarque']);
          final bEmbarque = _parseDateTime(b['Embarque']);
          return aEmbarque.compareTo(bEmbarque);
        });
        break;

      case 'Horário de chegada':
        voos.sort((a, b) {
          final aDesembarque = _parseDateTime(a['Desembarque']);
          final bDesembarque = _parseDateTime(b['Desembarque']);
          return aDesembarque.compareTo(bDesembarque);
        });
        break;
    }
  }

  int _parseDuration(String duration) {
    final parts = duration.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _textSecondaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textPrimaryColor,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: _textSecondaryColor, fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionDetail(
    Map<String, dynamic> connection,
    int index,
    int total,
  ) {
    // Format times from the connection object
    final embarque = connection['EmbarqueCompleto'] ?? connection['Embarque'];
    final desembarque =
        connection['DesembarqueCompleto'] ?? connection['Desembarque'];

    late DateTime embarqueDateTime;
    late DateTime desembarqueDateTime;

    try {
      embarqueDateTime = _parseDateTime(embarque);
      desembarqueDateTime = _parseDateTime(desembarque);
    } catch (e) {
      embarqueDateTime = DateTime.now();
      desembarqueDateTime = DateTime.now();
    }

    final duracao = connection['Duracao'] ?? '00:00';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${connection['Origem']} → ${connection['Destino']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'Voo: ${connection['NumeroVoo'] ?? 'N/A'}',
                style: TextStyle(color: _textSecondaryColor, fontSize: 12),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Partida: ${DateFormat('HH:mm').format(embarqueDateTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondaryColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Duração: ${_formatDuration(duracao)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Chegada: ${DateFormat('HH:mm').format(desembarqueDateTime)}',
                  style: TextStyle(fontSize: 12, color: _textSecondaryColor),
                ),
                if (index < total - 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tempo de conexão: ${_calculateConnectionTime(desembarqueDateTime, index + 1 < total ? _parseDateTime(connection['EmbarqueCompleto'] ?? connection['Embarque']) : null)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _accentColor,
                    ),
                  ),
                  const Divider(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateConnectionTime(DateTime arrival, DateTime? nextDeparture) {
    if (nextDeparture == null) return '';

    final difference = nextDeparture.difference(arrival);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return '$hours h $minutes min';
  }
}
