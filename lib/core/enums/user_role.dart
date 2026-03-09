enum UserRole {
  acs('acs', 'Agente Comunitário'),
  gestorUnidade('gestor_unidade', 'Gestor de Unidade'),
  medico('medico', 'Médico'),
  superAdmin('super_admin', 'Super Admin');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole? fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.acs,
    );
  }
}