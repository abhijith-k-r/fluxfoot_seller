// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/firebase/services/product_firebase_services.dart';
import 'package:fluxfoot_seller/features/products/model/dropdown_model.dart';
import 'package:fluxfoot_seller/features/products/model/product_model.dart';
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
    if (_selectedCategoryId != newId) {
      _selectedCategoryId = newId;

      _updateSelectedName(_categoriesFuture, newId, (name) {
        _selectedCategoryName = name;
      });
      notifyListeners();
    }
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

  // // ! SET INITIAL LOGO URL
  // void setInitialLogoUrl(String? url) {
  //   if (_logoUrl != url) {
  //     _logoUrl = url;
  //     notifyListeners();
  //   }
  // }

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

  // ! Add PRODUCT
  Future<void> addProduct({
    required List<String> images,
    required String name,
    String? description,
    required String regularPrice,
    required String salePrice,
    required String quantity,
    String? color,
    required String category,
    required String brand,
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
        color: color,
        brand: brand,
        images: images,
        status: 'active',
        sellerId: sellerId,
        createdAt: DateTime.now(),
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
    _selectedBrandId = null;
    _selectedCategoryId = null;
    // _logoUrl = product.images;
    _normalImageUrls.clear();
    _threeDImageUrls.clear();
    _searchTerm = '';

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
    }

    _normalImageUrls = product.images;

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
        color: color,
        brand: brand,
        images: images,
        status: 'active',
        sellerId: sellerId,
        createdAt: DateTime.now(),
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

  void clearAllFields() {
    _nameController.clear();
    _descriptionController.clear();
    _regPriceController.clear();
    _salePriceController.clear();
    _quantityController.clear();
    _colorsController.clear();

    clearSelectedImages();
    clearSelections();
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
