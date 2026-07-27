import '../features/config/constants.dart';

import '../core/env.dart';
import '../l10n/l10n_helper.dart';

bool isInt(String number) {
  return int.tryParse(number) == null ? false : true;
}

bool isNumber(String number) {
  return double.tryParse(number) == null ? false : true;
}

bool isValidEmail(String email) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}

bool isValidUrl(String url) {
  var urlPattern = r"^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$";
  return RegExp(urlPattern, caseSensitive: false).hasMatch(url);
}

bool isValidUsername(String username) {
  // 3 - 20 characters (alpha numberic + hyphen and underbar)
  return RegExp(r'^(?!\s*$)[a-zA-Z0-9_-]{3,20}$').hasMatch(username);
}

bool isValidPassword(String password) {
  return password.length > 7;

  // 8+ chars, number, symbol, 1 uppercase

  // return RegExp(
  //         r'^(?=[^A-Z\n]*[A-Z])(?=[^a-z\n]*[a-z])(?=[^0-9\n]*[0-9])(?=[^#?!@$%^&*\n-]*[#?!@$%^&*-]).{8,}$')
  //     .hasMatch(password);
}

bool isValidRbxAddress(String address) {
  address = address.trim().replaceAll("\n", "");
  if (address.length != 34) {
    return false;
  }

  if (address.startsWith("xRBX")) {
    return true;
  }

  String firstChar = "R";
  if (Env.isTestNet) {
    firstChar = "x";
  }
  if (address[0] != firstChar) {
    return false;
  }

  return true;
}

bool isValidPhoneNumber(String value) {
  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = RegExp(patttern);
  if (!regExp.hasMatch(value)) {
    return false;
  }

  return true;
}

String? formValidatorEmail(String? value) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hEmailRequired;
  }
  if (!isValidEmail(value)) {
    return globalL10n.r3hEmailInvalid;
  }
  return null;
}

String? formValidatorEmailOrEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  if (!isValidEmail(value)) {
    return globalL10n.r3hEmailInvalid;
  }
  return null;
}

String? formValidatorUsername(String? value) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hUsernameRequired;
  }

  if (!isValidUsername(value)) {
    return globalL10n.r3hUsernameInvalid;
  }

  return null;
}

String? formValidatorPhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hPhoneRequired;
  }
  if (!isValidPhoneNumber(value)) {
    return globalL10n.r3hPhoneInvalid;
  }
  return null;
}

String? formValidatorPassword(String? value) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hPasswordRequired;
  }

  if (!isValidPassword(value)) {
    return globalL10n.r3hPasswordWeak;
  }

  return null;
}

String? formValidatorNotEmpty(String? value, String label) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hFieldRequired(label);
  }

  return null;
}

String? formValidatorDecDescription(String? value) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hDescRequired;
  }
  if (value.length > MAX_DEC_SHOP_COLLECTION_DESCRIPTION_LENGTH) {
    return globalL10n.r3hDescTooLong;
  }
  if (value.split(' ').length > MAX_DEC_SHOP_COLLECTION_DESCRIPTION_WORDS) {
    return globalL10n.r3hDescTooManyWords;
  }
  return null;
}

String? formValidatorDecName(String? value) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hNameRequired;
  }
  if (value.length > MAX_DEC_SHOP_COLLECTION_NAME_LENGTH) {
    return globalL10n.r3hNameTooLong;
  }
  return null;
}

String? formValidatorRbxAddress(String? value, [bool allowAdnr = false]) {
  if (value == null || value.isEmpty) {
    return allowAdnr ? globalL10n.r3hAddressOrDomainRequired : globalL10n.r3hAddressRequired;
  }

  if (allowAdnr && value.contains(".vfx")) {
    return null;
  }

  if (!isValidRbxAddress(value)) {
    return globalL10n.r3hAddressInvalid;
  }

  return null;
}

String? formValidatorRbxAddressOrEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  if (!isValidRbxAddress(value)) {
    return globalL10n.r3hAddressInvalid;
  }

  return null;
}

String? formPercentValidator(String? val) {
  if (val == null || val.isEmpty) {
    return globalL10n.r3hRequired;
  }
  final amount = double.tryParse(val);
  if (amount == null) {
    return globalL10n.r3hInvalid;
  }

  if (amount > 100) {
    return globalL10n.r3hMaxPercent;
  }

  if (amount <= 0) {
    return globalL10n.r3hMinPercent;
  }

  return null;
}

String? formValidatorNumber(String? value, String label) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hFieldRequired(label);
  }

  if (!isNumber(value)) {
    return globalL10n.r3hFieldInvalid(label);
  }

  return null;
}

String? formValidatorInteger(String? value, String label) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hFieldRequired(label);
  }

  if (!isInt(value)) {
    return globalL10n.r3hFieldInvalid(label);
  }

  return null;
}

String? formValidatorAlphaNumeric(String? value, String label) {
  if (value == null || value.isEmpty) {
    return globalL10n.r3hFieldRequired(label);
  }

  return RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value) ? null : globalL10n.r3hDnrAlphaNumeric;
}
