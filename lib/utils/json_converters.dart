import 'package:freezed_annotation/freezed_annotation.dart';

/// Reads a JSON number that may arrive as a number or as a numeric string.
///
/// Spyglass serializes some decimal fields as strings (for example a zero
/// balance comes back as `"0.0000000000000000"`), so a plain `as num` cast
/// throws on otherwise valid data. Anything that is neither a number nor a
/// numeric string is a real format error and throws [FormatException].
double parseJsonDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    final parsed = double.tryParse(value.trim());
    if (parsed != null) {
      return parsed;
    }
  }
  throw FormatException("Expected a number or a numeric string", value);
}

/// Like [parseJsonDouble] but lets `null` through.
double? parseJsonDoubleOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return parseJsonDouble(value);
}

/// `double` field that accepts a number or a numeric string.
class NumOrStringDoubleConverter implements JsonConverter<double, Object> {
  const NumOrStringDoubleConverter();

  @override
  double fromJson(Object json) => parseJsonDouble(json);

  @override
  Object toJson(double object) => object;
}

/// `double?` field that accepts a number, a numeric string or null.
class NullableNumOrStringDoubleConverter implements JsonConverter<double?, Object?> {
  const NullableNumOrStringDoubleConverter();

  @override
  double? fromJson(Object? json) => parseJsonDoubleOrNull(json);

  @override
  Object? toJson(double? object) => object;
}
