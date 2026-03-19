import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../data/services/documento_service.dart';
import '../../core/enums/user_role.dart';

class RegisterUserScreen extends StatefulWidget {
  final UserRole? perfilInicial;

  const RegisterUserScreen({super.key, this.perfilInicial});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers básicos
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();

  // Controllers específicos por perfil
  final _crmController = TextEditingController();
  final _especialidadeController = TextEditingController();
  final _nisController = TextEditingController();
  final _cnesController = TextEditingController();
  final _cargoController = TextEditingController();

  // Dados adicionais
  DateTime? _dataNascimento;
  UserRole? _perfilSelecionado;
  String? _municipioSelecionado;
  String? _unidadeSelecionada;

  // Upload de arquivos
  final ImagePicker _picker = ImagePicker();
  final DocumentoService _documentoService = DocumentoService();

  XFile? _fotoPerfil;
  Map<String, List<XFile>> _documentos = {};
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Listas para dropdowns
  List<String> _municipios = [];
  List<String> _unidades = [];
  bool _carregandoUnidades = false;

  // Lista de tipos de documento por perfil
  late final Map<UserRole, List<Map<String, dynamic>>> _documentosPorPerfil = {
    UserRole.paciente: [
      {'tipo': 'rg', 'label': 'RG', 'icon': Icons.badge, 'obrigatorio': true},
      {
        'tipo': 'cpf',
        'label': 'CPF',
        'icon': Icons.credit_card,
        'obrigatorio': true,
      },
      {
        'tipo': 'comprovanteResidencia',
        'label': 'Comprovante de Residência',
        'icon': Icons.home,
        'obrigatorio': true,
      },
      {
        'tipo': 'cartaoSus',
        'label': 'Cartão SUS',
        'icon': Icons.health_and_safety,
        'obrigatorio': true,
      },
    ],
    UserRole.acs: [
      {'tipo': 'rg', 'label': 'RG', 'icon': Icons.badge, 'obrigatorio': true},
      {
        'tipo': 'cpf',
        'label': 'CPF',
        'icon': Icons.credit_card,
        'obrigatorio': true,
      },
      {
        'tipo': 'comprovanteResidencia',
        'label': 'Comprovante de Residência',
        'icon': Icons.home,
        'obrigatorio': true,
      },
      {
        'tipo': 'certidaoAcs',
        'label': 'Certidão ACS',
        'icon': Icons.elderly,
        'obrigatorio': true,
      },
    ],
    UserRole.medico: [
      {'tipo': 'rg', 'label': 'RG', 'icon': Icons.badge, 'obrigatorio': true},
      {
        'tipo': 'cpf',
        'label': 'CPF',
        'icon': Icons.credit_card,
        'obrigatorio': true,
      },
      {
        'tipo': 'crm',
        'label': 'CRM',
        'icon': Icons.medical_services,
        'obrigatorio': true,
      },
      {
        'tipo': 'especialidade',
        'label': 'Comprovante de Especialidade',
        'icon': Icons.school,
        'obrigatorio': false,
      },
    ],
    UserRole.gestorUnidade: [
      {'tipo': 'rg', 'label': 'RG', 'icon': Icons.badge, 'obrigatorio': true},
      {
        'tipo': 'cpf',
        'label': 'CPF',
        'icon': Icons.credit_card,
        'obrigatorio': true,
      },
      {
        'tipo': 'nomeacao',
        'label': 'Termo de Nomeação',
        'icon': Icons.description,
        'obrigatorio': true,
      },
    ],
    UserRole.gestorMunicipal: [
      {'tipo': 'rg', 'label': 'RG', 'icon': Icons.badge, 'obrigatorio': true},
      {
        'tipo': 'cpf',
        'label': 'CPF',
        'icon': Icons.credit_card,
        'obrigatorio': true,
      },
      {
        'tipo': 'nomeacao',
        'label': 'Termo de Nomeação',
        'icon': Icons.description,
        'obrigatorio': true,
      },
    ],
  };

  List<Map<String, dynamic>> _tiposDocumento = [];

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    print('Perfil recebido: ${widget.perfilInicial}');
    _perfilSelecionado = widget.perfilInicial;
    _carregarMunicipios();
    _atualizarDocumentosPorPerfil();
  }

  void _atualizarDocumentosPorPerfil() {
    if (_perfilSelecionado != null) {
      setState(() {
        _tiposDocumento = _documentosPorPerfil[_perfilSelecionado!] ?? [];
      });
    }
  }

  Future<void> _carregarMunicipios() async {
    setState(() {
      _municipios = ['São Paulo', 'Rio de Janeiro', 'Belo Horizonte'];
    });
  }

  Future<void> _carregarUnidades(String municipio) async {
    setState(() {
      _carregandoUnidades = true;
      _unidades = ['UBS Centro', 'UBS Norte', 'UBS Sul'];
      _carregandoUnidades = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _crmController.dispose();
    _especialidadeController.dispose();
    _nisController.dispose();
    _cnesController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFotoPerfil() async {
    try {
      final foto = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (foto != null) {
        setState(() => _fotoPerfil = foto);
      }
    } catch (e) {
      _mostrarErro('Erro ao selecionar foto: $e');
    }
  }

  Future<void> _selecionarDocumento(String tipo, String label) async {
    try {
      final arquivo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 70,
      );
      if (arquivo != null) {
        setState(() {
          if (_documentos[tipo] == null) {
            _documentos[tipo] = [];
          }
          _documentos[tipo]!.add(arquivo);
        });
      }
    } catch (e) {
      _mostrarErro('Erro ao selecionar documento: $e');
    }
  }

  void _removerDocumento(String tipo, int index) {
    setState(() {
      _documentos[tipo]?.removeAt(index);
      if (_documentos[tipo]?.isEmpty ?? true) {
        _documentos.remove(tipo);
      }
    });
  }

  Future<void> _selecionarDataNascimento() async {
    try {
      final DateTime? data = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        locale: const Locale('pt', 'BR'),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );

      if (data != null) {
        setState(() => _dataNascimento = data);
      }
    } catch (e) {
      print('Erro no date picker: $e');
      _mostrarErro('Erro ao abrir calendário. Tente novamente.');
    }
  }

  bool _validarDocumentosObrigatorios() {
    if (_perfilSelecionado == null) return true;

    final docsObrigatorios = _tiposDocumento
        .where((d) => d['obrigatorio'] == true)
        .map((d) => d['tipo'] as String)
        .toList();

    for (var doc in docsObrigatorios) {
      if (_documentos[doc] == null || _documentos[doc]!.isEmpty) {
        _mostrarErro('Documento ${_buscarLabelPorTipo(doc)} é obrigatório');
        return false;
      }
    }
    return true;
  }

  String _buscarLabelPorTipo(String tipo) {
    for (var doc in _tiposDocumento) {
      if (doc['tipo'] == tipo) return doc['label'];
    }
    return tipo;
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_perfilSelecionado == null) {
      _mostrarErro('Selecione um perfil');
      return;
    }

    if (!_validarDocumentosObrigatorios()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

      Map<String, dynamic> metadados = {
        'telefone': _telefoneController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'rg': _rgController.text.trim(),
        'dataNascimento': _dataNascimento?.toIso8601String(),
        'municipio': _municipioSelecionado,
        'unidade': _unidadeSelecionada,
      };

      switch (_perfilSelecionado) {
        case UserRole.medico:
          metadados.addAll({
            'crm': _crmController.text.trim(),
            'especialidade': _especialidadeController.text.trim(),
          });
          break;
        case UserRole.acs:
          metadados.addAll({
            'nis': _nisController.text.trim(),
            'cnes': _cnesController.text.trim(),
          });
          break;
        case UserRole.gestorUnidade:
        case UserRole.gestorMunicipal:
          metadados.addAll({
            'cargo': _cargoController.text.trim(),
            'cnes': _cnesController.text.trim(),
          });
          break;
        default:
          break;
      }

      final success = await authProvider.registerUser(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
        nome: _nomeController.text.trim(),
        role: _perfilSelecionado!,
        metadados: metadados,
      );

      if (!mounted) return;

      if (success) {
        final usuarioId = authProvider.userId;

        if (usuarioId != null) {
          if (_fotoPerfil != null) {
            try {
              await _documentoService.uploadDocumento(
                arquivo: _fotoPerfil!,
                usuarioId: usuarioId,
                tipo: 'fotoPerfil',
                usuarioNome: _nomeController.text,
                usuarioRole: _perfilSelecionado!.value,
              );
            } catch (e) {
              print('Erro ao upload foto: $e');
            }
          }

          for (var entry in _documentos.entries) {
            for (var arquivo in entry.value) {
              try {
                await _documentoService.uploadDocumento(
                  arquivo: arquivo,
                  usuarioId: usuarioId,
                  tipo: entry.key,
                  usuarioNome: _nomeController.text,
                  usuarioRole: _perfilSelecionado!.value,
                );
              } catch (e) {
                print('Erro ao upload ${entry.key}: $e');
              }
            }
          }
        }

        if (!mounted) return;
        _mostrarSucesso('Cadastro realizado com sucesso!');
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        _mostrarErro(authProvider.error ?? 'Erro ao cadastrar');
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarErro('Erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_perfilSelecionado == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Perfil não selecionado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOTO DE PERFIL
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _selecionarFotoPerfil,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                image: _fotoPerfil != null
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(_fotoPerfil!.path),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                border: Border.all(
                                  color: Colors.teal,
                                  width: 2,
                                ),
                              ),
                              child: _fotoPerfil == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: Colors.grey[600],
                                        ),
                                        const Text(
                                          'Adicionar foto',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          if (_fotoPerfil != null)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DADOS BÁSICOS
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.teal),
                                const SizedBox(width: 8),
                                Text(
                                  'Dados de ${_perfilSelecionado!.label}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),

                            TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                labelText: 'Nome Completo *',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Campo obrigatório';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-mail *',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Campo obrigatório';
                                if (!value.contains('@'))
                                  return 'E-mail inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _telefoneController,
                              decoration: const InputDecoration(
                                labelText: 'Telefone',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                                hintText: '(11) 99999-9999',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cpfController,
                                    decoration: const InputDecoration(
                                      labelText: 'CPF',
                                      prefixIcon: Icon(Icons.credit_card),
                                      border: OutlineInputBorder(),
                                      hintText: '000.000.000-00',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _rgController,
                                    decoration: const InputDecoration(
                                      labelText: 'RG',
                                      prefixIcon: Icon(Icons.badge),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            InkWell(
                              onTap: _selecionarDataNascimento,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Data de Nascimento',
                                  prefixIcon: Icon(Icons.cake),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _dataNascimento != null
                                      ? _dateFormat.format(_dataNascimento!)
                                      : 'Selecione uma data',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CAMPOS ESPECÍFICOS POR PERFIL
                    if (_perfilSelecionado == UserRole.medico) ...[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _crmController,
                                decoration: const InputDecoration(
                                  labelText: 'CRM *',
                                  prefixIcon: Icon(Icons.medical_services),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Campo obrigatório';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _especialidadeController,
                                decoration: const InputDecoration(
                                  labelText: 'Especialidade',
                                  prefixIcon: Icon(Icons.school),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (_perfilSelecionado == UserRole.acs) ...[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nisController,
                                decoration: const InputDecoration(
                                  labelText: 'NIS *',
                                  prefixIcon: Icon(Icons.numbers),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Campo obrigatório';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _cnesController,
                                decoration: const InputDecoration(
                                  labelText: 'CNES da Unidade *',
                                  prefixIcon: Icon(Icons.local_hospital),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Campo obrigatório';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (_perfilSelecionado == UserRole.gestorUnidade ||
                        _perfilSelecionado == UserRole.gestorMunicipal) ...[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _cargoController,
                                decoration: const InputDecoration(
                                  labelText: 'Cargo *',
                                  prefixIcon: Icon(Icons.work),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Campo obrigatório';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _cnesController,
                                decoration: const InputDecoration(
                                  labelText: 'CNES da Unidade',
                                  prefixIcon: Icon(Icons.local_hospital),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // VÍNCULOS
                    if (_perfilSelecionado != null &&
                        _perfilSelecionado != UserRole.paciente) ...[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vínculos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),

                              DropdownButtonFormField<String>(
                                value: _municipioSelecionado,
                                decoration: const InputDecoration(
                                  labelText: 'Município *',
                                  prefixIcon: Icon(Icons.location_city),
                                  border: OutlineInputBorder(),
                                ),
                                items: _municipios.map((municipio) {
                                  return DropdownMenuItem(
                                    value: municipio,
                                    child: Text(municipio),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _municipioSelecionado = value;
                                    _unidadeSelecionada = null;
                                    if (value != null) {
                                      _carregarUnidades(value);
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null)
                                    return 'Selecione um município';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              if (_perfilSelecionado !=
                                  UserRole.gestorMunicipal) ...[
                                _carregandoUnidades
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : DropdownButtonFormField<String>(
                                        value: _unidadeSelecionada,
                                        decoration: const InputDecoration(
                                          labelText: 'Unidade de Saúde *',
                                          prefixIcon: Icon(
                                            Icons.local_hospital,
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        items: _unidades.map((unidade) {
                                          return DropdownMenuItem(
                                            value: unidade,
                                            child: Text(unidade),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _unidadeSelecionada = value;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null)
                                            return 'Selecione uma unidade';
                                          return null;
                                        },
                                      ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],

                    // SENHA
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lock, color: Colors.teal),
                                const SizedBox(width: 8),
                                const Text(
                                  'Segurança',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),

                            TextFormField(
                              controller: _senhaController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Senha *',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Campo obrigatório';
                                if (value.length < 6)
                                  return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _confirmarSenhaController,
                              obscureText: _obscurePassword,
                              decoration: const InputDecoration(
                                labelText: 'Confirmar Senha *',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Campo obrigatório';
                                if (value != _senhaController.text)
                                  return 'As senhas não conferem';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DOCUMENTOS
                    if (_tiposDocumento.isNotEmpty) ...[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.folder, color: Colors.teal),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Documentos Necessários',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              const Text(
                                'Os documentos marcados com * são obrigatórios',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),

                              ..._tiposDocumento.map(
                                (doc) => _buildDocumentoField(
                                  doc['tipo'],
                                  doc['label'],
                                  doc['icon'],
                                  doc['obrigatorio'] == true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // BOTÃO
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'CADASTRAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDocumentoField(
    String tipo,
    String label,
    IconData icon,
    bool obrigatorio,
  ) {
    final documentos = _documentos[tipo] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    obrigatorio ? '$label *' : label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _selecionarDocumento(tipo, label),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload'),
                ),
              ],
            ),
          ),

          if (documentos.isNotEmpty)
            ...documentos.asMap().entries.map((entry) {
              final idx = entry.key;
              final arquivo = entry.value;
              return ListTile(
                leading: Icon(
                  arquivo.path.endsWith('.pdf')
                      ? Icons.picture_as_pdf
                      : Icons.image,
                  color: Colors.teal,
                ),
                title: Text(
                  arquivo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _removerDocumento(tipo, idx),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
