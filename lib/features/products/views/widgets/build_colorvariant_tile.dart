import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/products/model/colorvariant_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/product_variant_section.dart';

Widget buildColorVariantTile(
  BuildContext context,
  ProductProvider provider,
  ColorvariantModel variant,
) {
  // Use a standard Flutter ExpansionTile or a custom widget for the exact UI feel
  return ExpansionTile(
    leading: Container(
      // Small colored circle
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Color(int.parse(variant.colorCode.replaceAll('#', '0xFF'))),
        shape: BoxShape.circle,
      ),
    ),
    title: Text('Color: ${variant.colorName}'),
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Upload Area (Grid view of images)
            customText(14, 'Images for ${variant.colorName} Variant'),

            // ... Add your image picking/display logic here
            // This logic must call a provider method like:
            // provider.addImageToVariant(variant.colorName, newImageUrl)
            const SizedBox(height: 16),

            // 2. Size/Quantity Table (The heart of the variant system)
            buildSizeQuantityTable(context, provider, variant),

            // Button to ADD another SIZE/Quantity to this color variant
            ElevatedButton(
              onPressed: () =>
                  showSizeInput(context, provider, variant.colorName),
              child: const Text('Add Size/Quantity'),
            ),
          ],
        ),
      ),
    ],
  );
}
