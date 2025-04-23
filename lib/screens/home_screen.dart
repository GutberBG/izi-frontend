import 'package:flutter/material.dart';
import 'products_screen.dart'; // Asegúrate de importar correctamente

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Ir a Productos"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductsScreen()),
            );
          },
        ),
      ),
    );
  }
}