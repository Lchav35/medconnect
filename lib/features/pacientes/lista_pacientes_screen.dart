import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/paciente.dart';
import '../../data/models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../data/services/paciente_service.dart';

class ListaPacientesScreen extends StatefulWidget {
  const ListaPacientesScreen({super.key});

  @override
  State<ListaPacientesScreen> createState() =>
      _ListaPacientesScreenState();
}

class _ListaPacientesScreenState
    extends State<ListaPacientesScreen> {
  final PacienteService _pacienteService =
      PacienteService();

  @override
  Widget build(BuildContext context) {
    final auth =
        Provider.of<AuthProvider>(context);

    final Usuario? usuario =
        auth.currentUser; // 🔥 AGORA É Usuario

    Stream<List<Paciente>> stream =
        const Stream.empty();

    if (usuario != null) {
      if (auth.isGestorUnidade ||
          auth.isAcs) {
        stream = _pacienteService
            .getPacientesPorUnidade(
                usuario.unidadeId ?? '');
      } else {
        stream = _pacienteService
            .getPacientesPorMunicipio(
                usuario.municipioId ?? '');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Controle de Pacientes'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Paciente>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Erro ao carregar dados: ${snapshot.error}'));
          }

          final pacientes =
              snapshot.data ?? [];

          if (pacientes.isEmpty) {
            return const Center(
                child: Text(
                    'Nenhum paciente encontrado.'));
          }

          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder:
                (context, index) {
              final paciente =
                  pacientes[index];

              return Card(
                margin:
                    const EdgeInsets
                        .symmetric(
                            horizontal: 16,
                            vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.blueAccent,
                    child: Text(
                      paciente.nomeCompleto
                              .isNotEmpty
                          ? paciente
                              .nomeCompleto[0]
                          : 'P',
                      style:
                          const TextStyle(
                              color: Colors
                                  .white),
                    ),
                  ),
                  title: Text(
                    paciente.nomeCompleto,
                    style:
                        const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold),
                  ),
                  subtitle: Text(
                      'CPF: ${paciente.cpfFormatado}'),
                  trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16),
                  onTap: () {
                    // abrir detalhes
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          // adicionar paciente
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}