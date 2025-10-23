// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';
import 'package:fluxfoot_seller/features/products/model/dropdown_model.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';

class ProductFirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  //! Function to fetch data from Firestore
  Future<List<DropdownItemModel>> fetchDropdownData(
    String collectionName,
  ) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .get();

    return snapshot.docs
        .map(
          (doc) => DropdownItemModel(
            id: doc.id,
            name:
                doc.data()['name'] ?? '',
                    
          ),
        )
        .toList();
  }

      // ! Adding a Product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').add(product.toFireStore());
      debugPrint('Category added successfully to Firestore!');
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

       // ! Streaming products (Read)
  Stream<List<ProductModel>> readproducts(String sellerId) {
    return _firestore.collection('products').where('sellerId',isEqualTo: sellerId).
    snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }


  // ! Updating a Product
  Future<void> updateProduct(ProductModel product) async {
    try {
      if (product.id.isEmpty) {
        throw Exception('product ID is required for updating');
      }

      _firestore.collection('products').doc(product.id).update(product.toFireStore());
      debugPrint('product updated successfully: ${product.name}');
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }


   // ! Update Category Status (Block / Activ)
  Future<void> updateProductStatus(
    BuildContext context,
    ProductModel product,
    String newStatus,
  ) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('products').doc(product.id).update({
        'status': newStatus.toLowerCase(),
      });

      String finalStatus = newStatus == 'Block' ? 'blocked' : 'active';

      await firestore.collection('products').doc(product.id).update({
        'status': finalStatus,
      });
      String snackbarMessage = newStatus == 'Block'
          ? '${product.name} Blocked successfully!'
          : '${product.name} Unblocked successfully!';
      if (context.mounted) {
        showOverlaySnackbar(
          context,
          snackbarMessage,
          newStatus == 'UnBlock'
              ? WebColors.succesGreen
              : WebColors.errorRed,
        );
      }
    } catch (e) {
      showOverlaySnackbar(
        context,
        'Error updating brand status',
        WebColors.errorRed,
      );
    }
  }

  // ! Delete products
  Future<void> deleteProduct(ProductModel brand) async {
    try {
      await _firestore.collection('products').doc(brand.id).delete();
      debugPrint('Product deleted successfully: ${brand.name}');
    } catch (e) {
      throw Exception('Failed to delete Product: $e');
    }
  }

}
