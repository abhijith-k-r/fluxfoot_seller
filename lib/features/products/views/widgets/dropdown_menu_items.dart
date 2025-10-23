import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/firebase/services/product_firebase_services.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/show_helper_function.dart';

// ! DROP DOWN WIDGET FOR EDIT|| BLOCK || DELETE
Widget buildDropDownActionItems(
  ProductModel product,
  ProductFirebaseServices productService,
  ProductProvider productProvider,
) {
  return PopupMenuButton<String>(
    icon: Icon(Icons.more_vert, color: WebColors.iconGrey),

    itemBuilder: (context) => <PopupMenuEntry<String>>[
      // ! FOR EDIT
      PopupMenuItem<String>(
        value: 'edit',
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
            //! Execute the 'Edit' functionality
            showEditProductModal(context, product);
          },
          child: customText(15, 'Edit', webcolors: WebColors.buttonPurple),
        ),
      ),

      // !For BLOCK AND UNBLOCK
      product.status == 'active'
          ? PopupMenuItem<String>(
              value: 'block',
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // !Execute the 'Block' functionality
                  productService.updateProductStatus(context, product, 'Block');
                },
                child: customText(15, 'Block', webcolors: WebColors.errorRed),
              ),
            )
          : PopupMenuItem<String>(
              value: 'unblock',
              child: TextButton(
                onPressed: () {
                  // Close the menu
                  Navigator.pop(context);
                  //! Execute the 'UnBlock' functionality
                  productService.updateProductStatus(
                    context,
                    product,
                    'UnBlock',
                  );
                },
                child: customText(
                  15,
                  'UnBlock',
                  webcolors: WebColors.succesGreen,
                ),
              ),
            ),

      // ! For DELETE
      PopupMenuItem<String>(
        child: TextButton(
          onPressed: () {
            productProvider.deleteProduct(product);
            Navigator.pop(context);
          },
          child: customText(15, 'Delete', webcolors: WebColors.errorRed),
        ),
      ),
    ],
    onSelected: (String result) {},
  );
}
