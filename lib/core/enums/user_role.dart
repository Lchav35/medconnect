enum UserRole {
  acs('acs', 'Agente Comunitário'),
  gestorUnidade('gestor_unidade', 'Gestor de Unidade'),
  gestorMunicipal('gestor_municipal', 'Gestor Municipal'), // ADICIONADO
  medico('medico', 'Médico'),
  paciente('paciente', 'Paciente'), // ADICIONADO
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
