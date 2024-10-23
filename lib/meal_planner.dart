import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'data_entry.dart'; // Import the new Data Entry Page
import 'data_base.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  List<TextEditingController> searchControllers =
      []; // List of search controllers for each ingredient
  List<TextEditingController> weightControllers =
      []; // List of weight controllers for each ingredient
  List<Ingredient?> selectedIngredients =
      []; // List to store the selected ingredients
  List<List<Ingredient>> ingredientSuggestionsList =
      []; // List of suggestion lists for each search field
  double totalCalories = 0;
  double totalCarbs = 0;
  double totalProtein = 0;
  double totalFat = 0;
  double targetCalories = 0; // User input for target calories

  @override
  void initState() {
    super.initState();
    addIngredientField(); // Add the first ingredient field when the app starts
  }

  // Function to add a new ingredient field
  void addIngredientField() {
    setState(() {
      searchControllers.add(TextEditingController());
      weightControllers.add(TextEditingController());
      selectedIngredients.add(null);
      ingredientSuggestionsList.add([]);
    });
  }

  // Function to calculate total nutritional values based on selected ingredients and their weights
  void calculateTotals() {
    totalCalories = 0;
    totalCarbs = 0;
    totalProtein = 0;
    totalFat = 0;

    for (int i = 0; i < selectedIngredients.length; i++) {
      if (selectedIngredients[i] != null &&
          weightControllers[i].text.isNotEmpty) {
        double weight = double.tryParse(weightControllers[i].text) ?? 0;
        Ingredient ingredient = selectedIngredients[i]!;
        totalCalories += ingredient.kcalPerGram * weight;
        totalCarbs += ingredient.carbsPerGram * weight;
        totalProtein += ingredient.proteinPerGram * weight;
        totalFat += ingredient.fatPerGram * weight;
      }
    }

    setState(() {}); // Update the UI
  }

  // Function to tailor the recipe based on target calories
  void tailorRecipe() {
    if (totalCalories > 0 && targetCalories > 0) {
      double adjustmentFactor = targetCalories / totalCalories;

      setState(() {
        for (int i = 0; i < weightControllers.length; i++) {
          if (selectedIngredients[i] != null &&
              weightControllers[i].text.isNotEmpty) {
            double weight = double.tryParse(weightControllers[i].text) ?? 0;
            weight = weight * adjustmentFactor;
            weightControllers[i].text = weight.toStringAsFixed(2);
          }
        }
        calculateTotals(); // Recalculate totals with the new ingredient weights
      });
    }
  }

  // Real-time query to fetch ingredients directly from Firestore based on search input
  Future<void> fetchIngredientSuggestionsFromFirestore(
      String query, int index) async {
    if (query.isEmpty) {
      setState(() {
        ingredientSuggestionsList[index] =
            []; // Clear suggestions when input is empty
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
      ingredientSuggestionsList[index] = snapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc))
          .toList(); // Store the list of suggestions for the specific field
    });
  }

  // Function to select an ingredient from the suggestions
  void selectIngredient(Ingredient ingredient, int index) {
    setState(() {
      selectedIngredients[index] = ingredient;
      searchControllers[index].text =
          ingredient.name; // Set selected ingredient in the search field
      ingredientSuggestionsList[index] =
          []; // Clear suggestions after selecting
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
            Expanded(
              child: ListView.builder(
                itemCount: searchControllers.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          // Search field to search ingredients from Firestore
                          Expanded(
                            child: TextField(
                              controller: searchControllers[index],
                              decoration: const InputDecoration(
                                  labelText: "Search Ingredient"),
                              onChanged: (value) {
                                fetchIngredientSuggestionsFromFirestore(
                                    value, index); // Fetch suggestions
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Weight input field
                          Expanded(
                            child: TextField(
                              controller: weightControllers[index],
                              decoration: const InputDecoration(
                                  labelText: "Weight (g)"),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                calculateTotals(); // Recalculate after weight change
                              },
                            ),
                          ),
                        ],
                      ),
                      // Display suggestions below the search field
                      if (ingredientSuggestionsList[index].isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: ingredientSuggestionsList[index].length,
                          itemBuilder: (context, suggestionIndex) {
                            return ListTile(
                              title: Text(ingredientSuggestionsList[index]
                                      [suggestionIndex]
                                  .name),
                              onTap: () {
                                selectIngredient(
                                    ingredientSuggestionsList[index]
                                        [suggestionIndex],
                                    index); // Select ingredient
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addIngredientField(); // Add a new ingredient field
              },
              child: const Text('Add Ingredient'),
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
