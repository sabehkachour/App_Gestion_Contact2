import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person.dart';

// URL du backend (Windows / Desktop)
const String baseUrl = 'http://127.0.0.1:8000';

final http.Client client = http.Client();

class ApiService {
  // GET all persons
  static Future<List<Person>> getPersons() async {
    final uri = Uri.parse('$baseUrl/personnes');
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Person.fromJson(json)).toList();
    }
    throw Exception('Impossible de charger les contacts');
  }

  // POST new person
  static Future<void> addPerson(Person person) async {
    final uri = Uri.parse('$baseUrl/personnes');
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

  // DELETE a person
  static Future<void> deletePerson(int id) async {
    final uri = Uri.parse('$baseUrl/personnes/$id');
    final response = await client.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Erreur suppression');
    }
  }

  // PUT update person
  static Future<void> updatePerson(Person person) async {
    final uri = Uri.parse('$baseUrl/personnes/${person.id}');
    final response = await client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(person.toJson()),
    );
    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Erreur modification');
    }
  }
}