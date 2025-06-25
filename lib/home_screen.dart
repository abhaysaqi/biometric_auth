import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatelessWidget {
  final secureStorage = FlutterSecureStorage();

  HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await secureStorage.deleteAll();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome!"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              _logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "You're logged in using biometrics!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
