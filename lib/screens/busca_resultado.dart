import 'package:flutter/material.dart';
import '../models/flight_model.dart';
import '../utils/date_formatter.dart';
import '../widgets/results/filter_bar.dart';
import '../widgets/results/flight_card.dart';
import '../widgets/results/summary_footer.dart';

class SearchResultsScreen extends StatefulWidget {
  final Map<String, dynamic> searchResults;

  const SearchResultsScreen({Key? key, required this.searchResults})
    : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _selectedSortOption = 'Preço';
  bool _showMiles = false;
  String _selectedFareType = 'Start';

  final Color _primaryColor = const Color(0xFF1976D2);
  final Color _accentColor = const Color(0xFFFF9800);
  final Color _backgroundColor = const Color(0xFFF5F5F5);
  final Color _cardColor = Colors.white;
  final Color _selectedCardColor = const Color(0xFFE3F2FD);
  final Color _priceColor = const Color(0xFF4CAF50);
  final Color _textPrimaryColor = const Color(0xFF212121);
  final Color _textSecondaryColor = const Color(0xFF757575);

  final Map<String, Color> _airlineColors = {
    'AMERICAN AIRLINES': Colors.red.shade700,
    'GOL': Colors.orange.shade700,
    'LATAM': Colors.blue.shade700,
    'AZUL': Colors.blue.shade500,
    'TAP': Colors.green.shade600,
    'IBERIA': Colors.purple.shade600,
    'INTERLINE': Colors.indigo.shade600,
  };

  String? _selectedOutboundFlightId;
  String? _selectedReturnFlightId;

  late List<Flight> outboundFlights;
  late List<Flight> returnFlights;

  @override
  void initState() {
    super.initState();
    _parseFlights();
  }

  void _parseFlights() {
    outboundFlights = [];
    returnFlights = [];

    final allFlightsJson = List<Map<String, dynamic>>.from(
      widget.searchResults['Voos'] ?? [],
    );

    for (var flightJson in allFlightsJson) {
      final flight = Flight.fromJson(flightJson);

      if (flight.sentido == 'Ida') {
        outboundFlights.add(flight);
      } else if (flight.sentido == 'Volta') {
        returnFlights.add(flight);
      }
    }

    _sortFlights(outboundFlights);
    _sortFlights(returnFlights);
  }

  void _sortFlights(List<Flight> flights) {
    switch (_selectedSortOption) {
      case 'Preço':
        flights.sort((a, b) {
          final aPrice = a.calculateTotalPrice(_selectedFareType, _showMiles);
          final bPrice = b.calculateTotalPrice(_selectedFareType, _showMiles);
          return aPrice.compareTo(bPrice);
        });
        break;

      case 'Duração':
        flights.sort((a, b) {
          final aDuration = DateFormatter.parseDurationToMinutes(a.duracao);
          final bDuration = DateFormatter.parseDurationToMinutes(b.duracao);
          return aDuration.compareTo(bDuration);
        });
        break;

      case 'Horário de partida':
        flights.sort((a, b) {
          final aEmbarque = DateFormatter.parseDateTime(a.embarque);
          final bEmbarque = DateFormatter.parseDateTime(b.embarque);
          return aEmbarque.compareTo(bEmbarque);
        });
        break;

      case 'Horário de chegada':
        flights.sort((a, b) {
          final aDesembarque = DateFormatter.parseDateTime(a.desembarque);
          final bDesembarque = DateFormatter.parseDateTime(b.desembarque);
          return aDesembarque.compareTo(bDesembarque);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Resultados da Busca',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          FilterBar(
            selectedSortOption: _selectedSortOption,
            selectedFareType: _selectedFareType,
            showMiles: _showMiles,
            onSortOptionChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSortOption = value;
                  _sortFlights(outboundFlights);
                  _sortFlights(returnFlights);
                });
              }
            },
            onFareTypeChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedFareType = value;
                });
              }
            },
            onShowMilesChanged: (value) {
              setState(() {
                _showMiles = value;
              });
            },
            primaryColor: _primaryColor,
          ),

          if (outboundFlights.isNotEmpty) ...[
            _buildSectionHeader('Voos de Ida'),
            Expanded(
              child: ListView.builder(
                itemCount: outboundFlights.length,
                itemBuilder: (context, index) {
                  final flight = outboundFlights[index];
                  final isSelected = flight.id == _selectedOutboundFlightId;

                  return FlightCard(
                    flight: flight,
                    isOutbound: true,
                    isSelected: isSelected,
                    selectedFareType: _selectedFareType,
                    showMiles: _showMiles,
                    onSelect: () {
                      setState(() {
                        _selectedOutboundFlightId = flight.id;
                      });
                    },
                    onDeselect: () {
                      setState(() {
                        _selectedOutboundFlightId = null;
                      });
                    },
                    airlineColors: _airlineColors,
                    primaryColor: _primaryColor,
                    accentColor: _accentColor,
                    selectedCardColor: _selectedCardColor,
                    priceColor: _priceColor,
                    cardColor: _cardColor,
                    textPrimaryColor: _textPrimaryColor,
                    textSecondaryColor: _textSecondaryColor,
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
                  final flight = returnFlights[index];
                  final isSelected = flight.id == _selectedReturnFlightId;

                  return FlightCard(
                    flight: flight,
                    isOutbound: false,
                    isSelected: isSelected,
                    selectedFareType: _selectedFareType,
                    showMiles: _showMiles,
                    onSelect: () {
                      setState(() {
                        _selectedReturnFlightId = flight.id;
                      });
                    },
                    onDeselect: () {
                      setState(() {
                        _selectedReturnFlightId = null;
                      });
                    },
                    airlineColors: _airlineColors,
                    primaryColor: _primaryColor,
                    accentColor: _accentColor,
                    selectedCardColor: _selectedCardColor,
                    priceColor: _priceColor,
                    cardColor: _cardColor,
                    textPrimaryColor: _textPrimaryColor,
                    textSecondaryColor: _textSecondaryColor,
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
            _buildSummaryFooter(),
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

  Widget _buildSummaryFooter() {
    Flight? selectedOutboundFlight;
    Flight? selectedReturnFlight;

    if (_selectedOutboundFlightId != null) {
      try {
        selectedOutboundFlight = outboundFlights.firstWhere(
          (flight) => flight.id == _selectedOutboundFlightId,
        );
      } catch (e) {}
    }

    if (_selectedReturnFlightId != null) {
      try {
        selectedReturnFlight = returnFlights.firstWhere(
          (flight) => flight.id == _selectedReturnFlightId,
        );
      } catch (e) {}
    }

    return SummaryFooter(
      selectedOutboundFlight: selectedOutboundFlight,
      selectedReturnFlight: selectedReturnFlight,
      selectedFareType: _selectedFareType,
      showMiles: _showMiles,
      primaryColor: _primaryColor,
      accentColor: _accentColor,
      priceColor: _priceColor,
      textPrimaryColor: _textPrimaryColor,
      textSecondaryColor: _textSecondaryColor,
      onContinue: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Continuando para o pagamento...'),
            backgroundColor: _primaryColor,
          ),
        );
      },
    );
  }
}
