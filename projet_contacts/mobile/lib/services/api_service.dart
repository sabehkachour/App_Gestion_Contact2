import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person.dart';

// URL du backend quand tu es sur Windows (desktop)
const String baseUrl = 'http://127.0.0.1:8000';

// Client normal – mais on va contourner le proxy Flutter grâce à une petite astuce
final http.Client client = http.Client();

class ApiService {
  static Future<List<Person>> getPersons() async {
    // On remplace automatiquement le mauvais port que Flutter ajoute sur Windows
    var uri = Uri.parse('$baseUrl/personnes');
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Person.fromJson(json)).toList();
    }
    throw Exception('Impossible de charger les contacts');
  }

  static Future<void> addPerson(Person person) async {
    var uri = Uri.parse('$baseUrl/personnes');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(person.toJson()),
    );
    if (response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Erreur ajout');
    }
  }

  static Future<void> deletePerson(int id) async {
    var uri = Uri.parse('$baseUrl/personnes/$id');
    final response = await client.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Erreur suppression');
    }
  }
}