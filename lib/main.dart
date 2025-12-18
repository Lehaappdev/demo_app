import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'countries/providers/country_provider.dart';
import 'countries/screens/country_search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CountryProvider(),
      child: MaterialApp(
        title: 'Поиск стран',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const CountrySearchScreen(),
      ),
    );
  }
}

