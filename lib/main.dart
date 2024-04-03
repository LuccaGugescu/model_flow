import 'package:flutter/material.dart';
import 'package:model_flow/screens/home.dart';
import 'package:model_flow/screens/model_preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ModelFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(primary: Colors.black),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const MyHomePage(
              title: 'Welcome to ModelFlow',
            ),
        "/model_preview": (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments;
          return ModelPreview(argument: arguments as String);
        }
      },
    );
  }
}
