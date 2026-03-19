import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import 'register_user_screen.dart';

class SelecionarPerfilScreen extends StatefulWidget {
  const SelecionarPerfilScreen({super.key});

  @override
  State<SelecionarPerfilScreen> createState() => _SelecionarPerfilScreenState();
}

class _SelecionarPerfilScreenState extends State<SelecionarPerfilScreen> {
  UserRole? _selectedRole;

  final List<Map<String, dynamic>> _perfis = [
    {
      'role': UserRole.gestorMunicipal, // <-- AGORA EXISTE!
      'icon': Icons.apartment,
      'color': Colors.blue,
      'descricao': 'Gerencie municípios e indicadores',
    },
    {
      'role': UserRole.gestorUnidade,
      'icon': Icons.local_hospital,
      'color': Colors.green,
      'descricao': 'Administre sua unidade de saúde',
    },
    {
      'role': UserRole.acs,
      'icon': Icons.health_and_safety,
      'color': Colors.orange,
      'descricao': 'Agente Comunitário de Saúde',
    },
    {
      'role': UserRole.medico,
      'icon': Icons.medical_services,
      'color': Colors.red,
      'descricao': 'Acesse receitas e prontuários',
    },
    {
      'role': UserRole.paciente, // <-- AGORA EXISTE!
      'icon': Icons.person,
      'color': Colors.purple,
      'descricao': 'Visualize seus dados de saúde',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar Conta',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 50,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selecione seu Perfil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Escolha o tipo de perfil que melhor descreve sua atuação no sistema',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Grid de Perfis
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _perfis.length,
                itemBuilder: (context, index) {
                  final perfil = _perfis[index];
                  final isSelected = _selectedRole == perfil['role'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRole = perfil['role'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? (perfil['color'] as Color).withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1),
                            blurRadius: isSelected ? 15 : 8,
                            offset: Offset(0, isSelected ? 5 : 3),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? perfil['color']
                              : Colors.grey.shade200,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (perfil['color'] as Color).withOpacity(
                                0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              perfil['icon'],
                              size: 35,
                              color: perfil['color'],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            perfil['role'].label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              perfil['descricao'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botão Continuar
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _selectedRole == null
                      ? null
                      : () => _navegarParaProximaTela(context, _selectedRole!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: _selectedRole == null ? 0 : 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Continuar como ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_selectedRole != null)
                        Text(
                          _selectedRole!.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Voltar',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _navegarParaProximaTela(BuildContext context, UserRole role) {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    authProvider.setSelectedRole(role);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil ${role.label} selecionado!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterUserScreen(perfilInicial: role),
      ),
    );
  }
}
