import 'package:fluxfoot_seller/features/products/model/dynamicfield_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final List<DynamicFieldModel> dynamicFields;

  CategoryModel({
    required this.id,
    required this.name,
    required this.dynamicFields,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    final dynamicFiedsList = <DynamicFieldModel>[];
    final rawFields = data['dynamicFields'];

    if (rawFields is Map<String, dynamic>) {
      rawFields.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          dynamicFiedsList.add(DynamicFieldModel.fromMap(value, key));
        }
      });
    } else if (rawFields is List<dynamic>) {
      for (var value in rawFields) {
        if (value is Map<String, dynamic>) {
          final fieldId =
              value['id'] as String? ?? 'default_id_${dynamicFiedsList.length}';
          dynamicFiedsList.add(DynamicFieldModel.fromMap(value, fieldId));
        }
      }
    }

    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      dynamicFields: dynamicFiedsList,
    );
  }
}
