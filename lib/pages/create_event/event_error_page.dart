import 'package:flutter/material.dart';

class EventErrorPage extends StatelessWidget {
  const EventErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 150),
            const SizedBox(height: 10),
            const Text(
              'FALLO AL CREAR EL \n EVENTO',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Mensaje de redirección
            const Text("Comuníquese con el administrador de \n la aplicación para resolver el problema.",
            style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => Navigator.pop(context),
              child: const Text('VOLVER', style: TextStyle(color: Colors.white))
            ),
          ],
        ),
      ),
    );
  }
}
