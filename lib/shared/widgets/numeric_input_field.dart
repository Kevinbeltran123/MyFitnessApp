import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Text field with built-in numeric ergonomics: +/- buttons, adjustable
/// increments, and automatic selection on focus.
class NumericInputField extends StatefulWidget {
  const NumericInputField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixText,
    this.validator,
    this.decimal = false,
    this.decimalDigits = 1,
    this.initialStep = 1,
    this.stepOptions,
    this.min,
    this.max,
    this.allowEmpty = false,
    this.enabled = true,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final String? suffixText;
  final FormFieldValidator<String>? validator;
  final bool decimal;
  final int decimalDigits;
  final double initialStep;
  final List<double>? stepOptions;
  final double? min;
  final double? max;
  final bool allowEmpty;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  @override
  State<NumericInputField> createState() => _NumericInputFieldState();
}

class _NumericInputFieldState extends State<NumericInputField> {
  late FocusNode _focusNode;
  late double _currentStep;

  @override
  void initState() {
    super.initState();
    assert(
      widget.initialStep > 0,
      'initialStep must be greater than zero',
    );
    assert(
      widget.stepOptions == null || widget.stepOptions!.isNotEmpty,
      'stepOptions cannot be empty',
    );
    assert(
      widget.stepOptions == null ||
          widget.stepOptions!.every((double step) => step > 0),
      'stepOptions must contain values > 0',
    );
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _currentStep =
        widget.stepOptions != null && widget.stepOptions!.isNotEmpty
            ? widget.stepOptions!.first
            : widget.initialStep;
  }

  @override
  void didUpdateWidget(covariant NumericInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
    }
    if (widget.stepOptions != oldWidget.stepOptions &&
        widget.stepOptions != null &&
        widget.stepOptions!.isNotEmpty) {
      final double preferred =
          widget.stepOptions!.contains(_currentStep)
              ? _currentStep
              : widget.stepOptions!.first;
      setState(() {
        _currentStep = preferred;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final String text = widget.controller.text;
        widget.controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: text.length,
        );
      });
    }
  }

  void _changeByStep(int direction) {
    if (!widget.enabled) {
      return;
    }
    final double step = _currentStep;
    final double currentValue =
        _parse(widget.controller.text) ?? widget.min ?? 0;
    double next = currentValue + (direction * step);
    if (widget.min != null) {
      next = next < widget.min! ? widget.min! : next;
    }
    if (widget.max != null) {
      next = next > widget.max! ? widget.max! : next;
    }
    _setValue(next);
  }

  void _setValue(double value) {
    final String formatted = widget.decimal
        ? _formatDecimal(value, widget.decimalDigits)
        : value.round().toString();
    widget.controller.text = formatted;
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
    widget.onChanged?.call(widget.controller.text);
    setState(() {});
  }

  double? _parse(String input) {
    if (input.trim().isEmpty) {
      return null;
    }
    final String normalized = input.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String _formatDecimal(double value, int digits) {
    String text = value.toStringAsFixed(digits);
    if (text.contains('.')) {
      text = text.replaceAll(RegExp(r'0+$'), '');
      if (text.endsWith('.')) {
        text = text.substring(0, text.length - 1);
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            _AdjustButton(
              icon: Icons.remove,
              onTap: () => _changeByStep(-1),
              enabled: widget.enabled,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon,
                  suffixText: widget.suffixText,
                ),
                textAlign: TextAlign.center,
                keyboardType: widget.decimal
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    widget.decimal
                        ? RegExp(r'[0-9.,]')
                        : RegExp(r'[0-9]'),
                  ),
                ],
                validator: widget.validator,
                onChanged: widget.onChanged,
                textInputAction: widget.textInputAction,
                autofillHints: widget.autofillHints,
              ),
            ),
            const SizedBox(width: 8),
            _AdjustButton(
              icon: Icons.add,
              onTap: () => _changeByStep(1),
              enabled: widget.enabled,
            ),
          ],
        ),
        if (widget.stepOptions != null && widget.stepOptions!.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              children: widget.stepOptions!
                  .map(
                    (double step) => ChoiceChip(
                      label: Text(_labelForStep(step)),
                      selected: _currentStep == step,
                      onSelected: widget.enabled
                          ? (bool selected) {
                            if (selected) {
                              setState(() {
                                _currentStep = step;
                              });
                            }
                          }
                          : null,
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        if (!widget.enabled)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Campo deshabilitado',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  String _labelForStep(double step) {
    if (!widget.decimal || step == step.roundToDouble()) {
      return step.toInt().toString();
    }
    return _formatDecimal(step, widget.decimalDigits);
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.lightGray : AppColors.veryLightGray,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon),
      ),
    );
  }
}
