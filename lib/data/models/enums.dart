/// Enumerações para o sistema de gerenciamento de receitas médicas
library;

/// Tipos de usuário no sistema
enum UserRole {
  superAdmin('super_admin', 'SuperAdmin Nacional'),
  gestorMunicipal('gestor_municipal', 'Gestor Municipal'),
  gestorUnidade('gestor_unidade', 'Gestor de Unidade'),
  medico('medico', 'Médico'),
  acs('acs', 'Agente Comunitário de Saúde');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.acs,
    );
  }
}

/// Tipos de receita médica conforme legislação brasileira
enum TipoReceita {
  brancaAguda(
    'branca_aguda',
    'Receita Simples (Branca) - Aguda',
    30,
    'white',
  ),
  brancaContinua(
    'branca_continua',
    'Receita Simples (Branca) - Contínua',
    180,
    'white',
  ),
  azul(
    'azul',
    'Receita B (Azul) - Atenção',
    30,
    'blue',
  ),
  amarela(
    'amarela',
    'Receita A (Amarela) - Urgente',
    30,
    'yellow',
  );

  final String value;
  final String displayName;
  final int validadeDias;
  final String color;

  const TipoReceita(this.value, this.displayName, this.validadeDias, this.color);

  static TipoReceita fromString(String value) {
    return TipoReceita.values.firstWhere(
      (tipo) => tipo.value == value,
      orElse: () => TipoReceita.brancaAguda,
    );
  }
}

/// Status da receita no fluxo de trabalho
enum StatusReceita {
  pendente('pendente', 'Pendente'),
  emAnalise('em_analise', 'Em Análise'),
  assinada('assinada', 'Assinada'),
  impressa('impressa', 'Impressa'),
  dispensada('dispensada', 'Dispensada'),
  vencida('vencida', 'Vencida');

  final String value;
  final String displayName;

  const StatusReceita(this.value, this.displayName);

  static StatusReceita fromString(String value) {
    return StatusReceita.values.firstWhere(
      (status) => status.value == value,
      orElse: () => StatusReceita.pendente,
    );
  }
}

/// Status do paciente no acompanhamento
enum StatusPaciente {
  ativo('ativo', 'Ativo'),
  inativo('inativo', 'Inativo'),
  transferido('transferido', 'Transferido'),
  obito('obito', 'Óbito');

  final String value;
  final String displayName;

  const StatusPaciente(this.value, this.displayName);

  static StatusPaciente fromString(String value) {
    return StatusPaciente.values.firstWhere(
      (status) => status.value == value,
      orElse: () => StatusPaciente.ativo,
    );
  }
}

/// Categorias de medicamentos para agrupamento inteligente
enum CategoriaMedicamento {
  antibiotico('antibiotico', 'Antibiótico', TipoReceita.brancaAguda),
  antiInflamatorio('anti_inflamatorio', 'Anti-inflamatório', TipoReceita.brancaAguda),
  hipertensao('hipertensao', 'Hipertensão', TipoReceita.brancaContinua),
  diabetes('diabetes', 'Diabetes', TipoReceita.brancaContinua),
  controladoB('controlado_b', 'Controlado B', TipoReceita.azul),
  controladoA('controlado_a', 'Controlado A', TipoReceita.amarela),
  outros('outros', 'Outros', TipoReceita.brancaAguda);

  final String value;
  final String displayName;
  final TipoReceita tipoReceitaPadrao;

  const CategoriaMedicamento(this.value, this.displayName, this.tipoReceitaPadrao);

  static CategoriaMedicamento fromString(String value) {
    return CategoriaMedicamento.values.firstWhere(
      (categoria) => categoria.value == value,
      orElse: () => CategoriaMedicamento.outros,
    );
  }
}

/// Tipo de ação de auditoria
enum TipoAcaoAuditoria {
  criar('criar', 'Criar'),
  editar('editar', 'Editar'),
  excluir('excluir', 'Excluir'),
  visualizar('visualizar', 'Visualizar'),
  transferir('transferir', 'Transferir'),
  assinar('assinar', 'Assinar'),
  imprimir('imprimir', 'Imprimir');

  final String value;
  final String displayName;

  const TipoAcaoAuditoria(this.value, this.displayName);

  static TipoAcaoAuditoria fromString(String value) {
    return TipoAcaoAuditoria.values.firstWhere(
      (tipo) => tipo.value == value,
      orElse: () => TipoAcaoAuditoria.visualizar,
    );
  }
}
