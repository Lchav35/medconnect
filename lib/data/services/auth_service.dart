import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'auditoria_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditoriaService _auditoria = AuditoriaService();

  // ================================
  // FIREBASE USER
  // ================================

  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // ================================
  // LOGIN COM AUDITORIA
  // ================================

  Future<Usuario?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Falha ao autenticar usuário.');
      }

      final userDoc = await _firestore
          .collection('usuarios_global')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('Usuário não encontrado no sistema.');
      }

      final data = userDoc.data();

      if (data?['status'] != 'aprovado') {
        await _auth.signOut();
        throw Exception('Cadastro aguardando aprovação do gestor.');
      }

      final usuario = Usuario.fromFirestore(userDoc);

      await _firestore.collection('usuarios_global').doc(usuario.id).update({
        'ultimo_acesso': FieldValue.serverTimestamp(),
      });

      // ✅ REGISTRA LOGIN NA AUDITORIA
      await _auditoria.registrar(
        tipoAcao: TipoAcaoAuditoria.login,
        entidade: 'sistema',
        observacao:
            'Usuário fez login no sistema - ${usuario.nome} (${usuario.email})',
      );

      return usuario;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('E-mail não cadastrado.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta.');
      } else if (e.code == 'invalid-email') {
        throw Exception('E-mail inválido.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Usuário desativado.');
      } else {
        throw Exception('Erro ao realizar login.');
      }
    } catch (_) {
      throw Exception('Não foi possível realizar o login.');
    }
  }

  // ================================
  // LOGOUT COM AUDITORIA
  // ================================

  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore
            .collection('usuarios_global')
            .doc(user.uid)
            .get();

        final usuario = userDoc.data();

        await _auditoria.registrar(
          tipoAcao: TipoAcaoAuditoria.logout,
          entidade: 'sistema',
          observacao: 'Usuário fez logout - ${usuario?['nome'] ?? user.email}',
        );
      }
    } catch (_) {
      // Ignora erro de auditoria no logout
    }

    await _auth.signOut();
  }

  // ================================
  // REGISTRO
  // ================================

  Future<Usuario?> registerUser({
    required String email,
    required String password,
    required String nome,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Erro ao criar usuário.');
      }

      final usuarioData = {
        'uid': userCredential.user!.uid,
        'email': email,
        'nome': nome,
        'role': 'acs',
        'municipio_id': 'pendente',
        'unidade_id': null,
        'status': 'pendente',
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('usuarios_global')
          .doc(userCredential.user!.uid)
          .set(usuarioData);

      await _auth.signOut();

      return Usuario.fromFirestore(
        await _firestore
            .collection('usuarios_global')
            .doc(userCredential.user!.uid)
            .get(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este e-mail já está cadastrado.');
      } else if (e.code == 'weak-password') {
        throw Exception('A senha deve ter pelo menos 6 caracteres.');
      } else if (e.code == 'invalid-email') {
        throw Exception('E-mail inválido.');
      } else {
        throw Exception('Erro ao registrar usuário.');
      }
    } catch (_) {
      throw Exception('Não foi possível concluir o cadastro.');
    }
  }

  // ================================
  // APROVAR USUÁRIO (COM AUDITORIA)
  // ================================

  Future<void> aprovarUsuario(String userId) async {
    try {
      // Busca dados ANTES da aprovação
      final userDoc = await _firestore
          .collection('usuarios_global')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception('Usuário não encontrado.');
      }

      final dadosAntigos = userDoc.data()!;
      final nomeUsuario = dadosAntigos['nome'] ?? 'Desconhecido';
      final emailUsuario = dadosAntigos['email'] ?? '';

      // Atualiza status
      await _firestore.collection('usuarios_global').doc(userId).update({
        'status': 'aprovado',
        'aprovado_em': FieldValue.serverTimestamp(),
        'aprovado_por': _auth.currentUser?.uid,
      });

      // ✅ REGISTRA APROVAÇÃO NA AUDITORIA (CRÍTICO PARA PREFEITURAS!)
      await _auditoria.registrar(
        tipoAcao: TipoAcaoAuditoria.aprovar,
        entidade: 'usuario',
        entidadeId: userId,
        dadosAnteriores: dadosAntigos,
        dadosNovos: {'status': 'aprovado'},
        observacao: 'Gestor aprovou usuário: $nomeUsuario ($emailUsuario)',
      );
    } catch (e) {
      print('Erro ao aprovar usuário: $e');
      rethrow;
    }
  }

  // ================================
  // REPROVAR USUÁRIO
  // ================================

  Future<void> reprovarUsuario(String userId, {String? motivo}) async {
    try {
      final userDoc = await _firestore
          .collection('usuarios_global')
          .doc(userId)
          .get();

      final dadosAntigos = userDoc.data()!;
      final nomeUsuario = dadosAntigos['nome'] ?? 'Desconhecido';

      await _firestore.collection('usuarios_global').doc(userId).update({
        'status': 'reprovado',
        'reprovado_em': FieldValue.serverTimestamp(),
        'reprovado_por': _auth.currentUser?.uid,
        'motivo_reprovacao': motivo,
      });

      await _auditoria.registrar(
        tipoAcao: TipoAcaoAuditoria.reprovar,
        entidade: 'usuario',
        entidadeId: userId,
        dadosAnteriores: dadosAntigos,
        dadosNovos: {'status': 'reprovado', 'motivo': motivo},
        observacao:
            'Gestor reprovou usuário: $nomeUsuario${motivo != null ? ' - Motivo: $motivo' : ''}',
      );
    } catch (e) {
      print('Erro ao reprovar usuário: $e');
      rethrow;
    }
  }

  // ================================
  // ATUALIZAR USUÁRIO
  // ================================

  Future<void> atualizarUsuario(
    String userId,
    Map<String, dynamic> novosDados,
  ) async {
    try {
      // Busca dados atuais
      final userDoc = await _firestore
          .collection('usuarios_global')
          .doc(userId)
          .get();

      final dadosAntigos = userDoc.data();

      // Atualiza
      await _firestore
          .collection('usuarios_global')
          .doc(userId)
          .update(novosDados);

      // ✅ REGISTRA ALTERAÇÃO
      await _auditoria.registrar(
        tipoAcao: TipoAcaoAuditoria.editar,
        entidade: 'usuario',
        entidadeId: userId,
        dadosAnteriores: dadosAntigos,
        dadosNovos: novosDados,
        observacao: 'Dados do usuário foram alterados',
      );
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      rethrow;
    }
  }

  // ================================
  // DELETAR/DESATIVAR USUÁRIO
  // ================================

  Future<void> deletarUsuario(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('usuarios_global')
          .doc(userId)
          .get();

      final dadosUsuario = userDoc.data();

      // Boa prática: desativar em vez de deletar
      await _firestore.collection('usuarios_global').doc(userId).update({
        'status': 'inativo',
        'desativado_em': FieldValue.serverTimestamp(),
        'desativado_por': _auth.currentUser?.uid,
      });

      // ✅ REGISTRA DESATIVAÇÃO
      await _auditoria.registrar(
        tipoAcao: TipoAcaoAuditoria.deletar,
        entidade: 'usuario',
        entidadeId: userId,
        dadosAnteriores: dadosUsuario,
        dadosNovos: {'status': 'inativo'},
        observacao: 'Usuário foi desativado do sistema',
      );
    } catch (e) {
      print('Erro ao desativar usuário: $e');
      rethrow;
    }
  }

  // ================================
  // MÉTODOS AUXILIARES
  // ================================

  Future<Usuario?> getUsuario(String userId) async {
    final doc = await _firestore
        .collection('usuarios_global')
        .doc(userId)
        .get();

    if (!doc.exists) return null;
    return Usuario.fromFirestore(doc);
  }

  Stream<List<Usuario>> getUsuariosPendentes() {
    return _firestore
        .collection('usuarios_global')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Usuario.fromFirestore(doc)).toList(),
        );
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (_) {
      throw Exception('Não foi possível enviar o e-mail de recuperação.');
    }
  }
}
