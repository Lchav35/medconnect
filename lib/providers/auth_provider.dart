import 'package:flutter/material.dart';

import '../../data/models/usuario.dart';
import '../../data/services/auth_service.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/user_status.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  Usuario? _currentUser;

  AppAuthProvider() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadUsuario(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // ================================
  // GETTERS
  // ================================

  bool get isAuthenticated =>
      _authService.currentFirebaseUser != null;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Usuario? get currentUser => _currentUser;

  UserRole? get role =>
      _currentUser != null
          ? UserRole.fromValue(_currentUser!.role.value)
          : null;

  UserStatus? get status =>
      _currentUser != null
          ? UserStatus.fromString(_currentUser!.status)
          : null;

  bool get isSuperAdmin => role == UserRole.superAdmin;

  bool get isGestorUnidade => role == UserRole.gestorUnidade;

  bool get isAcs => role == UserRole.acs;

  bool get canViewPacientes =>
      isSuperAdmin || isGestorUnidade || isAcs;

  bool get canViewRelatorios =>
      isSuperAdmin || role == UserRole.gestorUnidade;

  // ================================
  // CARREGAR USUÁRIO (BLINDADO)
  // ================================

  Future<void> _loadUsuario(String uid) async {
    try {
      final usuario =
          await _authService.getUsuario(uid);

      // 🔒 Se não existir documento → desloga
      if (usuario == null) {
        await logout();
        return;
      }

      // 🔒 Se não estiver aprovado → desloga imediatamente
      if (usuario.status != 'aprovado') {
        await logout();
        _error =
            'Seu cadastro está aguardando aprovação.';
        notifyListeners();
        return;
      }

      // ✅ Só define usuário se estiver aprovado
      _currentUser = usuario;
      notifyListeners();
    } catch (_) {
      await logout();
    }
  }

  // ================================
  // LOGIN
  // ================================

  Future<bool> signIn(
      String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final usuario =
          await _authService.signIn(
        email,
        password,
      );

      _currentUser = usuario;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll(
          'Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // REGISTRO
  // ================================

  Future<bool> registerUser({
    required String email,
    required String password,
    required String nome,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.registerUser(
        email: email,
        password: password,
        nome: nome,
      );

      return true;
    } catch (e) {
      _error = e.toString().replaceAll(
          'Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // LOGOUT
  // ================================

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

typedef AuthProvider = AppAuthProvider;