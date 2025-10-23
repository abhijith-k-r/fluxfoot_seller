import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/product_list_table.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/show_helper_function.dart';

class ProductManageScreen extends StatelessWidget {
  const ProductManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 10,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              showAddProductModal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.buttonPurple,
              foregroundColor: WebColors.textWite,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add New Brand'),
          ),
          // ! Products Table
          Expanded(child: ProductListTable()),
        ],
      ),
    );
  }
}
