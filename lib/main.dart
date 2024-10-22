import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core package
import 'meal_planner.dart'; // Import the MealPlanner widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MealPlanner(), // Start directly with the MealPlanner screen
    );
  }
}
