Map<String, dynamic>? asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}

List<Object?> asList(Object? value) {
  if (value is List) {
    return value;
  }
  return const [];
}

String asString(Object? value) {
  if (value is String) {
    return value.trim();
  }
  return '';
}
