import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core package
import 'meal_planner.dart'; // Import the MealPlanner widget
import 'data_entry.dart'; // Import the DataEntry widget

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
      home: const MealPlanner(), // Start with the MealPlanner screen
      routes: {
        '/meal-planner': (context) =>
            const MealPlanner(), // Route for MealPlanner
        '/data-entry': (context) =>
            const DataEntryPage(), // Route for DataEntryPage
      },
    );
  }
}
