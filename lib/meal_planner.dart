import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'data_base.dart'; // Import the ingredient data
import 'data_entry.dart'; // Import the new Data Entry Page

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  final TextEditingController searchController =
      TextEditingController(); // For the search field
  final TextEditingController weightController = TextEditingController();
  Ingredient? selectedIngredient; // Store the selected ingredient
  double ingredientWeight = 0;
  double totalCalories = 0;
  double totalCarbs = 0;
  double totalProtein = 0;
  double totalFat = 0;
  double targetCalories = 0; // User input for target calories
  List<Ingredient> ingredientSuggestions =
      []; // Store suggestions from Firestore

  @override
  void initState() {
    super.initState();
  }

  // Function to calculate total nutritional values based on selected ingredient and its weight
  void calculateTotals() {
    totalCalories = 0;
    totalCarbs = 0;
    totalProtein = 0;
    totalFat = 0;

    if (selectedIngredient != null && ingredientWeight > 0) {
      totalCalories += selectedIngredient!.kcalPerGram * ingredientWeight;
      totalCarbs += selectedIngredient!.carbsPerGram * ingredientWeight;
      totalProtein += selectedIngredient!.proteinPerGram * ingredientWeight;
      totalFat += selectedIngredient!.fatPerGram * ingredientWeight;
    }

    setState(() {}); // Update the UI
  }

  // Function to tailor the recipe based on target calories
  void tailorRecipe() {
    if (totalCalories > 0 && targetCalories > 0) {
      double adjustmentFactor =
          targetCalories / totalCalories; // Adjust weights

      setState(() {
        if (selectedIngredient != null && ingredientWeight > 0) {
          ingredientWeight = ingredientWeight * adjustmentFactor;
          weightController.text = ingredientWeight.toStringAsFixed(2);
        }
        calculateTotals(); // Recalculate totals with the new ingredient weight
      });
    }
  }

  // Real-time query to fetch ingredients from Firestore based on search input
  Future<void> fetchIngredientSuggestionsFromFirestore(String query) async {
    if (query.isEmpty) {
      setState(() {
        ingredientSuggestions = []; // Clear suggestions when input is empty
      });
      return;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ingredients')
        .where('searchKeywords',
            arrayContains:
                query.toLowerCase()) // Partial case-insensitive matching
        .limit(5) // Limit to 5 suggestions
        .get();

    setState(() {
      ingredientSuggestions = snapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc))
          .toList(); // Store the list of suggestions
    });
  }

  // Function to select an ingredient from the suggestions and populate the search field
  void selectIngredient(Ingredient ingredient) {
    setState(() {
      selectedIngredient = ingredient;
      searchController.text =
          ingredient.name; // Set selected ingredient in the search field
      ingredientSuggestions = []; // Clear suggestions after selecting
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Planner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {
              // Navigate to Data Entry Page to add a new ingredient to Firestore
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DataEntryPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Search field to search ingredients from Firestore
                Expanded(
                  child: TextField(
                    controller: searchController, // Link the controller
                    decoration:
                        const InputDecoration(labelText: "Search Ingredient"),
                    onChanged: (value) {
                      fetchIngredientSuggestionsFromFirestore(
                          value); // Fetch suggestions from Firestore
                    },
                  ),
                ),
                const SizedBox(width: 20),
                // Weight input field
                Expanded(
                  child: TextField(
                    controller: weightController,
                    decoration: const InputDecoration(labelText: "Weight (g)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        ingredientWeight = double.tryParse(value) ?? 0;
                        calculateTotals(); // Recalculate after weight change
                      });
                    },
                  ),
                ),
              ],
            ),
            // Display suggestions below the search field
            if (ingredientSuggestions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ingredientSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(ingredientSuggestions[index].name),
                      onTap: () {
                        selectIngredient(
                            ingredientSuggestions[index]); // Select ingredient
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            // Input for target calories
            TextField(
              decoration: const InputDecoration(labelText: "Target Calories"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  targetCalories = double.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            // Button to adjust recipe to meet target calories
            ElevatedButton(
              onPressed: tailorRecipe,
              child: const Text("Tailor Recipe to Target Calories"),
            ),
            const SizedBox(height: 20),
            // Display total nutritional values
            Text("Total Calories: ${totalCalories.toStringAsFixed(2)}"),
            Text("Total Carbs: ${totalCarbs.toStringAsFixed(2)}g"),
            Text("Total Protein: ${totalProtein.toStringAsFixed(2)}g"),
            Text("Total Fat: ${totalFat.toStringAsFixed(2)}g"),
          ],
        ),
      ),
    );
  }
}
