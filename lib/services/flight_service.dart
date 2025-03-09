import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_request_model.dart';
import '../models/flight_model.dart';

class FlightService {
  static const String baseUrl = 'https://buscamilhas.mock.gralmeidan.dev';

  Future<List<String>> fetchAirports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/aeroportos'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> airports = [];

        for (var airport in data) {
          String airportStr = "${airport['Iata']} - ${airport['Nome']}";
          airports.add(airportStr);
        }

        return airports;
      } else {
        throw Exception('Failed to load airports');
      }
    } catch (e) {
      throw Exception('Error fetching airports: $e');
    }
  }

  Future<String> createSearchRequest(SearchRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/busca/criar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final searchId = json.decode(response.body)['Busca'];
        return searchId;
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? response.body;
        throw Exception('Error creating search: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error sending search request: $e');
    }
  }

  Future<Map<String, dynamic>> fetchSearchResults(
    String searchId,
    Map<String, dynamic> passageirosInfo,
  ) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/busca/$searchId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> searchResults = json.decode(response.body);

        if (searchResults.containsKey('Voos')) {
          List<dynamic> flights = searchResults['Voos'];
          for (var flight in flights) {
            if (!flight.containsKey('Passageiros')) {
              flight['Passageiros'] = passageirosInfo;
            }
          }
        }

        return searchResults;
      } else {
        final errorMessage =
            json.decode(response.body)['message'] ?? response.body;
        throw Exception('Error fetching results: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error fetching search results: $e');
    }
  }

  List<Flight> parseFlights(Map<String, dynamic> searchResults) {
    final List<Flight> flights = [];

    if (searchResults.containsKey('Voos')) {
      final flightsList = searchResults['Voos'] as List<dynamic>;

      for (var flightJson in flightsList) {
        flights.add(Flight.fromJson(flightJson));
      }
    }

    return flights;
  }
}
