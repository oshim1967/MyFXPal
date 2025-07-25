import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json';

  Future<List<dynamic>> getExchangeRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Failed to load exchange rates: $e');
    }
  }
}
