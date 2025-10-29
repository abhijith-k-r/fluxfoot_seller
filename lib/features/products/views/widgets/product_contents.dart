import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/firebase/services/product_firebase_services.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/dropdown_menu_items.dart';

// ! Product Contens / Details inside List view Seperator.
Container productsContents(
  double size,
  ProductModel product,
  ProductFirebaseServices productService,
  ProductProvider productProvider,
) {
  return Container(
    width: double.infinity,
    height: 40,
    decoration: BoxDecoration(
      color: WebColors.bgWiteShade,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: size * 0.15,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: size * 0.02,
                  height: size * 0.02,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: BoxBorder.all(color: WebColors.borderSideOrange),
                  ),
                  child: (product.images.isEmpty || product.images[0].isEmpty)
                      ? Icon(Icons.upload_file)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product.images[0],
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                customText(15, product.name, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),

        SizedBox(
          width: size * 0.15,
          child: Center(
            child: customText(
              15,
              product.status.toLowerCase() == 'active' ? 'Active' : 'InActive',
              webcolors: product.status == 'active'
                  ? WebColors.succesGreen
                  : WebColors.errorRed,
            ),
          ),
        ),

        SizedBox(
          width: size * 0.15,
          child: Center(
            child: Center(child: customText(15, product.createdAt.toString())),
          ),
        ),

        // ! Show Menu
        SizedBox(
          width: size * 0.15,
          child: CircleAvatar(
            backgroundColor: WebColors.buttonPurple,
            // ! Drop Down Item Showing
            child: buildDropDownActionItems(
              product,
              productService,
              productProvider,
            ),
          ),
        ),
      ],
    ),
  );
}
