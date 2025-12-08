// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';

// ! EDIT PRODUCT BUTTON
Widget buildEditProductButton(
  ProductProvider productProvider,
  BuildContext context,
  ProductModel  product
) {
  return Align(
    alignment: Alignment.bottomRight,
    child: ElevatedButton(
      onPressed: () async {
        final brandId = productProvider.selectedBrandId;
        final categoryId = productProvider.selectedCategoryId;

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
          return;
        }

        await productProvider.updateExistingProduct(
          id: product.id,
          name: productProvider.nameController.text,
          images: productProvider.allImageUrls,
          description: productProvider.descriptionController.text.isEmpty
              ? null
              : productProvider.descriptionController.text,
          regularPrice: productProvider.regPriceController.text,
          salePrice: productProvider.salePriceController.text,
          quantity: productProvider.quantityController.text,
          category: categoryName,
          color: null,
          brand: brandName,
        );

        showOverlaySnackbar(
          context,
          'Successfully Updated Product',
          WebColors.succesGreen,
        );
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: WebColors.buttonPurple,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: customText(
        16,
        'Save Changes',
        webcolors: WebColors.textWite,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
