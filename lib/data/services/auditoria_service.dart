import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class AuditoriaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton
  static final AuditoriaService _instance = AuditoriaService._internal();
  factory AuditoriaService() => _instance;
  AuditoriaService._internal();

  /// Registra qualquer ação no log de auditoria
  Future<void> registrar({
    required TipoAcaoAuditoria tipoAcao,
    required String entidade,
    String? entidadeId,
    Map<String, dynamic>? dadosAnteriores,
    Map<String, dynamic>? dadosNovos,
    String? observacao,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ Tentativa de registrar auditoria sem usuário logado');
        return;
      }

      // Busca dados completos do usuário no Firestore
      final userDoc = await _firestore
          .collection('usuarios_global')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        print('⚠️ Usuário não encontrado no Firestore: ${user.uid}');
        return;
      }

      final userData = userDoc.data()!;

      // Cria o log
      final log = LogAuditoria(
        id: '', // Será gerado pelo Firestore
        municipioId: userData['municipio_id'] ?? '',
        unidadeId: userData['unidade_id'],
        usuarioId: user.uid,
        usuarioNome: userData['nome'] ?? user.email ?? 'Desconhecido',
        usuarioRole: UserRole.fromString(userData['role'] ?? 'acs'),
        tipoAcao: tipoAcao,
        entidade: entidade,
        entidadeId: entidadeId,
        dadosAnteriores: _sanitizarDados(dadosAnteriores),
        dadosNovos: _sanitizarDados(dadosNovos),
        observacao: observacao,
        timestamp: DateTime.now(),
        ipAddress: null, // Opcional: implementar se necessário
        userAgent: null, // Opcional: implementar se necessário
      );

      // Salva no Firestore (coleção de auditoria)
      await _firestore.collection('auditoria').add(log.toFirestore());

      // Se for uma ação muito importante, podemos manter um log local também
      print('✅ Log registrado: ${tipoAcao.displayName} - $entidade');
    } catch (e) {
      // NUNCA interrompe o fluxo principal por erro de auditoria
      print('❌ Erro ao registrar log de auditoria: $e');

      // TODO: Em produção, enviar para um serviço de logging (Sentry, etc)
    }
  }

  /// Remove campos sensíveis ou problemáticos dos dados
  Map<String, dynamic>? _sanitizarDados(Map<String, dynamic>? dados) {
    if (dados == null) return null;

    // Remove campos que não devem ser logados (ex: senha, token)
    final sanitizado = Map<String, dynamic>.from(dados);
    sanitizado.remove('password');
    sanitizado.remove('senha');
    sanitizado.remove('token');
    return sanitizado;
  }

  // ================================
  // MÉTODOS ESPECÍFICOS PARA AÇÕES COMUNS
  // ================================

  Future<void> visualizouPaciente(
    String pacienteId,
    String pacienteNome,
  ) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.visualizar,
      entidade: 'paciente',
      entidadeId: pacienteId,
      observacao: 'Visualizou paciente: $pacienteNome',
    );
  }

  Future<void> criouPaciente(
    String pacienteId,
    Map<String, dynamic> dados,
  ) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.criar,
      entidade: 'paciente',
      entidadeId: pacienteId,
      dadosNovos: dados,
      observacao: 'Cadastrou novo paciente',
    );
  }

  Future<void> editouPaciente(
    String pacienteId,
    Map<String, dynamic> dadosAntigos,
    Map<String, dynamic> dadosNovos,
  ) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.editar,
      entidade: 'paciente',
      entidadeId: pacienteId,
      dadosAnteriores: dadosAntigos,
      dadosNovos: dadosNovos,
      observacao: 'Editou dados do paciente',
    );
  }

  Future<void> criouReceita(
    String receitaId,
    Map<String, dynamic> dados,
  ) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.criar,
      entidade: 'receita',
      entidadeId: receitaId,
      dadosNovos: dados,
      observacao: 'Emissão de nova receita',
    );
  }

  Future<void> renovouReceita(String receitaId) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.renovar,
      entidade: 'receita',
      entidadeId: receitaId,
      observacao: 'Renovação de receita',
    );
  }

  Future<void> loginUsuario(String email) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.login,
      entidade: 'sistema',
      observacao: 'Login no sistema: $email',
    );
  }

  Future<void> logoutUsuario(String nome) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.logout,
      entidade: 'sistema',
      observacao: 'Logout do sistema: $nome',
    );
  }

  Future<void> aprovouUsuario(String usuarioId, String nome) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.aprovar,
      entidade: 'usuario',
      entidadeId: usuarioId,
      observacao: 'Aprovou usuário: $nome',
    );
  }

  Future<void> reprovouUsuario(
    String usuarioId,
    String nome, {
    String? motivo,
  }) async {
    await registrar(
      tipoAcao: TipoAcaoAuditoria.reprovar,
      entidade: 'usuario',
      entidadeId: usuarioId,
      observacao:
          'Reprovou usuário: $nome${motivo != null ? ' - $motivo' : ''}',
    );
  }
}
