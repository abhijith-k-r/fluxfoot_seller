// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';

// !  Add Product Submit Logic
void addProductSubmit(
  BuildContext context,
  ProductProvider productProvider,
) async {
  //! Get the IDs selected by the dropdown
  final brandId = productProvider.selectedBrandId ?? '';
  final categoryId = productProvider.selectedCategoryId ?? '';

  //! Look up the actual Name using the new helper function (assuming you've implemented it)
  final brandName = await productProvider.getNameFromId(
    brandId,
    productProvider.brandsFuture,
  );
  final categoryName = await productProvider.getNameFromId(
    categoryId,
    productProvider.categoriesFuture,
  );

  if (brandName == null || categoryName == null) {
    showOverlaySnackbar(
      context,
      'brand/category must be selected',
      WebColors.errorRed,
    );

    debugPrint('Error: Brand or Category name not found. Check selection.');
    return;
  }

  // Check required fields again (your existing logic)
  if (productProvider.nameController.text.isEmpty ||
      productProvider.regPriceController.text.isEmpty ||
      productProvider.salePriceController.text.isEmpty) {
    showOverlaySnackbar(
      context,
      'All Fields Must Be Filled',
      WebColors.errorRed,
    );
    return;
  }

  await productProvider.addProduct(
    images: productProvider.normalImageUrls,
    name: productProvider.nameController.text,
    description: productProvider.descriptionController.text,
    regularPrice: productProvider.regPriceController.text,
    salePrice: productProvider.salePriceController.text,
    quantity: productProvider.quantityController.text.isNotEmpty
        ? productProvider.quantityController.text
        : '0',
    category: categoryName,
    brand: brandName,
    dynammicSpecs: productProvider.dynamicFieldValues,
  );
  productProvider.nameController.clear();
  productProvider.descriptionController.clear();
  productProvider.regPriceController.clear();
  productProvider.salePriceController.clear();
  productProvider.quantityController.clear();
  productProvider.colorsController.clear();
  productProvider.dynamicFieldValues.clear();
  productProvider.clearSelections();

  showOverlaySnackbar(
    context,
    'Successfully Added Product',
    WebColors.succesGreen,
  );
  Navigator.pop(context);
}
