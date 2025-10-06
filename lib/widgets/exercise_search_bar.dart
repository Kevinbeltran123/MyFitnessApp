import 'package:flutter/material.dart';

class ExerciseSearchBar extends StatelessWidget {
  const ExerciseSearchBar({
    super.key,
    required this.controller,
    required this.onQueryChanged,
    required this.onClear,
    this.isSearching = false,
  });

  final SearchController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final hasText = controller.text.isNotEmpty;
        return SearchBar(
          controller: controller,
          hintText: 'Buscar ejercicios',
          onChanged: onQueryChanged,
          onSubmitted: onQueryChanged,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          trailing: <Widget>[
            if (isSearching)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (hasText)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Borrar búsqueda',
                onPressed: onClear,
              ),
          ],
        );
      },
    );
  }
}
