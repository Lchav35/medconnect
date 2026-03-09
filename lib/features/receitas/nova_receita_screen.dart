import 'package:flutter/material.dart';
import '../../data/models/models.dart';

/// Tela de Nova Receita/Medicamento (baseada na primeira imagem fornecida)
class NovaReceitaScreen extends StatefulWidget {
  const NovaReceitaScreen({super.key});

  @override
  State<NovaReceitaScreen> createState() => _NovaReceitaScreenState();
}

class _NovaReceitaScreenState extends State<NovaReceitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeMedicamentoController = TextEditingController();
  final _dosagemController = TextEditingController();
  final _frequenciaController = TextEditingController();
  final _nomeMedicoController = TextEditingController();
  final _crmController = TextEditingController();
  final _observacoesController = TextEditingController();

  TipoReceita _tipoReceitaSelecionado = TipoReceita.brancaAguda;
  DateTime _dataReceita = DateTime.now();
  int _validadeDias = 30;

  @override
  void dispose() {
    _nomeMedicamentoController.dispose();
    _dosagemController.dispose();
    _frequenciaController.dispose();
    _nomeMedicoController.dispose();
    _crmController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Medicamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nome do medicamento
                TextFormField(
                  controller: _nomeMedicamentoController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do medicamento *',
                    prefixIcon: Icon(Icons.medical_services, color: Color(0xFF2E7D32)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Dosagem
                TextFormField(
                  controller: _dosagemController,
                  decoration: const InputDecoration(
                    labelText: 'Dosagem *',
                    prefixIcon: Icon(Icons.science, color: Color(0xFF2E7D32)),
                    hintText: 'Ex: 500mg, 10ml',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Frequência
                TextFormField(
                  controller: _frequenciaController,
                  decoration: const InputDecoration(
                    labelText: 'Frequência *',
                    prefixIcon: Icon(Icons.access_time, color: Color(0xFF2E7D32)),
                    hintText: 'Ex: 3x ao dia, 8/8h',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Tipo de Receita
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Receita *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TipoReceita>(
                        initialValue: _tipoReceitaSelecionado,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          TipoReceita.brancaAguda,
                          TipoReceita.brancaContinua,
                        ].map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _tipoReceitaSelecionado = value;
                              _validadeDias = value.validadeDias;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tipoReceitaSelecionado == TipoReceita.brancaAguda
                            ? 'Medicamentos comuns, pode ter validade de 30 ou 180 dias'
                            : 'Medicamentos de uso contínuo, validade de 180 dias',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Data da receita e Validade
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final data = await showDatePicker(
                            context: context,
                            initialDate: _dataReceita,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (data != null) {
                            setState(() {
                              _dataReceita = data;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data da receita',
                            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                          ),
                          child: Text(
                            '${_dataReceita.day.toString().padLeft(2, '0')}/${_dataReceita.month.toString().padLeft(2, '0')}/${_dataReceita.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Validade (dias)',
                        ),
                        child: DropdownButton<int>(
                          value: _validadeDias,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 30, child: Text('30 dias')),
                            DropdownMenuItem(value: 180, child: Text('180 dias')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _validadeDias = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nome do médico
                TextFormField(
                  controller: _nomeMedicoController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do médico',
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF2E7D32)),
                  ),
                ),
                const SizedBox(height: 16),
                // CRM do médico
                TextFormField(
                  controller: _crmController,
                  decoration: const InputDecoration(
                    labelText: 'CRM do médico',
                    prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF2E7D32)),
                  ),
                ),
                const SizedBox(height: 16),
                // Observações
                TextFormField(
                  controller: _observacoesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    prefixIcon: Icon(Icons.notes, color: Color(0xFF2E7D32)),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                // Botão Salvar
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Implementar salvamento da receita
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Medicamento salvo com sucesso!'),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'SALVAR MEDICAMENTO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
