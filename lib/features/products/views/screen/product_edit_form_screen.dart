// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_back_button.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/form_elements.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/product_dynamicfield_section.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/product_variant_section.dart';
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
                        Expanded(
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
                        ),

                        //! RIGHT COLUMN FORM FIELD
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ! B R A N D S \\ DROP DOWN
                                Consumer<ProductProvider>(
                                  builder: (context, value, child) {
                                    return buildDropdownField(
                                      context: context,
                                      label: 'Brands',
                                      hint: '',
                                      itemsFuture: value.brandsFuture,
                                      selectedValue: value.selectedBrandId,
                                      onChanged: (newId) {
                                        value.selectedBrandId = newId;
                                      },
                                    );
                                  },
                                ),

                                // ! C A T E G O R I E S \\ DROP DOWN
                                Consumer<ProductProvider>(
                                  builder: (context, value, child) {
                                    return buildDropdownField(
                                      context: context,
                                      label: 'Categories',
                                      hint: '',
                                      itemsFuture: value.categoriesFuture,
                                      selectedValue: value.selectedCategoryId,
                                      onChanged: (newId) {
                                        value.selectedCategoryId = newId;
                                      },
                                    );
                                  },
                                ),

                                // !  SALE PRIZE
                                buildTextField(
                                  context,
                                  'Sale Price',
                                  'eg: ₹ 100/-',
                                  productProvider.salePriceController,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ! DYNAMIC FIELDS
                    const SellerDynamicFieldsSection(),

                    // ! VARIANTS
                    const ProductVariantSection(),

                    // !Add Product Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final brandId = productProvider.selectedBrandId;
                          final categoryId = productProvider.selectedCategoryId;

                          final brandName = await productProvider.getNameFromId(
                            brandId,
                            productProvider.brandsFuture,
                          );
                          final categoryName = await productProvider
                              .getNameFromId(
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
                            description:
                                productProvider
                                    .descriptionController
                                    .text
                                    .isEmpty
                                ? null
                                : productProvider.descriptionController.text,
                            regularPrice:
                                productProvider.regPriceController.text,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: customText(
                          16,
                          'Save Changes',
                          webcolors: WebColors.textWite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
