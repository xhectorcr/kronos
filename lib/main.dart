import 'package:flutter/material.dart';
import 'view/island_operations.dart';
import 'view/finaces.dart';
import 'view/omnidroid_metatraining.dart';
import 'view/supers.dart';

void main() {
  runApp(const KronosApp());
}

class KronosApp extends StatelessWidget {
  const KronosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const IslandOperationsScreen(),
    );
  }
}

class IslandOperationsScreen extends StatefulWidget {
  const IslandOperationsScreen({super.key});

  @override
  State<IslandOperationsScreen> createState() => _IslandOperationsScreenState();
}

class _IslandOperationsScreenState extends State<IslandOperationsScreen> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.home, "text": "ISLAND OPERATIONS"}, // ahora es item
    {"icon": Icons.attach_money, "text": "FINANCES"},
    {"icon": Icons.smart_toy, "text": "OMNIDROID METATRAINING"},
    {"icon": Icons.flash_on, "text": "SUPERS"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFCDFCFC), // azul ocupa toda la pantalla
        child: Column(
          children: [
            // Franja superior
            Expanded(
              child: Container(
                color: const Color(0xFF72AFAF), // gris
              ),
            ),

            // Franja central con contenido (centrado)
            Expanded(
              child: Center(
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(menuItems.length, (index) {
                      final item = menuItems[index];
                      final isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          Widget? destination;
                          switch (index) {
                            case 0:
                              destination =
                                  const IslandOperationsScreen(); // island_operations.dart
                              break;
                            case 1:
                              destination =
                                  const IslandOperationsScreen(); // finaces.dart
                              break;
                            case 2:
                              destination =
                                  const IslandOperationsScreen(); // omnidroid_metatraining.dart
                              break;
                            case 3:
                              destination = VideoPlayerExample(); // supers.dart
                              break;
                          }
                          if (destination != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => destination!),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black.withOpacity(
                                    0.1,
                                  ) // fondo seleccionado
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(item["icon"], color: Colors.black, size: 30),
                              const SizedBox(width: 12),
                              Text(
                                item["text"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Franja inferior
            Expanded(
              child: Container(
                color: const Color(0xFF72AFAF), // gris
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//final v11
