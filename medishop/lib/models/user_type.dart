enum UserType {
  CLIENT,
  PHARMACIE,
  LIVREUR,
  UNKNOWN,
}

UserType userTypeFromString(String? value) {
  if (value == null) return UserType.UNKNOWN;
  return UserType.values.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => UserType.UNKNOWN,
  );
}
