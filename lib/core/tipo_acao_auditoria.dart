/// Enum para todos os tipos de ações que podem ser auditadas no sistema
enum TipoAcaoAuditoria {
  // Ações básicas
  visualizar('visualizar', 'Visualizou'),
  criar('criar', 'Criou'),
  editar('editar', 'Editou'),
  deletar('deletar', 'Deletou'),

  // Autenticação
  login('login', 'Login'),
  logout('logout', 'Logout'),

  // Gestão de usuários
  aprovar('aprovar', 'Aprovou'),
  reprovar('reprovar', 'Reprovou'),

  // Ações específicas do domínio
  renovar('renovar', 'Renovou'),
  imprimir('imprimir', 'Imprimiu'),
  exportar('exportar', 'Exportou'),

  // Ações em lote
  importar('importar', 'Importou'),
  sincronizar('sincronizar', 'Sincronizou');

  const TipoAcaoAuditoria(this.value, this.displayName);

  /// Valor para salvar no banco (ex: 'visualizar')
  final String value;

  /// Nome para exibição na interface (ex: 'Visualizou')
  final String displayName;

  /// Cria um enum a partir do valor salvo no banco
  static TipoAcaoAuditoria fromString(String value) {
    return TipoAcaoAuditoria.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoAcaoAuditoria.visualizar, // fallback seguro
    );
  }

  /// Retorna todos os valores para usar em Dropdowns
  static List<TipoAcaoAuditoria> get valores => values;
}

// Se você preferir separar em outro arquivo, também pode criar:
// lib/core/enums/user_role.dart (se não existir)
// lib/core/enums/user_status.dart (se não existir)
