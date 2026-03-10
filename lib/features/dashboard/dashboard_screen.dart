import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../pacientes/lista_pacientes_screen.dart';
import '../receitas/lista_renovacoes_screen.dart';
import 'admin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'MedConnect',
          style: TextStyle(
            color: Color(0xFF1E3A5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1E3A5F)),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: _buildBody(auth),
      bottomNavigationBar: _buildSafeBottomNavigation(auth),
    );
  }

  // ================================
  // MENU INFERIOR SEGURO
  // ================================
  Widget _buildSafeBottomNavigation(AppAuthProvider auth) {
    final items = _buildBottomItems(auth);

    if (items.length < 2) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
      );
    }

    if (_selectedIndex >= items.length) {
      _selectedIndex = 0;
    }

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: items,
    );
  }

  // ================================
  // ITENS BASEADOS NO PERFIL (RBAC)
  // ================================
  List<BottomNavigationBarItem> _buildBottomItems(AppAuthProvider auth) {
    final items = <BottomNavigationBarItem>[];

    if (auth.canViewPacientes) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        label: 'Pacientes',
      ));
    }

    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.medical_services),
      label: 'Renovações',
    ));

    if (auth.canViewRelatorios) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.assessment),
        label: 'Relatórios',
      ));
    }

    // 🔐 ADMINISTRADOR GLOBAL
    if (auth.isSuperAdmin) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Administração',
      ));
    }

    return items;
  }

  // ================================
  // TELAS BASEADAS NO PERFIL
  // ================================
  Widget _buildBody(AppAuthProvider auth) {
    final screens = <Widget>[];

    if (auth.canViewPacientes) {
      screens.add(const ListaPacientesScreen());
    }

    screens.add(const ListaRenovacoesScreen());

    if (auth.canViewRelatorios) {
      screens.add(const RelatoriosScreen());
    }

    // 🔐 ADMINISTRADOR GLOBAL
    if (auth.isSuperAdmin) {
      screens.add(const AdminScreen());
    }

    if (screens.isEmpty) {
      return const Center(
        child: Text('Nenhuma tela disponível'),
      );
    }

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return screens[_selectedIndex];
  }
}

// ================================
// TELA DE RELATÓRIOS
// ================================
class RelatoriosScreen extends StatelessWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    if (!auth.canViewRelatorios) {
      return const Center(
        child: Text(
          'Acesso negado',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return const Center(
      child: Text(
        'Relatórios',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}