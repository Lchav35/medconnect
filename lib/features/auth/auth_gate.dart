import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return DashboardScreen(); // ← Se estiver logado, vai direto pro Dashboard
        }
        if (authProvider.selectedRole == null) {
          return SelecionarPerfilScreen(); // ← Se não tiver perfil, mostra seleção
        }
        return LoginScreen();
      },
    );
  }
}
