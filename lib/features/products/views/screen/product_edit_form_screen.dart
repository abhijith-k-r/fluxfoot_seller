// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_back_button.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/product_dynamicfield_section.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/product_variant_section.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/productadddform_left_form_colum.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/productaddform_right_form_colum.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/producteditform_edit_button.dart';
import 'package:provider/provider.dart';

class ProductEditFormScreen extends StatelessWidget {
  final ProductModel product;
  const ProductEditFormScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    Future.microtask(() {
      productProvider.initializeForEdit(product);
    });

    return Dialog(
      child: Container(
        width: size * 0.7,
        height: size * 0.7,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: size * 0.01,
                right: size * 0.01,
                bottom: size * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customText(
                    18,
                    'Create New Product',
                    fontWeight: FontWeight.bold,
                    webcolors: WebColors.textBlack,
                  ),
                  customBackButton(context),
                ],
              ),
            ),
            //  ! New Thing Vannu In My MInd
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ! Two Column Layout Product adding
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // !LEFT COLUMN FORM FIELD
                        buildLeftColumForm(context, productProvider),

                        //! RIGHT COLUMN FORM FIELD
                        buildRighColumFormField(context, productProvider),
                      ],
                    ),

                    // ! DYNAMIC FIELDS
                    const SellerDynamicFieldsSection(),

                    // ! VARIANTS
                    const ProductVariantSection(),

                    // !Add Product Button
                    buildEditProductButton(productProvider, context, product),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
