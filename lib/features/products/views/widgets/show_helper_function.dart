import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/features/products/model/dynamicfield_model.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/screen/product_add_form_screen.dart';
import 'package:fluxfoot_seller/features/products/views/screen/product_edit_form_screen.dart';

// ! ---- ADD PRODUCT SHOWING MODAL HELPER FUNCTION ======
showAddProductModal(BuildContext context) {
  showDialog(context: context, builder: (context) => ProductAddFormScreen());
}

showEditProductModal(BuildContext context, ProductModel product) {
  showDialog(
    context: context,
    builder: (context) => ProductEditFormScreen(product: product),
  );
}

// ! Show Add SizeQuantity Dialog

void showAddSizeDialog(
  BuildContext context,
  ProductProvider provider,
  String colorName,
  DynamicFieldModel sizeField,
) {
  final existingSizes = provider.productVariants
      .firstWhere((v) => v.colorName == colorName)
      .sizes
      .map((s) => s.size.trim().toLowerCase())
      .toSet();

  // Filter available options
  final availableOptions = sizeField.options
      .map((o) => o.trim())
      .where((opt) => !existingSizes.contains(opt.toLowerCase()))
      .toList();

  if (availableOptions.isEmpty) {
    // Show a simple snackbar or dialog if no sizes are available
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All available sizes have been added.')),
    );
    return;
  }

  // Show the dialog with available sizes
  showDialog(
    context: context,
    builder: (context) {
      final size = MediaQuery.of(context).size.width;
      return AlertDialog(
        title: const Text('Select Size to Add'),
        content: SizedBox(
          width: size * 0.1,
          child: ListView(
            shrinkWrap: true,
            children: availableOptions.map((sizeOption) {
              return ListTile(
                title: Text(sizeOption),
                onTap: () {
                  // CRITICAL STEP: Add the size with a default quantity (e.g., 1)
                  provider.addSizeToVariant(colorName, sizeOption, 1);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: WebColors.textBlack)),
          ),
        ],
      );
    },
  );
}
