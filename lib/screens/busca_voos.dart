import 'package:flutter/material.dart';
import '../models/search_request_model.dart';
import '../services/flight_service.dart';
import '../widgets/search/trip_type_selector.dart';
import '../widgets/search/airport_selector.dart';
import '../widgets/search/date_selector.dart';
import '../widgets/search/passenger_counter.dart';
import '../widgets/search/airline_selector.dart';
import '../widgets/search/search_form_card.dart';
import 'busca_resultado.dart';

class SearchFlightScreen extends StatefulWidget {
  const SearchFlightScreen({Key? key}) : super(key: key);

  @override
  _SearchFlightScreenState createState() => _SearchFlightScreenState();
}

class _SearchFlightScreenState extends State<SearchFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final FlightService _flightService = FlightService();

  final List<String> _airports = [];
  String _selectedTripType = 'OneWay';
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  List<String> _selectedAirlines = [];
  bool _isLoading = false;

  final Color primaryColor = Colors.blue.shade700;
  final Color accentColor = Colors.blue.shade500;
  final Color backgroundColor = Colors.grey.shade50;
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchAirports();
  }

  Future<void> _fetchAirports() async {
    try {
      final airports = await _flightService.fetchAirports();
      setState(() {
        _airports.addAll(airports);
      });
    } catch (e) {
      _showErrorMessage("Erro ao carregar aeroportos: $e");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLoadingMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isLoading = true;
        });

        final origem = SearchRequest.extractIATACode(_departureController.text);
        final destino = SearchRequest.extractIATACode(_arrivalController.text);

        final tipo = SearchRequest.convertTripType(_selectedTripType);

        final dataIda = _departureDateController.text;

        String dataVolta;
        if (_returnDateController.text.isNotEmpty) {
          dataVolta = _returnDateController.text;
        } else {
          dataVolta = SearchRequest.calculateReturnDate(dataIda);
        }

        final passageiros = {
          "Adultos": _adults,
          "Criancas": _children,
          "Bebes": _infants,
        };

        final request = SearchRequest(
          companhias:
              _selectedAirlines.isEmpty
                  ? [
                    "AMERICAN AIRLINES",
                    "GOL",
                    "IBERIA",
                    "INTERLINE",
                    "LATAM",
                    "AZUL",
                    "TAP",
                  ]
                  : _selectedAirlines,
          dataIda: dataIda,
          dataVolta: dataVolta,
          origem: origem,
          destino: destino,
          tipo: tipo,
          passageiros: passageiros,
        );

        _showLoadingMessage('Buscando resultados...');

        final searchId = await _flightService.createSearchRequest(request);

        final searchResults = await _flightService.fetchSearchResults(
          searchId,
          passageiros,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      SearchResultsScreen(searchResults: searchResults),
            ),
          );
        }
      } catch (e) {
        _showErrorMessage("Erro: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _incrementAdults() {
    if (_adults + _children + _infants < 9) {
      setState(() {
        _adults++;
      });
    } else {
      _showErrorMessage("O número total de passageiros não pode exceder 9.");
    }
  }

  void _decrementAdults() {
    setState(() {
      if (_adults > 1) _adults--;
    });
  }

  void _incrementChildren() {
    if (_adults + _children + _infants < 9) {
      setState(() {
        _children++;
      });
    } else {
      _showErrorMessage("O número total de passageiros não pode exceder 9.");
    }
  }

  void _decrementChildren() {
    setState(() {
      if (_children > 0) _children--;
    });
  }

  void _incrementInfants() {
    if (_infants < _adults) {
      if (_adults + _children + _infants < 9) {
        setState(() {
          _infants++;
        });
      } else {
        _showErrorMessage("O número total de passageiros não pode exceder 9.");
      }
    } else {
      _showErrorMessage(
        "O número de bebês não pode ser maior que o número de adultos.",
      );
    }
  }

  void _decrementInfants() {
    setState(() {
      if (_infants > 0) _infants--;
    });
  }

  Future<void> _selectDepartureDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _departureDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";

        if (_returnDateController.text.isNotEmpty &&
            !SearchRequest.isReturnDateValid(
              _departureDateController.text,
              _returnDateController.text,
            )) {
          _returnDateController.clear();
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    DateTime initialDate = DateTime.now();

    if (_departureDateController.text.isNotEmpty) {
      try {
        List<String> parts = _departureDateController.text.split('/');
        if (parts.length == 3) {
          DateTime departureDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          initialDate = departureDate.add(const Duration(days: 1));
        }
      } catch (e) {}
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _returnDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _onAirlineToggled(String airline, bool selected) {
    setState(() {
      if (selected) {
        _selectedAirlines.add(airline);
      } else {
        _selectedAirlines.remove(airline);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Passagens Aéreas'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SearchFormCard(
                  cardColor: cardColor,
                  child: TripTypeSelector(
                    selectedTripType: _selectedTripType,
                    onTripTypeChanged: (type) {
                      setState(() {
                        _selectedTripType = type;
                        if (type == 'OneWay') {
                          _returnDateController.clear();
                        }
                      });
                    },
                    accentColor: accentColor,
                  ),
                ),

                const SizedBox(height: 16),

                SearchFormCard(
                  cardColor: cardColor,
                  child: AirportSelector(
                    departureController: _departureController,
                    arrivalController: _arrivalController,
                    airports: _airports,
                    accentColor: accentColor,
                  ),
                ),

                const SizedBox(height: 16),

                SearchFormCard(
                  cardColor: cardColor,
                  child: DateSelector(
                    departureDateController: _departureDateController,
                    returnDateController: _returnDateController,
                    selectedTripType: _selectedTripType,
                    onSelectDepartureDate: _selectDepartureDate,
                    onSelectReturnDate: _selectReturnDate,
                    accentColor: accentColor,
                    primaryColor: primaryColor,
                  ),
                ),

                const SizedBox(height: 16),

                SearchFormCard(
                  cardColor: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Passageiros",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      PassengerCounter(
                        label: "Adultos",
                        description: "Acima de 12 anos",
                        count: _adults,
                        onIncrement: _incrementAdults,
                        onDecrement: _decrementAdults,
                        accentColor: accentColor,
                      ),

                      const Divider(height: 24),

                      PassengerCounter(
                        label: "Crianças",
                        description: "2-12 anos",
                        count: _children,
                        onIncrement: _incrementChildren,
                        onDecrement: _decrementChildren,
                        accentColor: accentColor,
                      ),

                      const Divider(height: 24),

                      PassengerCounter(
                        label: "Bebês",
                        description: "Menores de 2 anos",
                        count: _infants,
                        onIncrement: _incrementInfants,
                        onDecrement: _decrementInfants,
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SearchFormCard(
                  cardColor: cardColor,
                  child: AirlineSelector(
                    selectedAirlines: _selectedAirlines,
                    onAirlineToggled: _onAirlineToggled,
                    accentColor: accentColor,
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'BUSCAR PASSAGENS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),

            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _departureDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }
}
