import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/hive_models/user.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupération des arguments et vérification du type
    final args = ModalRoute.of(context)!.settings.arguments;
    final List<User> users = args is List<User> ? args : [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue'),
      ),
      body: users.isNotEmpty
          ? ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text(user.dateOfBirth),
            leading: user.profileImage != null
                ? Image.file(user.profileImage!)
                : Icon(Icons.person),
          );
        },
      )
          : Center(
        child: Text('Moins de 3 utilisateurs inscrits.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Icon(Icons.logout),
        tooltip: 'Déconnexion',
      ),
    );
  }
}
