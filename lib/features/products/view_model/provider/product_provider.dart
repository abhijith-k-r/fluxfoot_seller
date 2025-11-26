// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/firebase/services/product_firebase_services.dart';
import 'package:fluxfoot_seller/features/products/model/category_model.dart';
import 'package:fluxfoot_seller/features/products/model/colorvariant_model.dart';
import 'package:fluxfoot_seller/features/products/model/dropdown_model.dart';
import 'package:fluxfoot_seller/features/products/model/dynamicfield_model.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
import 'package:fluxfoot_seller/features/products/model/sizequantity_model.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider extends ChangeNotifier {
  final _productFirebaseServices = ProductFirebaseServices();
  final _auth = FirebaseAuth.instance;

  String? _selectedBrandId;
  String? _selectedCategoryId;
  String? _selectedBrandName;
  String? _selectedCategoryName;

  late Future<List<DropdownItemModel>> _brandsFuture;
  late Future<List<DropdownItemModel>> _categoriesFuture;

  bool _isLoading = false;
  List<ProductModel> _products = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _regPriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  String _searchTerm = '';
  // String? _logoUrl;
  List<String> _normalImageUrls = [];
  List<String> _threeDImageUrls = [];
  final String _isActive = '';
  final cloudinary = CloudinaryPublic('dryij9oei', 'sr_default', cache: false);

  CategoryModel? _selectedCategoryModel;
  final Map<String, dynamic> _dynamicFieldValues = {};

  String? get selectedBrandId => _selectedBrandId;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedBrandName => _selectedBrandName;
  String? get selectedCategoryName => _selectedCategoryName;

  Future<List<DropdownItemModel>> get brandsFuture => _brandsFuture;
  Future<List<DropdownItemModel>> get categoriesFuture => _categoriesFuture;

  String? get currentSellerId => _auth.currentUser?.uid;

  bool get isLoading => _isLoading;
  TextEditingController get nameController => _nameController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get regPriceController => _regPriceController;
  TextEditingController get salePriceController => _salePriceController;
  TextEditingController get colorsController => _colorsController;
  TextEditingController get quantityController => _quantityController;
  TextEditingController get searchController => _searchController;
  // String? get selectedLogoUrl => _logoUrl;
  List<String> get normalImageUrls => _normalImageUrls;
  List<String> get threeDImageUrls => _threeDImageUrls;
  // Get ALL image URLs combined for submission to Firestore
  List<String> get allImageUrls => [..._normalImageUrls, ..._threeDImageUrls];
  String get isActive => _isActive;

  CategoryModel? get selectedCategoryModel => _selectedCategoryModel;
  Map<String, dynamic> get dynamicFieldValues => _dynamicFieldValues;

  dynamic getDynamicFieldValue(String fieldId) => _dynamicFieldValues[fieldId];

  //! --- SETTERS (MUST CALL notifyListeners) ---
  set selectedBrandId(String? newId) {
    if (_selectedBrandId != newId) {
      _selectedBrandId = newId;

      _updateSelectedName(_brandsFuture, newId, (name) {
        _selectedBrandName = name;
      });
      notifyListeners();
    }
  }

  set selectedCategoryId(String? newId) {
    if (_selectedCategoryId == newId) return;

    _selectedCategoryId = newId;
    _selectedCategoryModel = null;
    _selectedCategoryName = null;
    _dynamicFieldValues.clear();
    productVariants.clear();

    notifyListeners();

    if (newId != null) {
      fetchCategoryModel(newId)
          .then((categoryModel) async {
            if (categoryModel != null) {
              _selectedCategoryModel = categoryModel;

              for (var field in categoryModel.dynamicFields) {
                if (field.type == DynamicFieldType.boolean) {
                  _dynamicFieldValues[field.id] = 'false';
                }
              }

              _updateSelectedName(_categoriesFuture, newId, (name) {
                _selectedCategoryName = name;
              });
            } else {
              _selectedCategoryModel = null;
              _selectedCategoryName = null;
            }

            notifyListeners();
          })
          .catchError((error) {
            debugPrint('Error fetching category model in setter: $error');
            _selectedCategoryModel = null;
            _selectedCategoryName = null;
            notifyListeners();
          });
    } else {
      _selectedCategoryName = null;
    }
  }

  // ! ===== ======= ()======================
  List<ColorvariantModel> productVariants = [];

  void addColorVariant(String colorName, String colorCode) {
    // Check if color already exists
    if (!productVariants.any((v) => v.colorName == colorName)) {
      productVariants.add(
        ColorvariantModel(
          colorName: colorName,
          colorCode: colorCode,
          imageUrls: [],
          sizes: [],
        ),
      );
      notifyListeners();
    }
  }

  void removeColorVariant(String colorName) {
    productVariants.removeWhere((v) => v.colorName == colorName);
    notifyListeners();
  }

  void removeSizeFromVariant(String colorName, String size) {
    final idx = productVariants.indexWhere((v) => v.colorName == colorName);
    if (idx == -1) return;

    final variant = productVariants[idx];
    final newSizes = variant.sizes
        .where((s) => s.size.trim().toLowerCase() != size.trim().toLowerCase())
        .toList();

    productVariants[idx] = ColorvariantModel(
      colorName: variant.colorName,
      colorCode: variant.colorCode,
      imageUrls: variant.imageUrls,
      sizes: newSizes,
    );
    notifyListeners();
  }

  void addSizeToVariant(String colorName, String size, int quantity) {
    final index = productVariants.indexWhere((v) => v.colorName == colorName);
    if (index == -1) return;

    final variant = productVariants[index];
    final normalized = size.trim();

    final sizeIndex = variant.sizes.indexWhere(
      (s) => s.size.trim().toLowerCase() == normalized.toLowerCase(),
    );

    final List<SizeQuantityVariant> newSizes = List.from(variant.sizes);

    if (quantity <= 0) {
      if (sizeIndex != -1) {
        variant.sizes.removeAt(sizeIndex);
      }
    } else {
      if (sizeIndex != -1) {
        newSizes[sizeIndex] = SizeQuantityVariant(
          size: size,
          quantity: quantity,
        );
      } else {
        newSizes.add(SizeQuantityVariant(size: normalized, quantity: quantity));
      }
    }

    productVariants[index] = ColorvariantModel(
      colorName: variant.colorName,
      colorCode: variant.colorCode,
      imageUrls: variant.imageUrls,
      sizes: newSizes,
    );

    notifyListeners();
  }

  //! Helper method to look up the name from the Future list
  void _updateSelectedName(
    Future<List<DropdownItemModel>> futureList,
    String? id,
    Function(String? name) onNameFound,
  ) async {
    if (id == null) {
      onNameFound(null);
      return;
    }

    try {
      final list = await futureList;
      final selectedItem = list.firstWhere(
        (item) => item.id == id,
        orElse: () => DropdownItemModel(id: '', name: 'Unknown'),
      );

      onNameFound(selectedItem.name == 'Unknown' ? null : selectedItem.name);
    } catch (e) {
      debugPrint('Error finding name for ID $id: $e');
      onNameFound(null);
    }
  }

  // ! filtered list based on the search term
  List<ProductModel> get products {
    if (_searchTerm.isEmpty) {
      return _products;
    }

    return _products.where((brand) {
      return brand.name.toLowerCase().contains(_searchTerm.toLowerCase());
    }).toList();
  }

  void onSearchTermChanged(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  ProductProvider() {
    _brandsFuture = _productFirebaseServices.fetchDropdownData('brands');
    _categoriesFuture = _productFirebaseServices.fetchDropdownData(
      'categories',
    );

    final sellerId = currentSellerId;
    if (sellerId != null) {
      _productFirebaseServices.readproducts(sellerId).listen((productList) {
        productList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _products = productList;

        _searchController.addListener(() {
          onSearchTermChanged(_searchController.text);
        });

        notifyListeners();
      });
    } else {
      _products = [];
      debugPrint('ProductProvider initialized with no logged-in seller.');
    }
  }

  // !========(======)=========Add an image URL to a specific color variant

  void addImgeToVariant(String colorName, String imageUrl) {
    final idx = productVariants.indexWhere((v) => v.colorName == colorName);

    if (idx == -1) return;
    final variant = productVariants[idx];
    variant.imageUrls = [...variant.imageUrls, imageUrl];
    notifyListeners();
  }

  //! Remove image URL from a specific color variant
  void removeImageFromVariant(String colorName, String imageUrl) {
    final idx = productVariants.indexWhere((v) => v.colorName == colorName);
    if (idx == -1) return;
    final varint = productVariants[idx];
    varint.imageUrls = varint.imageUrls.where((u) => u != imageUrl).toList();
    notifyListeners();
  }

  // !Pick and upload images for a specific variant (uses your existing Cloudinary logic)
  Future<void> pickAndUpladImagesForVariant(String colorName) async {
    if (_isLoading) return;

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    for (var imgFile in pickedFiles) {
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imgFile.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        addImgeToVariant(colorName, response.secureUrl);
      } catch (e) {
        debugPrint('Error uploading image for variant $colorName: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // ! To Pick and Upload image
  Future<void> pickAndUploadImages() async {
    if (_isLoading) return;

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    for (var imgFile in pickedFiles) {
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imgFile.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );

        _normalImageUrls.add(response.secureUrl);
      } catch (e) {
        debugPrint('Error uploading image: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  // ! Remove Images At Index
  void removeImageAt(int index) {
    _normalImageUrls.removeAt(index);
    notifyListeners();
  }

  // ! Clear Selected Logo Url
  void clearSelectedImages() {
    _normalImageUrls.clear();
    _threeDImageUrls.clear();
    notifyListeners();
  }

  //! New helper function to get the name from the ID at the time of submission
  Future<String?> getNameFromId(
    String? id,
    Future<List<DropdownItemModel>> futureList,
  ) async {
    if (id == null) return null;

    try {
      final list = await futureList;
      final selectedItem = list.firstWhere(
        (item) => item.id == id,
        orElse: () => DropdownItemModel(id: '', name: 'Unknown'),
      );
      return selectedItem.name == 'Unknown' ? null : selectedItem.name;
    } catch (e) {
      debugPrint('Error getting name for ID $id: $e');
      return null;
    }
  }

  // !=== Set Dynamic  Fields

  void setDynamicFieldValue(String fieldId, dynamic value) {
    _dynamicFieldValues[fieldId] = value;
    notifyListeners();
  }

  Future<CategoryModel?> fetchCategoryModel(String categoryId) async {
    try {
      final categoryData = await _productFirebaseServices.getDocumentById(
        'categories',
        categoryId,
      );

      if (categoryData != null) {
        return CategoryModel.fromFirestore(categoryData, categoryId);
      }
    } catch (e) {
      debugPrint('Error fetching category model: $e');
    }
    return null;
  }

  // ! Add PRODUCT
  Future<void> addProduct({
    required List<String> images,
    required String name,
    String? description,
    required String regularPrice,
    required String salePrice,
    required String quantity,
    required String category,
    required String brand,
    Map<String, dynamic>? dynammicSpecs,
  }) async {
    if (name.isEmpty ||
        regularPrice.isEmpty ||
        salePrice.isEmpty ||
        brand.isEmpty ||
        category.isEmpty ||
        quantity.isEmpty) {
      return;
    }
    final sellerId = currentSellerId;
    if (sellerId == null) {
      debugPrint('Error: Seller not logged in.');
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final newProduct = ProductModel(
        id: '',
        name: name,
        description: description,
        regularPrice: regularPrice,
        salePrice: salePrice,
        quantity: quantity,
        category: category,
        brand: brand,
        images: images,
        status: 'active',
        sellerId: sellerId,
        createdAt: DateTime.now(),
        dynamicSpecs: Map<String, dynamic>.from(_dynamicFieldValues),
        variants: productVariants,
      );

      await _productFirebaseServices.addProduct(newProduct);
    } catch (e) {
      debugPrint('Error from viewModel: $e');
    } finally {
      _isLoading = false;
      clearSelectedImages();
      notifyListeners();
    }
  }

  // ! Initilaize Dropdowns for Edit Screen
  Future<void> initializeForEdit(ProductModel product) async {
    // _selectedBrandId = null;
    // _selectedCategoryId = null;
    // // _logoUrl = product.images;
    // _normalImageUrls.clear();
    // _threeDImageUrls.clear();
    // _searchTerm = '';

    // final brands = await _brandsFuture;
    // final categories = await _categoriesFuture;

    // final currentBrand = brands.firstWhere(
    //   (item) => item.name == product.brand,
    //   orElse: () => DropdownItemModel(id: '', name: ''),
    // );

    // final currentCategory = categories.firstWhere(
    //   (item) => item.name == product.category,
    //   orElse: () => DropdownItemModel(id: '', name: ''),
    // );

    // if (currentBrand.id.isNotEmpty) {
    //   _selectedBrandId = currentBrand.id;
    //   _selectedBrandName = currentBrand.name;
    // }
    // if (currentCategory.id.isNotEmpty) {
    //   _selectedCategoryId = currentCategory.id;
    //   _selectedCategoryName = currentCategory.name;
    // }

    // _normalImageUrls = product.images;

    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _regPriceController.text = product.regularPrice;
    _salePriceController.text = product.salePrice;
    _quantityController.text = product.quantity;
    _colorsController.text = '';

    _normalImageUrls = List<String>.from(product.images);

    _dynamicFieldValues.clear();
    if (product.dynamicSpecs.isNotEmpty) {
      _dynamicFieldValues.addAll(
        Map<String, dynamic>.from(product.dynamicSpecs),
      );
    }

    productVariants = product.variants.map((v) {
      return ColorvariantModel(
        colorName: v.colorName,
        colorCode: v.colorCode,
        imageUrls: List<String>.from(v.imageUrls),
        sizes: v.sizes
            .map((s) => SizeQuantityVariant(size: s.size, quantity: s.quantity))
            .toList(),
      );
    }).toList();

    // Attempt to map saved brand/category names back to their IDs so the
    // dropdowns show the selected values in the edit UI.
    try {
      final brands = await _brandsFuture;
      final categories = await _categoriesFuture;

      final currentBrand = brands.firstWhere(
        (item) => item.name == product.brand,
        orElse: () => DropdownItemModel(id: '', name: ''),
      );

      final currentCategory = categories.firstWhere(
        (item) => item.name == product.category,
        orElse: () => DropdownItemModel(id: '', name: ''),
      );

      if (currentBrand.id.isNotEmpty) {
        _selectedBrandId = currentBrand.id;
        _selectedBrandName = currentBrand.name;
      }

      if (currentCategory.id.isNotEmpty) {
        _selectedCategoryId = currentCategory.id;
        _selectedCategoryName = currentCategory.name;
        // Also fetch and cache the category model for rendering dynamic fields
        _selectedCategoryModel = await fetchCategoryModel(_selectedCategoryId!);
      }
    } catch (e) {
      debugPrint('Error mapping brand/category for edit screen: $e');
    }

    notifyListeners();
  }

  // ! Edit Product
  Future<void> updateExistingProduct({
    required String id,
    required String name,
    required List<String> images,
    String? description,
    required String regularPrice,
    required String salePrice,
    required String quantity,
    String? color,
    required String category,
    required String brand,
  }) async {
    if (name.isEmpty || id.isEmpty) return;

    final sellerId = currentSellerId;
    if (sellerId == null) {
      debugPrint('Error: Seller not logged in.');
      // Handle error gracefully (e.g., show error message)
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final updateProduct = ProductModel(
        id: id,
        name: name,
        description: description,
        regularPrice: regularPrice,
        salePrice: salePrice,
        quantity: quantity,
        category: category,
        brand: brand,
        images: images,
        status: 'active',
        sellerId: sellerId,
        createdAt: DateTime.now(),
        dynamicSpecs: Map<String, dynamic>.from(_dynamicFieldValues),
        variants: List<ColorvariantModel>.from(productVariants),
      );

      await _productFirebaseServices.updateProduct(updateProduct);
    } catch (e) {
      debugPrint('Error updating Product from ViewModel: $e');
    } finally {
      _isLoading = false;
      clearSelectedImages();
      notifyListeners();
    }
  }

  // ! Delete Brand
  Future<void> deleteProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productFirebaseServices.deleteProduct(product);
    } catch (e) {
      debugPrint('Error deleting Product from ViewModel: $e');
    } finally {
      _isLoading = false;
    }
  }

  // ! Clear Dropdown Selections
  void clearSelections() {
    _selectedBrandId = null;
    _selectedCategoryId = null;
    _selectedBrandName = null;
    _selectedCategoryName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _salePriceController.dispose();
    _colorsController.dispose();
    _searchController.dispose();
    _regPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
