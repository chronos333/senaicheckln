import 'package:flutter/material.dart';
import 'registro_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SENAI CheckIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCC1825)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFCC1825),
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),
      home: const RegistroPage(),
    );
  }
}
