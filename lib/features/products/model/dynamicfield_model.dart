import 'package:flutter/material.dart';

enum DynamicFieldType {
  text,
  number,
  dropdown,
  boolean,
  unknown;

  factory DynamicFieldType.fromString(String type) {
    switch (type.toLowerCase()) {
      case 'textinput':
        return DynamicFieldType.text;
      case 'number':
        return DynamicFieldType.number;
      case 'booleantoggle':
        return DynamicFieldType.boolean;
      case 'sellerselectionlist':
        return DynamicFieldType.dropdown;
      default:
        debugPrint('Warning: Unknown dynamic field type encountered: $type');
        return DynamicFieldType.unknown;
    }
  }
}

class DynamicFieldModel {
  final String id;
  final String label;
  final DynamicFieldType type;
  final List<String> options;
  final bool isRequired;

  DynamicFieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.options = const [],
    this.isRequired = false,
  });

  factory DynamicFieldModel.fromMap(Map<String, dynamic> data, String id) {
    return DynamicFieldModel(
      id: id,
      label: data['label'] ?? '',
      type: DynamicFieldType.fromString(data['type'] ?? 'text'),
      options: List<String>.from(data['options'] ?? []),
      isRequired: data['isRequired'] ?? false,
    );
  }
}
