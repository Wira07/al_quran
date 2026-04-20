import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ayat_model.dart';
import '../model/surah_model.dart';

class ApiService {
  static const String baseUrl = 'https://equran.id/api/v2';

  Future<List<Surah>> getSurah() async {
    final response = await http.get(Uri.parse('$baseUrl/surat'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List data = jsonData['data'];

      return data.map((e) => Surah.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load surah');
    }
  }

  Future<List<Ayat>> getDetailSurah(int nomor) async {
    final response = await http.get(
      Uri.parse('$baseUrl/surat/$nomor'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List data = jsonData['data']['ayat'];
      print(jsonData['data']['ayat'][0]);

      return data.map((e) => Ayat.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load detail surah');
    }
  }
}
