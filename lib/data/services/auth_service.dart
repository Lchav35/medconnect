import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ================================
  // FIREBASE USER
  // ================================

  firebase_auth.User? get currentFirebaseUser =>
      _auth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges =>
      _auth.authStateChanges();

  // ================================
  // LOGIN COM TRATAMENTO PROFISSIONAL
  // ================================

  Future<Usuario?> signIn(
    String email,
    String password,
  ) async {
    try {
      final userCredential =
          await _auth.signInWithEmailAndPassword(
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

      await _firestore
          .collection('usuarios_global')
          .doc(usuario.id)
          .update({
        'ultimo_acesso': FieldValue.serverTimestamp(),
      });

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
  // REGISTRO COM TRATAMENTO PROFISSIONAL
  // ================================

  Future<Usuario?> registerUser({
    required String email,
    required String password,
    required String nome,
  }) async {
    try {
      final userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Erro ao criar usuário.');
      }

      await _firestore
          .collection('usuarios_global')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'email': email,
        'nome': nome,
        'role': 'acs',
        'municipio_id': 'pendente', // ✅ agora é string
        'unidade_id': null,
        'status': 'pendente',
        'created_at': FieldValue.serverTimestamp(),
      });

      await _auth.signOut();

      return await getUsuario(userCredential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este e-mail já está cadastrado.');
      } else if (e.code == 'weak-password') {
        throw Exception(
            'A senha deve ter pelo menos 6 caracteres.');
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
  // LOGOUT
  // ================================

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ================================
  // BUSCAR USUÁRIO
  // ================================

  Future<Usuario?> getUsuario(String userId) async {
    final doc = await _firestore
        .collection('usuarios_global')
        .doc(userId)
        .get();

    if (!doc.exists) return null;

    return Usuario.fromFirestore(doc);
  }

  // ================================
  // LISTAR PENDENTES
  // ================================

  Stream<List<Usuario>> getUsuariosPendentes() {
    return _firestore
        .collection('usuarios_global')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Usuario.fromFirestore(doc))
            .toList());
  }

  // ================================
  // APROVAR USUÁRIO
  // ================================

  Future<void> aprovarUsuario(String userId) async {
    await _firestore
        .collection('usuarios_global')
        .doc(userId)
        .update({
      'status': 'aprovado',
      'aprovado_em': FieldValue.serverTimestamp(),
    });
  }

  // ================================
  // RESETAR SENHA
  // ================================

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (_) {
      throw Exception(
          'Não foi possível enviar o e-mail de recuperação.');
    }
  }
}