import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchFlightScreen extends StatefulWidget {
  @override
  _SearchFlightScreenState createState() => _SearchFlightScreenState();
}

class _SearchFlightScreenState extends State<SearchFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _departureController = TextEditingController();
  TextEditingController _arrivalController = TextEditingController();
  TextEditingController _departureDateController = TextEditingController();
  TextEditingController _returnDateController = TextEditingController();

  final List<String> _aeroportos = [];
  String? _selectedTripType = 'OneWay';
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  List<String> _selectedAirlines = [];

  // Define theme colors
  final Color primaryColor = Colors.blue.shade700;
  final Color accentColor = Colors.blue.shade500;
  final Color backgroundColor = Colors.grey.shade50;
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchAeroportos('');
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Implement form submission logic
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

  Future<void> _fetchAeroportos(String query) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/aeroportos'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        for (var aero in data) {
          String aeroportosStr = "${aero['Iata']} - ${aero['Nome']}";
          _aeroportos.add(aeroportosStr);
        }
      }
    } catch (e) {
      _showErrorMessage("Erro ao carregar aeroportos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Passagens Aéreas'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Trip type selection card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Tipo de Viagem"),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSelectionButton(
                          text: 'Somente Ida',
                          icon: Icons.flight_takeoff,
                          isSelected: _selectedTripType == 'OneWay',
                          onTap: () {
                            setState(() {
                              _selectedTripType = 'OneWay';
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildSelectionButton(
                          text: 'Ida e Volta',
                          icon: Icons.swap_horiz,
                          isSelected: _selectedTripType == 'RoundTrip',
                          onTap: () {
                            setState(() {
                              _selectedTripType = 'RoundTrip';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Route card (Departure and Arrival)
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Seu Itinerário"),
                  SizedBox(height: 12),
                  // Departure airport field
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textvalue) {
                      return _aeroportos.where(
                        (String value) => value.toLowerCase().contains(
                          textvalue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (String selectedValue) {
                      _departureController.text = selectedValue;
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
                          prefixIcon: Icon(
                            Icons.flight_takeoff,
                            color: accentColor,
                          ),
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

                  SizedBox(height: 16),

                  // Direction indicator
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

                  SizedBox(height: 16),

                  // Arrival airport field
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textvalue) {
                      return _aeroportos.where(
                        (String value) => value.toLowerCase().contains(
                          textvalue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (String selectedValue) {
                      _arrivalController.text = selectedValue;
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
                          prefixIcon: Icon(
                            Icons.flight_land,
                            color: accentColor,
                          ),
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
              ),
            ),

            SizedBox(height: 16),

            // Dates card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Datas"),
                  SizedBox(height: 12),
                  // Departure date field
                  TextFormField(
                    controller: _departureDateController,
                    decoration: InputDecoration(
                      labelText: 'Data de Ida',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: accentColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Selecione a data',
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione a data de ida';
                      }
                      return null;
                    },
                  ),

                  // Return date field (visible only if round-trip)
                  if (_selectedTripType == 'RoundTrip')
                    Column(
                      children: [
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _returnDateController,
                          decoration: InputDecoration(
                            labelText: 'Data de Volta',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: accentColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'Selecione a data',
                          ),
                          readOnly: true,
                          onTap: _selectReturnDate,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione a data de volta';
                            }
                            if (!checkReturn(
                              _departureDateController.text,
                              value,
                            )) {
                              return 'Data de volta deve ser posterior a ida';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Passengers card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Passageiros"),
                  SizedBox(height: 8),

                  // Adults
                  _buildPassengerCounter(
                    label: "Adultos",
                    count: _adults,
                    onIncrement: _incrementAdults,
                    onDecrement: _decrementAdults,
                    description: "Acima de 12 anos",
                  ),

                  Divider(height: 24),

                  // Children
                  _buildPassengerCounter(
                    label: "Crianças",
                    count: _children,
                    onIncrement: _incrementChildren,
                    onDecrement: _decrementChildren,
                    description: "2-12 anos",
                  ),

                  Divider(height: 24),

                  // Infants
                  _buildPassengerCounter(
                    label: "Bebês",
                    count: _infants,
                    onIncrement: _incrementInfants,
                    onDecrement: _decrementInfants,
                    description: "Menores de 2 anos",
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Airlines card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Companhias Aéreas"),
                  SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAirlineChip('AMERICAN AIRLINES'),
                      _buildAirlineChip('GOL'),
                      _buildAirlineChip('IBERIA'),
                      _buildAirlineChip('INTERLINE'),
                      _buildAirlineChip('LATAM'),
                      _buildAirlineChip('AZUL'),
                      _buildAirlineChip('TAP'),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Search button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: Text(
                'BUSCAR PASSAGENS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
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
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            SizedBox(width: 8),
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

  Widget _buildPassengerCounter({
    required String label,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required String description,
  }) {
    return Row(
      children: [
        // Label and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        // Counter
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: onDecrement,
                isEnabled: count > (label == "Adultos" ? 1 : 0),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onTap: onIncrement,
                isEnabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? accentColor : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildAirlineChip(String airline) {
    bool isSelected = _selectedAirlines.contains(airline);

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
        setState(() {
          if (selected) {
            _selectedAirlines.add(airline);
          } else {
            _selectedAirlines.remove(airline);
          }
        });
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
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
    if (_picked != null) {
      setState(() {
        _departureDateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectReturnDate() async {
    DateTime initialDate = DateTime.now();

    // If departure date is selected, set initial return date to day after
    if (_departureDateController.text.isNotEmpty) {
      try {
        DateTime departureDate = DateTime.parse(_departureDateController.text);
        initialDate = departureDate.add(Duration(days: 1));
      } catch (e) {
        // Use default initial date if parsing fails
      }
    }

    DateTime? _picked = await showDatePicker(
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
    if (_picked != null) {
      setState(() {
        _returnDateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  bool checkReturn(String ida, String volta) {
    if (ida.isEmpty || volta.isEmpty) {
      return false;
    }

    try {
      DateTime departureDate = DateTime.parse(ida);
      DateTime returnDate = DateTime.parse(volta);

      if (departureDate.isAfter(returnDate)) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
