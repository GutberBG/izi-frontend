import 'package:flutter/material.dart';
import 'products_screen.dart';
import 'sales_screen.dart';
import 'reports_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required Map<String, String> user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        title: const Text('Gestión Comercial'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        //color texto blanco
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: AnimationLimiter(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 600),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                _buildNavigationCard(
                  context,
                  title: 'Productos',
                  icon: Icons.inventory_2,
                  color: Colors.blue.shade400,
                  destination: const ProductsScreen(),
                ),
                const SizedBox(height: 20),
                _buildNavigationCard(
                  context,
                  title: 'Ventas',
                  icon: Icons.shopping_cart,
                  color: Colors.green.shade400,
                  destination: const SalesScreen(),
                ),
                const SizedBox(height: 20),
                _buildNavigationCard(
                  context,
                  title: 'Reportes',
                  icon: Icons.analytics,
                  color: Colors.orange.shade400,
                  destination: const ReportsScreen(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return SizedBox(
      width: 450,
      height: 180,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: color,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ver detalles',
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
