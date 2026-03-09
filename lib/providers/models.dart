enum UserRole {
  acs('acs', 'Agente Comunitário'),
  gestorUnidade('gestor_unidade', 'Gestor de Unidade'),
  medico('medico', 'Médico'),
  admin('super_admin', 'Super Admin');

  final String value;
  final String label;

  const UserRole(this.value, this.label);
}