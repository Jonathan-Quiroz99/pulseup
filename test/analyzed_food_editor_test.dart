import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/nutrition/models/meal_food.dart';
import 'package:pulseup/features/nutrition/widgets/analyzed_food_editor.dart';

Future<MealFood> _pump(WidgetTester tester, MealFood food) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: AnalyzedFoodEditor(food: food, onChanged: () {}, onDelete: () {}),
      ),
    ),
  ));
  return food;
}

Finder _field(String label) =>
    find.widgetWithText(TextField, label);

void main() {
  testWidgets('cambiar los gramos recalcula calorías y macros en proporción',
      (tester) async {
    final food = await _pump(
      tester,
      MealFood(name: 'Pollo', grams: 250, calories: 412.5, protein: 77.5, carbs: 0, fat: 9),
    );

    await tester.enterText(_field('Gramos'), '180');
    await tester.pump();

    expect(food.grams, 180);
    expect(food.calories, closeTo(297, 0.05)); // 412.5 * 0.72
    expect(food.protein, closeTo(55.8, 0.05));
    expect(food.carbs, 0);
    expect(food.fat, closeTo(6.5, 0.05));
  });

  testWidgets('mientras se borra el campo de gramos no se pierden los datos',
      (tester) async {
    final food = await _pump(
      tester,
      MealFood(name: 'Arroz', grams: 200, calories: 260, protein: 5, carbs: 56, fat: 1),
    );

    await tester.enterText(_field('Gramos'), '');
    await tester.pump();
    expect(food.calories, 260);

    await tester.enterText(_field('Gramos'), '100');
    await tester.pump();
    expect(food.calories, closeTo(130, 0.05));
  });

  testWidgets('una corrección manual pasa a ser la base de la proporción',
      (tester) async {
    final food = await _pump(
      tester,
      MealFood(name: 'Pan', grams: 100, calories: 250, protein: 9, carbs: 49, fat: 3),
    );

    await tester.enterText(_field('Kcal'), '300'); // la etiqueta decía 300
    await tester.pump();
    await tester.enterText(_field('Gramos'), '50');
    await tester.pump();

    expect(food.calories, closeTo(150, 0.05));
    expect(food.protein, closeTo(4.5, 0.05));
  });

  testWidgets('alimento agregado a mano: los primeros gramos no borran lo escrito',
      (tester) async {
    final food = await _pump(
      tester,
      MealFood(name: 'Alimento', grams: 0, calories: 0, protein: 0, carbs: 0, fat: 0),
    );

    await tester.enterText(_field('Kcal'), '200');
    await tester.pump();
    await tester.enterText(_field('Gramos'), '100');
    await tester.pump();
    expect(food.calories, 200);

    await tester.enterText(_field('Gramos'), '150');
    await tester.pump();
    expect(food.calories, closeTo(300, 0.05));
  });
}
