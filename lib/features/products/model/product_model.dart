import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluxfoot_seller/features/products/model/colorvariant_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String regularPrice;
  final String salePrice;
  final String quantity;
  final String category;
  final String brand;
  final List<String> images;
  final String status;
  final String sellerId;
  final DateTime createdAt;
  final Map<String, dynamic> dynamicSpecs;
  final List<ColorvariantModel> variants;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.regularPrice,
    required this.salePrice,
    required this.quantity,
    required this.category,
    required this.brand,
    required this.images,
    required this.status,
    required this.sellerId,
    required this.createdAt,
    this.dynamicSpecs = const {},
    this.variants = const [],
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    var imagesData = data['images'];
    List<String> imagesList;

    if (imagesData == null) {
      imagesList = [];
    } else if (imagesData is String) {
      imagesList = [imagesData];
    } else if (imagesData is Iterable) {
      imagesList = List<String>.from(imagesData);
    } else {
      imagesList = [];
    }

    // Read variants safely
    final variantsRaw = data['variants'] as List<dynamic>? ?? [];
    final variantsList = variantsRaw
        .map(
          (e) => ColorvariantModel.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      regularPrice: data['regularPrice'] ?? '',
      salePrice: data['salePrice'] ?? '',
      quantity: data['quantity'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      images: imagesList,
      status: data['status'] ?? '',
      sellerId: data['sellerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dynamicSpecs: data['dynamicSpecs'] as Map<String, dynamic>? ?? {},
      variants: variantsList,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'name': name,
      'description': description,
      'regularPrice': regularPrice,
      'salePrice': salePrice,
      'quantity': quantity,
      'category': category,
      'brand': brand,
      'images': images,
      'status': status,
      'sellerId': sellerId,
      'createdAt': createdAt,
      'dynamicSpecs': dynamicSpecs,
      'variants': variants.map((v) => v.toMap()).toList(),
    };
  }
}
