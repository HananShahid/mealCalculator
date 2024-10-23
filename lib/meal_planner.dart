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
  List<Ingredient?> selectedIngredients = [];
  List<TextEditingController> weightControllers = [];
  List<double> ingredientWeights = [];
  List<List<Ingredient>> filteredIngredients = [];
  List<TextEditingController> searchControllers = [];
  double totalCalories = 0;
  double totalCarbs = 0;
  double totalProtein = 0;
  double totalFat = 0;
  double targetCalories = 0; // User input for target calories

  @override
  void initState() {
    super.initState();
    addNewIngredientField(); // Add the first ingredient field
  }

  // Function to add new ingredient fields
  void addNewIngredientField() {
    setState(() {
      selectedIngredients.add(null);
      weightControllers.add(TextEditingController());
      ingredientWeights.add(0);
      filteredIngredients.add([]);
      searchControllers.add(TextEditingController());
    });
  }

  // Function to calculate total nutritional values based on selected ingredients and their weights
  void calculateTotals() {
    totalCalories = 0;
    totalCarbs = 0;
    totalProtein = 0;
    totalFat = 0;
    for (int i = 0; i < selectedIngredients.length; i++) {
      if (selectedIngredients[i] != null && ingredientWeights[i] > 0) {
        Ingredient ingredient = selectedIngredients[i]!;
        totalCalories += ingredient.kcalPerGram * ingredientWeights[i];
        totalCarbs += ingredient.carbsPerGram * ingredientWeights[i];
        totalProtein += ingredient.proteinPerGram * ingredientWeights[i];
        totalFat += ingredient.fatPerGram * ingredientWeights[i];
      }
    }
    setState(() {}); // Update the UI
  }

  // Function to tailor the recipe based on target calories
  void tailorRecipe() {
    if (totalCalories > 0 && targetCalories > 0) {
      double adjustmentFactor =
          targetCalories / totalCalories; // Adjust weights

      setState(() {
        for (int i = 0; i < ingredientWeights.length; i++) {
          if (selectedIngredients[i] != null && ingredientWeights[i] > 0) {
            ingredientWeights[i] = ingredientWeights[i] * adjustmentFactor;
            weightControllers[i].text = ingredientWeights[i].toStringAsFixed(2);
          }
        }
        calculateTotals(); // Recalculate totals with new ingredient weights
      });
    }
  }

  // Real-time query to fetch ingredients from Firestore based on search input
  Future<void> filterIngredientsFromFirestore(String query, int index) async {
    if (query.isEmpty) {
      setState(() {
        filteredIngredients[index] = [];
      });
      return;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ingredients')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      filteredIngredients[index] =
          snapshot.docs.map((doc) => Ingredient.fromFirestore(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Planner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              addNewIngredientField(); // Add new ingredient field dynamically
            },
          ),
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
                itemCount: selectedIngredients.length,
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
                                filterIngredientsFromFirestore(value, index);
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
                                setState(() {
                                  ingredientWeights[index] =
                                      double.tryParse(value) ?? 0;
                                  calculateTotals(); // Recalculate after weight change
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      // Display the filtered ingredients list as suggestions
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredIngredients[index].length,
                        itemBuilder: (context, suggestionIndex) {
                          return ListTile(
                            title: Text(filteredIngredients[index]
                                    [suggestionIndex]
                                .name),
                            onTap: () {
                              setState(() {
                                selectedIngredients[index] =
                                    filteredIngredients[index][suggestionIndex];
                                searchControllers[index].text =
                                    filteredIngredients[index][suggestionIndex]
                                        .name;
                                filteredIngredients[index] = [];
                                calculateTotals();
                              });
                            },
                          );
                        },
                      ),
                    ],
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
