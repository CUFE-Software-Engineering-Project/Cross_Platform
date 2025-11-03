String? emailValidator(String? value) {
  const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  final RegExp regex = RegExp(emailPattern);

  if (value == null || value.isEmpty) {
    return 'Email is required';
  } else if (value.length > 254) {
    return 'Email can\'t be longer than 254 characters';
  } else if (!regex.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? dobValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Date of birth can\'t be empty';
  }

  try {
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'enter a valid date';
    }

    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final dob = DateTime(year, month, day);
    final now = DateTime.now();

    if (dob.isAfter(now)) {
      return 'Date of birth can\'t be in the future';
    }

    final minage = DateTime(now.year - 13, now.month, now.day);
    if (dob.isAfter(minage)) {
      return 'You must be at least 13 years old';
    }
  } catch (e) {
    return 'Enter a valid date';
  }

  return null;
}

String? nameValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name can\'t be empty';
  } else if (value.trim().length < 2) {
    return 'Name must be at least 2 characters';
  } else if (value.trim().length > 50) {
    return 'Name can\'t be longer than 50 characters';
  }

  return null;
}

String? verificationCodeValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Verification code can\'t be empty';
  } else if (value.trim().length != 6) {
    return 'Verification code must be exactly 6 digits';
  } else if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
    return 'Verification code must contain only digits';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (value.length > 256) {
    return 'Password must be less than 256 characters';
  }

  final capitalLetters = RegExp(r'[A-Z]');
  if (capitalLetters.allMatches(value).length < 3) {
    return 'Password must contain at least 3 uppercase letters';
  }

  final lowercaseLetters = RegExp(r'[a-z]');
  if (lowercaseLetters.allMatches(value).length < 3) {
    return 'Password must contain at least 3 lowercase letters';
  }

  final symbols = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-=+;]');
  if (symbols.allMatches(value).length < 3) {
    return 'Password must contain at least 3 symbols';
  }

  final numbers = RegExp(r'\d');
  if (numbers.allMatches(value).length < 3) {
    return 'Password must contain at least 3 numbers';
  }

  return null;
}

String? loginpasswordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  return null;
}

String? usernameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length < 4) {
    return 'Username must be at least 4 characters';
  }
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
    return 'Only letters, numbers and underscore are allowed';
  }
  return null;
}
