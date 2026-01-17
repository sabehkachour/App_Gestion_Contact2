import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import 'add_person_screen.dart';
import 'edit_person_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Person>> futurePersons;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
  // 1️⃣ Fetch data first (async)
  final persons = await ApiService.getPersons();

  // 2️⃣ Update state synchronously
  setState(() {
    futurePersons = Future.value(persons);
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Contacts'), backgroundColor: Colors.blue),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Person>>(
          future: futurePersons,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final persons = snapshot.data!;
              if (persons.isEmpty) {
                return const Center(child: Text('Aucun contact', style: TextStyle(fontSize: 18)));
              }
              return ListView.builder(
                itemCount: persons.length,
                itemBuilder: (context, i) {
                  final p = persons[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(p.prenom[0].toUpperCase())),
                      title: Text('${p.prenom} ${p.nom}'),
                      subtitle: Text(p.telephone),
                      // ✅ Edit on tap
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditPersonScreen(person: p)),
                        );
                        if (updated == true) await _refresh();
                      },
                      // ✅ Delete button
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmer'),
                              content: Text('Supprimer ${p.prenom} ${p.nom} ?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Non')),
                                TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Oui', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ApiService.deletePerson(p.id!);
                            await _refresh();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Supprimé')));
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPersonScreen()),
          );
          if (added == true) await _refresh();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}