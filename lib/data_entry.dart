import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  _DataEntryPageState createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController kcalController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatController = TextEditingController();

  Future<void> addIngredientToFirestore() async {
    await FirebaseFirestore.instance.collection('ingredients').add({
      'Ingredient': nameController.text.trim(),
      'kcalPerGram': double.parse(kcalController.text.trim()),
      'carbsPerGram': double.parse(carbsController.text.trim()),
      'proteinPerGram': double.parse(proteinController.text.trim()),
      'fatPerGram': double.parse(fatController.text.trim()),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ingredient added successfully!')),
    );
    // Clear inputs after submission
    nameController.clear();
    kcalController.clear();
    carbsController.clear();
    proteinController.clear();
    fatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Ingredient')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ingredient Name'),
            ),
            TextField(
              controller: kcalController,
              decoration: const InputDecoration(labelText: 'kCal per Gram'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: carbsController,
              decoration: const InputDecoration(labelText: 'Carbs per Gram'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: proteinController,
              decoration: const InputDecoration(labelText: 'Protein per Gram'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: fatController,
              decoration: const InputDecoration(labelText: 'Fat per Gram'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addIngredientToFirestore,
              child: const Text('Add Ingredient'),
            ),
          ],
        ),
      ),
    );
  }
}
