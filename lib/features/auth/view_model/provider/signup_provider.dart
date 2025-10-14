// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluxfoot_seller/core/firebase/auth/authgate.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/core/widgets/routs_widgets.dart';

const String kCloudinaryCloudName = 'dryij9oei';
const String kCloudinaryUploadPreset = 'sr_default';
const String kCloudinaryFolder = 'selller_verification_docs';

class SignupProvider extends ChangeNotifier {
  final GlobalKey<FormState> _signupFormkey = GlobalKey<FormState>(
    debugLabel: 'SingUpForm',
  );
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _warehouseController = TextEditingController();
  String _selectedBusinessType = '';
  String _businessLicenseFileName = '';
  File? _businessLicenseFile;
  Uint8List? _licenseFileBytes;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final cloudinary = CloudinaryPublic(
    kCloudinaryCloudName,
    kCloudinaryUploadPreset,
    cache: false,
  );

  bool _isEnterPasswordVisible = false;
  bool _isCreatePasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  GlobalKey<FormState> get signupFormkey => _signupFormkey;
  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPassController => _confirmPassController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get storeNameController => _storeNameController;
  TextEditingController get warehouseController => _warehouseController;
  String get selectedBusinessType => _selectedBusinessType;
  String get businessLicenseFileName => _businessLicenseFileName;
  File? get businessLicenseFile => _businessLicenseFile;
  Uint8List? get licenseFileBytes => _licenseFileBytes;

  bool get isEnterPasswordVisible => _isEnterPasswordVisible;
  bool get isCreatePasswordVisible => _isCreatePasswordVisible;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSelectedBusinessType(String type) {
    _selectedBusinessType = type;
    notifyListeners();
  }

  List<String> businessTypes = [
    'Individual Seller',
    'Sole Proprietorship',
    'Registered Company',
    'Partnership',
  ];

  Future<void> pickBusinessLicense(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
      withData: kIsWeb ? true : false,
      withReadStream: kIsWeb ? false : true,
    );

    if (result != null) {
      PlatformFile file = result.files.single;

      if (kIsWeb) {
        _licenseFileBytes = file.bytes;
        _businessLicenseFile = null;
      } else {
        _businessLicenseFile = File(file.path!);
        _licenseFileBytes = null;
      }
      _businessLicenseFileName = file.name;
      setError(null);
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('you cancelled upload proof'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  // Add a method to clear/remove the selected file
  void clearBusinessLicense() {
    _businessLicenseFile = null;
    _businessLicenseFileName = '';
    _licenseFileBytes = null;
    notifyListeners();
  }

  void togglePasswordVisibleEnter() {
    _isEnterPasswordVisible = !_isEnterPasswordVisible;
    notifyListeners();
  }

  void togglePasswordVisibleCreate() {
    _isCreatePasswordVisible = !_isCreatePasswordVisible;
    notifyListeners();
  }

  void toggleRemember(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<String> _uploadToCloudinary(String uid) async {
    String extension = _businessLicenseFileName.split('.').last.toLowerCase();
    CloudinaryResourceType resourceType = (extension == 'pdf')
        ? CloudinaryResourceType.Raw
        : CloudinaryResourceType.Image;

    CloudinaryResponse ressponse;

    if (kIsWeb) {
      if (_licenseFileBytes == null) {
        throw Exception("License file data not found for web upload");
      }

      ByteData byteData = ByteData.view(_licenseFileBytes!.buffer);

      ressponse = await cloudinary.uploadFile(
        CloudinaryFile.fromByteData(
          byteData,
          resourceType: resourceType,
          folder: kCloudinaryFolder,
          identifier: 'business_license_id$uid',
          publicId: 'business_license_$uid',
        ),
      );
    } else {
      if (_businessLicenseFile == null) {
        throw Exception("License file not found for native uplad.");
      }

      ressponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          _businessLicenseFile!.path,
          resourceType: resourceType,
          folder: kCloudinaryFolder,
          identifier: uid,
        ),
      );
    }
    return ressponse.secureUrl;
  }

  Future<void> handleSignup(BuildContext context) async {
    if (_signupFormkey.currentState!.validate()) {
      if (_passwordController.text != _confirmPassController.text) {
        setError('Passwords do not match');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }
      if (!kIsWeb && _businessLicenseFile == null ||
          kIsWeb && _licenseFileBytes == null) {
        setError('Please Upload your business license');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload your business license'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      setLoading(true);
      try {
        // Create user with Firebase Auth
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        // Check if the user was created successfully
        if (userCredential.user != null) {
          final String uid = userCredential.user!.uid;

          log('Starting Cloudinary upad...');
          final String licenseUrl = await _uploadToCloudinary(uid);
          log('Cloudinary uplad successful. URL : $licenseUrl');

          // Store seller data in Firestore
          await _firestore.collection('sellers').doc(uid).set({
            'uid': uid,
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _confirmPassController.text.trim(),
            'phone': _phoneController.text.trim(),
            'createdAt': Timestamp.now(),
            'status': 'pending',
            'store name': _storeNameController.text.trim(),
            'business type': _selectedBusinessType.trim(),
            'business_license_url': licenseUrl,
            'warehouse': _warehouseController.text.trim(),
          });

          showOverlaySnackbar(
            context,
            'Sign-up successful!💫',
            AppColors.succesGreen,
          );
          // Navigate to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AuthGate()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setError(e.message);
        log(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-up failed: ${e.message}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      } catch (e) {
        setError(e.toString());
        log(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-up failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      } finally {
        setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _warehouseController.dispose();
    super.dispose();
  }
}
