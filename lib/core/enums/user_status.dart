enum UserStatus {
  pendente,
  aprovado,
  bloqueado;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserStatus.pendente,
    );
  }
}