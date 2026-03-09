import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

/// Modelo de Log de Auditoria (imutável)
class LogAuditoria {
  final String id;
  final String municipioId;
  final String? unidadeId;
  final String usuarioId;
  final String usuarioNome;
  final UserRole usuarioRole;
  final TipoAcaoAuditoria tipoAcao;
  final String entidade; // paciente, receita, usuario, etc
  final String? entidadeId;
  final Map<String, dynamic>? dadosAnteriores;
  final Map<String, dynamic>? dadosNovos;
  final String? observacao;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  LogAuditoria({
    required this.id,
    required this.municipioId,
    this.unidadeId,
    required this.usuarioId,
    required this.usuarioNome,
    required this.usuarioRole,
    required this.tipoAcao,
    required this.entidade,
    this.entidadeId,
    this.dadosAnteriores,
    this.dadosNovos,
    this.observacao,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
  });

  factory LogAuditoria.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogAuditoria(
      id: doc.id,
      municipioId: data['municipio_id'] as String? ?? '',
      unidadeId: data['unidade_id'] as String?,
      usuarioId: data['usuario_id'] as String? ?? '',
      usuarioNome: data['usuario_nome'] as String? ?? '',
      usuarioRole: UserRole.fromString(data['usuario_role'] as String? ?? 'acs'),
      tipoAcao: TipoAcaoAuditoria.fromString(data['tipo_acao'] as String? ?? 'visualizar'),
      entidade: data['entidade'] as String? ?? '',
      entidadeId: data['entidade_id'] as String?,
      dadosAnteriores: data['dados_anteriores'] as Map<String, dynamic>?,
      dadosNovos: data['dados_novos'] as Map<String, dynamic>?,
      observacao: data['observacao'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ipAddress: data['ip_address'] as String?,
      userAgent: data['user_agent'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'municipio_id': municipioId,
      'unidade_id': unidadeId,
      'usuario_id': usuarioId,
      'usuario_nome': usuarioNome,
      'usuario_role': usuarioRole.value,
      'tipo_acao': tipoAcao.value,
      'entidade': entidade,
      'entidade_id': entidadeId,
      'dados_anteriores': dadosAnteriores,
      'dados_novos': dadosNovos,
      'observacao': observacao,
      'timestamp': Timestamp.fromDate(timestamp),
      'ip_address': ipAddress,
      'user_agent': userAgent,
    };
  }

  String get descricao {
    return '$usuarioNome (${usuarioRole.displayName}) ${tipoAcao.displayName.toLowerCase()} $entidade';
  }
}
