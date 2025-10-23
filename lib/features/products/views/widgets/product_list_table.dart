import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/firebase/services/product_firebase_services.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/custom_text.dart';
import 'package:fluxfoot_seller/features/products/view_model/provider/product_provider.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/product_contents.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/product_title_contents.dart';
import 'package:fluxfoot_seller/features/products/views/widgets/search_formfield_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ProductListTable extends StatelessWidget {
  const ProductListTable({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final productProvider = Provider.of<ProductProvider>(context);
    final productService = ProductFirebaseServices();
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(18, 'Existing Brands', fontWeight: FontWeight.bold),
                // ! Search Form Field
                customSearchForm(size, productProvider),
              ],
            ),
            const Divider(height: 32),
            // ! BRAND TITLE
            buildTitleContents(size),
            SizedBox(height: 10),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.isLoading &&
                      productProvider.products.isEmpty) {
                    return Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: WebColors.activeOrange,
                        size: size * 0.10,
                      ),
                    );
                  }
                  final products = productProvider.products;
                  if (products.isEmpty) {
                    return Center(
                      child: customText(16, 'No Products added yet.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      // ! Brand Detaisl (Contents / from Firebase) CONTAINER
                      return productsContents(
                        size,
                        product,
                        productService,
                        productProvider,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
