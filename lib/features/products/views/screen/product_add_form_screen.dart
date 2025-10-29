// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_back_button.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/addedit_product_image.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/form_elements.dart';
import 'package:provider/provider.dart';

class ProductAddFormScreen extends StatelessWidget {
  const ProductAddFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    return Dialog(
      child: Container(
        width: size * 0.7,
        height: size * 0.7,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            // ! Custom Back BUTTON
            customBackButton(context),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ! Selecting Product Image Helper Function
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Consumer<ProductProvider>(
                            builder: (context, provider, child) =>
                                buildAddEditProductImage(
                                  size: size,
                                  imageUrls: provider.normalImageUrls,
                                  title: 'PNG IMAGES',
                                  onAddTap: () =>
                                      provider.pickAndUploadImages(),
                                  onRemove: (index) =>
                                      provider.removeImageAt(index),
                                ),
                          ),
                        ),

                        SizedBox(width: 20),
                        //! **3D IMAGES (Right)**
                        Expanded(
                          child: Container(),
                          // child: Consumer<ProductProvider>(
                          //   builder: (context, provider, child) =>
                          //       buildAddEditProductImage(
                          //         size: size,
                          //         title: '3D Images',
                          //         // Assuming you add these lists/methods to ProductProvider
                          //         imageUrls: provider.imageUrls,
                          //         onAddTap: () =>
                          //             provider.pickAndUploadImages(),
                          //         onRemove: (index) =>
                          //             provider.removeImageAt(index),
                          //       ),
                          // ),
                        ),
                      ],
                    ),
                    SizedBox(height: size * 0.01),
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
                                // !! Color Text Form Field
                                buildTextField(
                                  context,
                                  'Colors',
                                  'eg: Red',
                                  productProvider.colorsController,
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
                                // ! QUANTITY TEXT FORM FIELD
                                buildTextField(
                                  context,
                                  'Quantity',
                                  'eg: 10',
                                  productProvider.quantityController,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // !Add Product Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          addProductSubmit(context, productProvider);
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
                          'Add Product',
                          webcolors: WebColors.textWite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
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

// !  asdfghj+====== ===(====)

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
      productProvider.salePriceController.text.isEmpty ||
      productProvider.colorsController.text.isEmpty ||
      productProvider.quantityController.text.isEmpty) {
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
    quantity: productProvider.quantityController.text,
    category: categoryName,
    color: productProvider.colorsController.text,
    brand: brandName,
  );
  productProvider.nameController.clear();
  productProvider.descriptionController.clear();
  productProvider.regPriceController.clear();
  productProvider.salePriceController.clear();
  productProvider.quantityController.clear();
  productProvider.colorsController.clear();
  productProvider.clearSelections();

  showOverlaySnackbar(
    context,
    'Successfully Added Product',
    WebColors.succesGreen,
  );
  Navigator.pop(context);
}
