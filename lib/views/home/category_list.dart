import 'package:flutter/material.dart';

class CategorySelectorSheet extends StatefulWidget {
  const CategorySelectorSheet({super.key});

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  final List<String> categories = [
    'Important',
    'Lecture notes',
    'To-do lists',
    'Shopping list',
    'Diary',
    'Retrospective 2023',
  ];

  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 400,
      child: Column(
        children: [
          const Text('Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: categories.map((cat) {
                final isSelected = selected.contains(cat);
                return ListTile(
                  title: Text(cat),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.black) : null,
                  onTap: () {
                    setState(() {
                      isSelected ? selected.remove(cat) : selected.add(cat);
                    });
                  },
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selected.toList()),
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
