import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/form_elements.dart';

// ! Right Form Colum
Widget buildLeftColumForm(
  BuildContext context,
  ProductProvider productProvider,
) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextField(
            context,
            'Product Name',
            'eg: Jercey',
            productProvider.nameController,
          ),
          buildTextArea(
            context,
            'Full Description',
            '',
            productProvider.descriptionController,
          ),
          buildTextField(
            context,
            'Regular Price',
            "eg: ₹ 100/-",
            productProvider.regPriceController,
          ),
        ],
      ),
    ),
  );
}
