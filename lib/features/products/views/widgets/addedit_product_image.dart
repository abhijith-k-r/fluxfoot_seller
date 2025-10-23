// ! Brand LOGO Adding Widget
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:provider/provider.dart';

Widget buildAddEditProductImage(double size) {
  return Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
      return Stack(
        alignment: AlignmentGeometry.topRight,
        children: [
          GestureDetector(
            onTap: () => productProvider.pickAndUploadLogo(),
            child: Container(
              width: size * 0.2,
              height: size * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: BoxBorder.all(color: WebColors.borderSideGrey),
              ),
              child: productProvider.selectedLogoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        productProvider.selectedLogoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file),
                        customText(
                          15,
                          productProvider.selectedLogoUrl != null
                              ? ' Logo Selected'
                              : 'Upload Logo',
                        ),
                      ],
                    ),
            ),
          ),
          IconButton(
            onPressed: () => productProvider.clearSelectedLogoUrl(),
            icon: CircleAvatar(
              radius: 10,
              backgroundColor: WebColors.iconGrey,
              child: Icon(Icons.close, color: WebColors.iconWhite, size: 15),
            ),
          ),
        ],
      );
    },
  );
}
