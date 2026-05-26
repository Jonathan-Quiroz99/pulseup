import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final Function(String) onSelect;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = cat == selected;

          return GestureDetector(
            onTap: () => onSelect(cat),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}