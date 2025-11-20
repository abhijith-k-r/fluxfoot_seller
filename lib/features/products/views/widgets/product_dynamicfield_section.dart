// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/products/model/dropdown_model.dart';
import 'package:fluxfoot_seller/features/products/model/dynamicfield_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/form_elements.dart';
import 'package:provider/provider.dart';

class SellerDynamicFieldsSection extends StatelessWidget {
  const SellerDynamicFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final categoryModel = provider.selectedCategoryModel;

        if (categoryModel == null || categoryModel.dynamicFields.isEmpty) {
          return const SizedBox.shrink();
        }

        final displayFields = categoryModel.dynamicFields.where((field) {
          final label = field.label.toLowerCase();
          return !label.contains('color') && !label.contains('size');
        }).toList();

        if (displayFields.isEmpty) {
          return SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WebColors.borderSideGrey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  20,
                  '${categoryModel.name} Specifications',
                  fontWeight: FontWeight.bold,
                  webcolors: WebColors.textBlack,
                ),
                const SizedBox(height: 24),

                // ! Dynamic Field Grid
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    childAspectRatio: 5 / 1,
                  ),
                  itemCount: displayFields.length,
                  itemBuilder: (context, index) {
                    final field = displayFields[index];

                    return _buildFieldWidget(context, field, provider);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper function to build the correct widget type
Widget _buildFieldWidget(
  BuildContext context,
  DynamicFieldModel field,
  ProductProvider provider,
) {
  final initialValue = provider.getDynamicFieldValue(field.id);
  final isRequired = field.isRequired;
  if (field.label.toLowerCase().contains('color') ||
      field.label.toLowerCase().contains('size')) {
    return SizedBox.shrink();
  }
  switch (field.type) {
    case DynamicFieldType.text:
    case DynamicFieldType.number:
      return buildTextField(
        context,
        field.label + (isRequired ? ' *' : ''),
        'Enter ${field.label.toLowerCase()}',
        TextEditingController(text: initialValue ?? ''),
        keyboardType: field.type == DynamicFieldType.number
            ? TextInputType.number
            : TextInputType.text,
        onChanged: (value) => provider.setDynamicFieldValue(field.id, value),
      );

    case DynamicFieldType.dropdown:
      return buildDropdownField(
        context: context,
        label: field.label + (isRequired ? ' *' : ''),
        hint: 'Select ${field.label}',

        itemsFuture: Future.value(
          field.options
              .map((name) => DropdownItemModel(id: name, name: name))
              .toList(),
        ),
        selectedValue: initialValue,
        onChanged: (newId) => provider.setDynamicFieldValue(field.id, newId),
      );

    case DynamicFieldType.boolean:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            14,
            field.label + (isRequired ? ' *' : ''),
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 6),
          SwitchListTile(
            title: const Text(''),
            value: initialValue == 'true',
            onChanged: (bool value) =>
                provider.setDynamicFieldValue(field.id, value.toString()),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      );

    default:
      return const SizedBox.shrink();
  }
}
