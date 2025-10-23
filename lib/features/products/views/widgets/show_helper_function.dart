import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
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
