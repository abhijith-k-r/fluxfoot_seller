import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_back_button.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/addedit_product_image.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/form_elements.dart';
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
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(
      text: product.description,
    );
    final regPriceController = TextEditingController(
      text: product.regularPrice,
    );
    final salePriceController = TextEditingController(text: product.salePrice);
    final colorsController = TextEditingController(text: product.color);
    final quantityController = TextEditingController(text: product.quantity);

    Future.microtask(() {
      productProvider.setInitialLogoUrl(product.imageUrl);

      productProvider.initializeForEdit(product);
    });
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ! Selecting Product Image Helper Function
                buildAddEditProductImage(size),
                SizedBox(height: size * 0.01),
                // ! Two Column Layout Product adding
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // !LEFT COLUMN FORM FIELD
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildTextField(
                                  context,
                                  'Product Name',
                                  'eg: Jercey',
                                  nameController,
                                ),
                                buildTextArea(
                                  context,
                                  'Full Description',
                                  '',
                                  descriptionController,
                                ),
                                buildTextField(
                                  context,
                                  'Regular Price',
                                  "eg: ₹ 100/-",
                                  regPriceController,
                                ),
                                buildTextField(
                                  context,
                                  'Sale Price',
                                  'eg: ₹ 100/-',
                                  salePriceController,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      //! RIGHT COLUMN FORM FIELD
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SingleChildScrollView(
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
                                  colorsController,
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
                                  quantityController,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // !Add Product Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // !addProductSubmit(context, productProvider);
                      updateProductSubmit(
                        context,
                        productProvider,
                        product,
                        nameController,
                        descriptionController,
                        regPriceController,
                        salePriceController,
                        colorsController,
                        quantityController,
                      );
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
          ],
        ),
      ),
    );
  }
}

void updateProductSubmit(
  BuildContext context,
  ProductProvider productProvider,
  ProductModel originalProduct,
  TextEditingController nameController,
  TextEditingController descriptionController,
  TextEditingController regPriceController,
  TextEditingController salePriceController,
  TextEditingController colorsController,
  TextEditingController quantityController,
) async {
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

  await productProvider.updateExistingProduct(
    id: originalProduct.id,
    name: nameController.text,
    description: descriptionController.text.isEmpty
        ? null
        : descriptionController.text,
    regularPrice: regPriceController.text,
    salePrice: salePriceController.text,
    quantity: quantityController.text,
    category: categoryName!,
    color: colorsController.text.isEmpty ? null : colorsController.text,
    brand: brandName!,
    logoUrl: productProvider.selectedLogoUrl,
  );

  showOverlaySnackbar(
    context,
    'Successfully Updated Product',
    WebColors.succesGreen,
  );
  Navigator.pop(context);
}
