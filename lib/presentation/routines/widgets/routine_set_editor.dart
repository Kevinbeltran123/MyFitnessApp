import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';

class RoutineSetEditor extends StatefulWidget {
  const RoutineSetEditor({
    super.key,
    this.initialSets = const <RoutineSet>[],
    required this.onChanged,
  });

  final List<RoutineSet> initialSets;
  final ValueChanged<List<RoutineSet>> onChanged;

  @override
  State<RoutineSetEditor> createState() => _RoutineSetEditorState();
}

class _RoutineSetEditorState extends State<RoutineSetEditor> {
  late List<RoutineSet> _sets;

  @override
  void initState() {
    super.initState();
    _sets = widget.initialSets.isEmpty
        ? <RoutineSet>[const RoutineSet(setNumber: 1, repetitions: 12)]
        : List<RoutineSet>.from(widget.initialSets);
  }

  void _update() {
    widget.onChanged(_sets);
    setState(() {});
  }

  void _addSet() {
    if (_sets.length >= 10) {
      AppSnackBar.showWarning(
        context,
        'Máximo 10 series por ejercicio.',
      );
      return;
    }
    final int nextNumber = (_sets.isNotEmpty ? _sets.last.setNumber : 0) + 1;
    _sets = <RoutineSet>[..._sets, RoutineSet(setNumber: nextNumber, repetitions: 10)];
    _update();
  }

  void _removeSet(int index) {
    if (_sets.length == 1) {
      AppSnackBar.showWarning(
        context,
        'Debe existir al menos una serie.',
      );
      return;
    }
    _sets = List<RoutineSet>.from(_sets)..removeAt(index);
    _update();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Series y repeticiones', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (int i = 0; i < _sets.length; i += 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SetRow(
              set: _sets[i],
              onChanged: (RoutineSet updated) {
                _sets = List<RoutineSet>.from(_sets)..[i] = updated;
                _update();
              },
              onRemove: () => _removeSet(i),
            ),
          ),
        TextButton.icon(
          onPressed: _addSet,
          icon: const Icon(Icons.add),
          label: const Text('Agregar serie'),
        ),
      ],
    );
  }
}

class _SetRow extends StatefulWidget {
  const _SetRow({
    required this.set,
    required this.onChanged,
    required this.onRemove,
  });

  final RoutineSet set;
  final ValueChanged<RoutineSet> onChanged;
  final VoidCallback onRemove;

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: widget.set.repetitions.toString());
    _weightController = TextEditingController(text: widget.set.targetWeight?.toString() ?? '');
    _restController = TextEditingController(
      text: widget.set.restInterval?.inSeconds.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _emitUpdate() {
    int reps = int.tryParse(_repsController.text) ?? widget.set.repetitions;
    reps = reps.clamp(1, 100);
    if (_repsController.text != reps.toString()) {
      _repsController.text = reps.toString();
      _repsController.selection = TextSelection.fromPosition(
        TextPosition(offset: _repsController.text.length),
      );
    }

    double? weight;
    if (_weightController.text.isEmpty) {
      weight = null;
    } else {
      final double? parsed = double.tryParse(_weightController.text);
      if (parsed == null) {
        weight = widget.set.targetWeight ?? 0;
      } else {
        weight = parsed < 0 ? 0 : parsed;
      }
      if (weight != null) {
        final String formatted = weight.toStringAsFixed(1);
        if (_weightController.text != formatted) {
          _weightController.text = formatted;
          _weightController.selection = TextSelection.fromPosition(
            TextPosition(offset: _weightController.text.length),
          );
        }
      }
    }

    Duration? rest;
    if (_restController.text.isEmpty) {
      rest = null;
    } else {
      final int? seconds = int.tryParse(_restController.text);
      int clamped = seconds ?? widget.set.restInterval?.inSeconds ?? 0;
      clamped = clamped.clamp(0, 1200);
      rest = Duration(seconds: clamped);
      if (_restController.text != clamped.toString()) {
        _restController.text = clamped.toString();
        _restController.selection = TextSelection.fromPosition(
          TextPosition(offset: _restController.text.length),
        );
      }
    }
    widget.onChanged(
      RoutineSet(
        setNumber: widget.set.setNumber,
        repetitions: reps,
        targetWeight: weight,
        restInterval: rest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _repsController,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _emitUpdate(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Peso (kg)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _emitUpdate(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _restController,
            decoration: const InputDecoration(labelText: 'Descanso (s)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _emitUpdate(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: widget.onRemove,
          color: theme.colorScheme.error,
        ),
      ],
    );
  }
}
