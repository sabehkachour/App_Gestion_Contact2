import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';

class EditPersonScreen extends StatefulWidget {
  final Person person;
  const EditPersonScreen({super.key, required this.person});

  @override
  State<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nom;
  late TextEditingController _prenom;
  late TextEditingController _tel;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController(text: widget.person.nom);
    _prenom = TextEditingController(text: widget.person.prenom);
    _tel = TextEditingController(text: widget.person.telephone);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.updatePerson(Person(
        id: widget.person.id,
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
      appBar: AppBar(title: const Text('Modifier contact')),
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
                    : const Text('Modifier', style: TextStyle(fontSize: 18)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}