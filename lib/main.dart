import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentations/screens/list_screen/dog_list_screen.dart';
import 'presentations/providers/dog_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DogProvider(),
      child: MaterialApp(
        title: 'Dog Breeds App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const DogListScreen(),
      ),
    );
  }
}
