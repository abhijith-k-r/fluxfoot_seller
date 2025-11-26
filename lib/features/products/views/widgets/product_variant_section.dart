// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/products/model/colorvariant_model.dart';
import 'package:fluxfoot_seller/features/products/model/dynamicfield_model.dart';
import 'package:fluxfoot_seller/features/products/model/sizequantity_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/show_helper_function.dart';
import 'package:provider/provider.dart';

//! Placeholder for future size/color picking dialogs
// void showSizeInput(
//   BuildContext context,
//   ProductProvider provider,
//   String colorName,
// ) {
//   // We will define this later
// }

// ! ============()=============
Widget buildSizeQuantityTable(
  BuildContext context,
  ProductProvider provider,
  ColorvariantModel variant, {
  SizeQuantityVariant? sizeQuantity,
  DynamicFieldModel? sizeField,
}) {
  if (sizeField == null) {
    return const Text(
      'Size options not available for this category.',
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      //! === Existing sizes rows ===
      ...variant.sizes.map((existing) {
        final sizeLabel = existing.size;

        final TextEditingController qtyController = TextEditingController(
          text: existing.quantity.toString(),
        );

        qtyController.addListener(() {
          final q = int.tryParse(qtyController.text) ?? 0;
          if (q != existing.quantity) {
            provider.addSizeToVariant(variant.colorName, sizeLabel, q);
          }
        });

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),

          child: Row(
            children: [
              Expanded(
                child: Text(
                  sizeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: TextFormField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Qty',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: WebColors.errorRed,
                  size: 20,
                ),
                onPressed: () {
                  provider.removeSizeFromVariant(variant.colorName, sizeLabel);
                },
              ),
            ],
          ),
        );
      }),

      const SizedBox(height: 8),
    ],
  );
}

// ! ===========
class ProductVariantSection extends StatelessWidget {
  const ProductVariantSection({super.key, th});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final categoryModel = productProvider.selectedCategoryModel;
        DynamicFieldModel? colorField;
        DynamicFieldModel? sizeField;

        if (categoryModel != null) {
          for (final f in categoryModel.dynamicFields) {
            final label = f.label.toLowerCase();
            if (f.type == DynamicFieldType.dropdown) {
              final optionsLower = f.options
                  .map((o) => o.toLowerCase())
                  .toList();

              if (label.contains('color') ||
                  optionsLower.any((o) => o.contains('color'))) {
                colorField = f;
              }

              if (label.contains('size') ||
                  optionsLower.any((o) => o.contains('size'))) {
                sizeField = f;
              }
            }
          }
        }

        final bool hasColorDropdown = colorField != null;
        if (hasColorDropdown) {
          return Container(
            margin: const EdgeInsets.only(top: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WebColors.borderSideGrey),
              color: Colors.white,
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
                //! Header Row (Title + Add Color Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customText(
                      20,
                      'Color & Size Variants',
                      fontWeight: FontWeight.bold,
                      webcolors: WebColors.textBlack,
                    ),
                    // ! Button to ADD ANOTHER COLOR
                    ElevatedButton.icon(
                      onPressed: () => showColorSelectionDialog(
                        context,
                        colorField!,
                        productProvider,
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text('Add Color'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WebColors.buttonPurple,
                        foregroundColor: WebColors.textWite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (productProvider.productVariants.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No variants added yet. Click "Add Color" to begin.',
                      ),
                    ),
                  ),

                ...productProvider.productVariants.map((variant) {
                  return _buildColorVariantTile(
                    context,
                    productProvider,
                    variant,
                    null,
                    sizeField,
                  );
                }),
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildColorVariantTile(
    BuildContext context,
    ProductProvider provider,
    ColorvariantModel variant,
    SizeQuantityVariant? sizeQuantity,
    DynamicFieldModel? field,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Color(int.parse(variant.colorCode.replaceAll('#', '0xFF'))),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        title: customText(
          16,
          'Color: ${variant.colorName}',
          fontWeight: FontWeight.w600,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => provider.removeColorVariant(variant.colorName),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //! 1. Image Upload Area (Needs its own focused widget)
                customText(
                  14,
                  'Images for ${variant.colorName}',
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 8),
                _buildImageUploadGrid(context, provider, variant),

                const SizedBox(height: 24),

                //! 2. Size/Quantity Management (Table structure)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customText(
                      14,
                      'Sizes & Stock',
                      fontWeight: FontWeight.w500,
                    ),

                    //! === NEW "Add Size" Button ===
                    TextButton.icon(
                      onPressed: field == null
                          ? null
                          : () => showAddSizeDialog(
                              context,
                              provider,
                              variant.colorName,
                              field,
                            ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Size Option'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        backgroundColor: WebColors.buttonPurple,
                        foregroundColor: WebColors.textWite,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                buildSizeQuantityTable(
                  context,
                  provider,
                  variant,
                  sizeField: field,
                  sizeQuantity: sizeQuantity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ! ======== () ========

  Widget _buildImageUploadGrid(
    BuildContext context,
    ProductProvider provider,
    ColorvariantModel variant,
  ) {
    final size = MediaQuery.of(context).size.width;
    return Column(
      children: [
        if (variant.imageUrls.isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(child: Text('No images for ${variant.colorName}.')),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: variant.imageUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final url = variant.imageUrls[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        url,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => provider.removeImageFromVariant(
                          variant.colorName,
                          url,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () =>
                provider.pickAndUpladImagesForVariant(variant.colorName),
            icon: Icon(
              Icons.add_photo_alternate_outlined,
              size: size * 0.015,
              color: WebColors.iconWhite,
            ),
            label: customText(
              size * 0.009,
              'Upload Images for this color',
              webcolors: WebColors.textWite,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.buttonPurple,
            ),
          ),
        ),
      ],
    );
  }

  // !=======

  void showColorSelectionDialog(
    BuildContext context,
    DynamicFieldModel field,
    ProductProvider provider,
  ) {
    final category = provider.selectedCategoryModel;
    List<Map<String, String>> availableColors = [];
    // final initialValue = provider.getDynamicFieldValue(field.id);

    if (category != null) {
      DynamicFieldModel? colorField;
      for (final f in category.dynamicFields) {
        if (f.type == DynamicFieldType.dropdown) {
          final label = f.label.toLowerCase();
          final optsLower = f.options.map((o) => o.toLowerCase()).toList();
          if (f.id == 'color' ||
              label.contains('color') ||
              optsLower.any((o) => o.contains('color'))) {
            colorField = f;
            break;
          }
        }
      }

      if (colorField != null && colorField.options.isNotEmpty) {
        for (final opt in colorField.options) {
          if (opt.contains(':')) {
            final parts = opt.split(':');
            final name = parts[0].trim();
            final code = parts.length > 1 ? parts[1].trim() : '#000000';
            availableColors.add({'name': name, 'code': code});
          } else {
            final name = opt.trim();
            final hex = simpleColorLookup(name) ?? '#000000';
            availableColors.add({'name': name, 'code': hex});
          }
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select a Color Variant'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableColors.length,
              itemBuilder: (context, index) {
                final color = availableColors[index];
                final code = (color['code'] ?? '#000000').replaceAll(
                  '#',
                  '0xFF',
                );

                return ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(int.parse(code)),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  title: Text(color['name'] ?? ''),
                  trailing:
                      provider.productVariants.any(
                        (v) => v.colorName == color['name'],
                      )
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.add_circle_outline),
                  onTap:
                      provider.productVariants.any(
                        (v) => v.colorName == color['name'],
                      )
                      ? null
                      : () {
                          provider.addColorVariant(
                            color['name'] ?? '',
                            color['code'] ?? '#000000',
                          );
                          Navigator.of(dialogContext).pop();
                        },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ! ==========()=========
  String? simpleColorLookup(String name) {
    final n = name.toLowerCase();
    const map = {
      'red': '#FF0000',
      'blue': '#0000FF',
      'green': '#00FF00',
      'black': '#000000',
      'white': '#FFFFFF',
      'yellow': '#FFFF00',
      'orange': '#FFA500',
      'pink': '#FFC0CB',
      'purple': '#800080',
      // add as needed
    };
    return map[n];
  }
}
