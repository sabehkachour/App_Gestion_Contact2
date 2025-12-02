import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import 'add_person_screen.dart';

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
    futurePersons = ApiService.getPersons();
  }

  void _refresh() => setState(() => futurePersons = ApiService.getPersons());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Contacts'), backgroundColor: Colors.blue),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
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
                  return Dismissible(
                    key: Key(p.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red, alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white)),
                    confirmDismiss: (_) => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirmer'),
                        content: Text('Supprimer ${p.prenom} ${p.nom} ?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                    onDismissed: (_) async {
                      await ApiService.deletePerson(p.id!);
                      _refresh();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supprimé')));
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(p.prenom[0].toUpperCase())),
                        title: Text('${p.prenom} ${p.nom}'),
                        subtitle: Text(p.telephone),
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
          final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPersonScreen()));
          if (added == true) _refresh();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}