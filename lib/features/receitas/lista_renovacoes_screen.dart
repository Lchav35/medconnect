import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'nova_receita_screen.dart';

/// Tela de Renovações (baseada na segunda imagem fornecida)
class ListaRenovacoesScreen extends StatelessWidget {
  const ListaRenovacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saudação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, ${currentUser?.role.displayName ?? "Usuário"}.',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Cards de Renovação
          const Text(
            'Próximas Renovações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRenovacaoCard(
                  context,
                  'Receita A\n(Amarela) -\nUrgente',
                  '2',
                  '2 pacientes',
                  Colors.red,
                  Icons.notification_important,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRenovacaoCard(
                  context,
                  'Receita B\n(Azul) -\nAtenção',
                  '5',
                  '5 pacientes',
                  Colors.yellow[700]!,
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRenovacaoCard(
                  context,
                  'Simples\n(Branca) -\nPendente',
                  '10',
                  '10 pacientes',
                  Colors.blue,
                  Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Lista de Pacientes
          const Text(
            'Lista de Pacientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPacienteCard(
            context,
            'Maria Silva',
            'Agendado',
            Colors.green[100]!,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildPacienteCard(
            context,
            'João Santos',
            'Visita Pendente',
            Colors.green[100]!,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildPacienteCard(
            context,
            'Ana Costa',
            'Em Acompanhamento',
            Colors.orange[100]!,
            Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildPacienteCard(
            context,
            'Carlos Oliveira',
            'Renovação Urgente',
            Colors.red[100]!,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildRenovacaoCard(
    BuildContext context,
    String titulo,
    String quantidade,
    String subtitulo,
    Color cor,
    IconData icone,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icone, color: cor, size: 32),
          const SizedBox(height: 8),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: cor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quantidade,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacienteCard(
    BuildContext context,
    String nome,
    String status,
    Color backgroundColor,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[600], size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // Navegar para detalhes do paciente ou nova receita
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NovaReceitaScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
