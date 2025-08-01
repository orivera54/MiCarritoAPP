import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedTextFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool required;
  final String? errorText;

  const EnhancedTextFormField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.focusNode,
    this.required = false,
    this.errorText,
  });

  @override
  State<EnhancedTextFormField> createState() => _EnhancedTextFormFieldState();
}

class _EnhancedTextFormFieldState extends State<EnhancedTextFormField> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (widget.required)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          initialValue: widget.initialValue,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: (value) {
            if (_hasError) {
              // Clear error on change
              setState(() {
                _hasError = false;
                _errorMessage = null;
              });
            }
            widget.onChanged?.call(value);
          },
          onSaved: widget.onSaved,
          validator: (value) {
            final error = widget.validator?.call(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _hasError = error != null;
                  _errorMessage = error;
                });
              }
            });
            return error;
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: widget.errorText ?? _errorMessage,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError ? Colors.red : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError ? Colors.red : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError ? Colors.red : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: widget.enabled
                ? (_hasError ? Colors.red[50] : Colors.grey[50])
                : Colors.grey[100],
          ),
        ),
      ],
    );
  }
}

class EnhancedDropdownFormField<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final void Function(T?)? onSaved;
  final void Function(T?)? onChanged;
  final bool enabled;
  final bool required;
  final Widget? prefixIcon;

  const EnhancedDropdownFormField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.prefixIcon,
  });

  @override
  State<EnhancedDropdownFormField<T>> createState() =>
      _EnhancedDropdownFormFieldState<T>();
}

class _EnhancedDropdownFormFieldState<T>
    extends State<EnhancedDropdownFormField<T>> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (widget.required)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        DropdownButtonFormField<T>(
          value: widget.value,
          items: widget.items,
          onChanged: widget.enabled
              ? (value) {
                  if (_hasError) {
                    setState(() {
                      _hasError = false;
                    });
                  }
                  widget.onChanged?.call(value);
                }
              : null,
          onSaved: widget.onSaved,
          validator: (value) {
            final error = widget.validator?.call(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _hasError = error != null;
                });
              }
            });
            return error;
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError ? Colors.red : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError ? Colors.red : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError ? Colors.red : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: widget.enabled
                ? (_hasError ? Colors.red[50] : Colors.grey[50])
                : Colors.grey[100],
          ),
        ),
      ],
    );
  }
}

class FormValidationHelper {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return null;

    final price = double.tryParse(value);
    if (price == null) {
      return 'Ingresa un precio válido';
    }
    if (price < 0) {
      return 'El precio no puede ser negativo';
    }
    if (price > 999999) {
      return 'El precio es demasiado alto';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Ingresa un peso válido';
    }
    if (weight <= 0) {
      return 'El peso debe ser mayor a 0';
    }
    if (weight > 1000) {
      return 'El peso es demasiado alto';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) return null;

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Ingresa una cantidad válida';
    }
    if (quantity <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    if (quantity > 9999) {
      return 'La cantidad es demasiado alta';
    }
    return null;
  }

  static String? validateLength(String? value,
      {int? minLength, int? maxLength}) {
    if (value == null) return null;

    if (minLength != null && value.length < minLength) {
      return 'Debe tener al menos $minLength caracteres';
    }
    if (maxLength != null && value.length > maxLength) {
      return 'No puede tener más de $maxLength caracteres';
    }
    return null;
  }

  static String? combineValidators(
      String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
