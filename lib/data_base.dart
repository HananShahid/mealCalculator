import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package

class Ingredient {
  final String name;
  final double kcalPerGram;
  final double carbsPerGram;
  final double proteinPerGram;
  final double fatPerGram;

  Ingredient({
    required this.name,
    required this.kcalPerGram,
    required this.carbsPerGram,
    required this.proteinPerGram,
    required this.fatPerGram,
  });

  // Factory method to create an Ingredient from Firestore document
  factory Ingredient.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Ingredient(
      name:
          data['Ingredient'] ?? '', // Adjust according to Firestore field name
      kcalPerGram: (data['kcalPerGram'] as num).toDouble(),
      carbsPerGram: (data['carbsPerGram'] as num).toDouble(),
      proteinPerGram: (data['proteinPerGram'] as num).toDouble(),
      fatPerGram: (data['fatPerGram'] as num).toDouble(),
    );
  }

  // Convert Ingredient instance to Firestore-friendly map for upload
  Map<String, dynamic> toFirestore() {
    return {
      'Ingredient': name,
      'kcalPerGram': kcalPerGram,
      'carbsPerGram': carbsPerGram,
      'proteinPerGram': proteinPerGram,
      'fatPerGram': fatPerGram,
    };
  }
}
