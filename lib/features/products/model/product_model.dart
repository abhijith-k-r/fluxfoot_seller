import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String regularPrice;
  final String salePrice;
  final String quantity;
  final String? color;
  final String category;
  final String brand;
  final String? imageUrl;
  final String status;
  final String sellerId;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.regularPrice,
    required this.salePrice,
    required this.quantity,
    this.color,
    required this.category,
    required this.brand,
    this.imageUrl,
    required this.status,
    required this.sellerId,
    required this.createdAt,
    String? logoUrl,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      regularPrice: data['regularPrice'] ?? '',
      salePrice: data['salePrice'] ?? '',
      quantity: data['quantity'] ?? '',
      color: data['color'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? '',
      sellerId: data['sellerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
      'color': color,
      'brand': brand,
      'imageUrl': imageUrl,
      'status': status,
      'sellerId': sellerId,
      'createdAt': createdAt,
    };
  }
}
