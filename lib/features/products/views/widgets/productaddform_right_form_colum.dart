import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/form_elements.dart';
import 'package:provider/provider.dart';

// ! RIGHT COLUMN FORM FIELD
Widget buildRighColumFormField(
  BuildContext context,
  ProductProvider productProvider,
) {
  return Expanded(
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
  );
}
