import 'package:fluxfoot_seller/features/products/model/sizequantity_model.dart';

class ColorvariantModel {
  String colorName;
  String colorCode;
  List<String> imageUrls;
  List<SizeQuantityVariant> sizes;

  ColorvariantModel({
    required this.colorName,
    this.colorCode = '#000000',
    this.imageUrls = const [],
    this.sizes = const [],
  });

  Map<String, dynamic> toMap() => {
    'colorName': colorName,
    'colorCode': colorCode,
    'imageUrls': imageUrls,
    'sizes': sizes.map((s) => s.toMap()).toList(),
  };

  factory ColorvariantModel.fromMap(Map<String, dynamic> map) {
    return ColorvariantModel(
      colorName: map['colorName'] ?? '',
      colorCode: map['colorCode'] ?? '#000000',
      imageUrls:
          (map['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sizes:
          (map['sizes'] as List<dynamic>?)
              ?.map(
                (e) => SizeQuantityVariant.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
    );
  }
}
