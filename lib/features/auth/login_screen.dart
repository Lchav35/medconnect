import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/services/auth_service.dart';
import 'register_user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController();
  final _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider =
          Provider.of<AppAuthProvider>(
              context,
              listen: false);

      final success =
          await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (!success &&
          authProvider.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email =
        _emailController.text.trim();

    if (email.isEmpty) return;

    try {
      await AuthService()
          .resetPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              'E-mail de recuperação enviado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
              e.toString().replaceAll(
                  'Exception: ',
                  '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth =
        context.watch<AppAuthProvider>();

    // 🔥 MOSTRA ERRO AUTOMÁTICO
    if (auth.error != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(auth.error!),
            backgroundColor: Colors.red,
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                const SizedBox(
                    height: 60),
                const Icon(
                  Icons.local_hospital,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(
                    height: 16),
                const Text(
                  'Receita Renew',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                    height: 48),
                TextFormField(
                  controller:
                      _emailController,
                  decoration:
                      const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(
                        Icons
                            .email_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Informe o e-mail';
                    }
                    if (!value
                        .contains('@')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                    height: 16),
                TextFormField(
                  controller:
                      _passwordController,
                  obscureText:
                      _obscurePassword,
                  decoration:
                      InputDecoration(
                    labelText: 'Senha',
                    prefixIcon:
                        const Icon(
                            Icons
                                .lock_outline),
                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility
                            : Icons
                                .visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Informe a senha';
                    }
                    if (value.length <
                        6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                    height: 24),
                auth.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed:
                            _handleLogin,
                        child: const Text(
                            'ENTRAR'),
                      ),
                const SizedBox(
                    height: 16),
                TextButton(
                  onPressed:
                      _handleForgotPassword,
                  child: const Text(
                      'Esqueceu sua senha?'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RegisterUserScreen(),
                      ),
                    );
                  },
                  child: const Text(
                      'Cadastrar novo usuário'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}