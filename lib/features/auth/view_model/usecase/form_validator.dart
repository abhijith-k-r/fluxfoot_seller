// ! VALIDATOR MIXIN
mixin Validator {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    } else if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateName(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return 'Please enter your Name';
    }
    if (!RegExp(r"^[a-zA-Z\s.-]+$").hasMatch(trimmedValue)) {
      return 'Name can only contain letters, spaces, hyphens, or periods.';
    }
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters long.';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  String? validateWarehouse(String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return 'Please enter your warehouse location';
    }
    // Basic heuristic: require at least 8 characters and contain a comma (street, city)
    if (trimmedValue.length < 8) {
      return 'Please provide a more detailed address';
    }
    if (!trimmedValue.contains(',') && !trimmedValue.contains('\n')) {
      return 'Please include city or postcode (e.g. "Street, City")';
    }
    return null;
  }
}
