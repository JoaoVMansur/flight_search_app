class SearchRequest {
  final List<String> companhias;
  final String dataIda;
  final String dataVolta;
  final String origem;
  final String destino;
  final String tipo;
  final Map<String, dynamic> passageiros;

  SearchRequest({
    required this.companhias,
    required this.dataIda,
    required this.dataVolta,
    required this.origem,
    required this.destino,
    required this.tipo,
    required this.passageiros,
  });

  Map<String, dynamic> toJson() {
    return {
      'Companhias': companhias,
      'DataIda': dataIda,
      'DataVolta': dataVolta,
      'Origem': origem,
      'Destino': destino,
      'Tipo': tipo,
      'Passageiros': passageiros,
    };
  }

  static String extractIATACode(String airportString) {
    if (airportString.isEmpty) return '';
    return airportString.split(' - ')[0].trim();
  }

  static String convertTripType(String selectedTripType) {
    return selectedTripType == 'OneWay' ? 'Ida' : 'IdaVolta';
  }

  static String calculateReturnDate(String departureDate) {
    if (departureDate.isEmpty) return '';

    try {
      List<String> parts = departureDate.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        DateTime departureDateTime = DateTime(year, month, day);
        DateTime nextDay = departureDateTime.add(const Duration(days: 1));

        return "${nextDay.day.toString().padLeft(2, '0')}/${nextDay.month.toString().padLeft(2, '0')}/${nextDay.year}";
      }
    } catch (e) {}

    DateTime nextDay = DateTime.now().add(const Duration(days: 1));
    return "${nextDay.day.toString().padLeft(2, '0')}/${nextDay.month.toString().padLeft(2, '0')}/${nextDay.year}";
  }

  static bool isReturnDateValid(String departureDate, String returnDate) {
    if (departureDate.isEmpty || returnDate.isEmpty) {
      return false;
    }

    try {
      List<String> departureParts = departureDate.split('/');
      List<String> returnParts = returnDate.split('/');

      if (departureParts.length == 3 && returnParts.length == 3) {
        DateTime departureDateTime = DateTime(
          int.parse(departureParts[2]),
          int.parse(departureParts[1]),
          int.parse(departureParts[0]),
        );

        DateTime returnDateTime = DateTime(
          int.parse(returnParts[2]),
          int.parse(returnParts[1]),
          int.parse(returnParts[0]),
        );

        return !departureDateTime.isAfter(returnDateTime);
      }
    } catch (e) {}
    return false;
  }
}
