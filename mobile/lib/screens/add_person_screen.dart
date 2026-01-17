import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});
  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _tel = TextEditingController();
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.addPerson(Person(
        nom: _nom.text.trim(),
        prenom: _prenom.text.trim(),
        telephone: _tel.text.trim(),
      ));
      if (mounted) Navigator.pop(context, true); // return true to HomeScreen
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau contact')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _prenom,
              decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
              validator: (v) => v!.trim().isEmpty ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nom,
              decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
              validator: (v) => v!.trim().isEmpty ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tel,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
              validator: (v) => v!.trim().isEmpty ? 'Obligatoire' : !RegExp(r'^[0-9+\s-]+$').hasMatch(v!) ? 'Numéro invalide' : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Ajouter', style: TextStyle(fontSize: 18)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}