import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';
import 'unidade_saude.dart';

/// Modelo profissional de Paciente
class Paciente {
  final String id;

  // 🔐 Controle de escopo
  final String municipioId;
  final String unidadeId;
  final String acsId;

  // 👤 Dados pessoais
  final String nomeCompleto;
  final String cpf;
  final DateTime dataNascimento;
  final String? cartaoSus;
  final String? telefone;

  // 📍 Endereço
  final Endereco endereco;

  // 📊 Controle
  final StatusPaciente status;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;
  final String? observacoes;

  Paciente({
    required this.id,
    required this.municipioId,
    required this.unidadeId,
    required this.acsId,
    required this.nomeCompleto,
    required this.cpf,
    required this.dataNascimento,
    this.cartaoSus,
    this.telefone,
    required this.endereco,
    this.status = StatusPaciente.ativo,
    required this.criadoEm,
    this.atualizadoEm,
    this.observacoes,
  });

  // ==========================
  // ⚡ ATALHOS (Resolvendo o erro de compilação)
  // ==========================

  // Este getter faz com que 'paciente.nome' funcione retornando 'nomeCompleto'
  String get nome => nomeCompleto;

  // ==========================
  // 🔄 FROM FIRESTORE
  // ==========================

  factory Paciente.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Paciente(
      id: doc.id,
      municipioId: data['municipio_id'] ?? '',
      unidadeId: data['unidade_id'] ?? '',
      acsId: data['acs_id'] ?? '',
      nomeCompleto: data['nome_completo'] ?? '',
      cpf: data['cpf'] ?? '',
      dataNascimento:
          (data['data_nascimento'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      cartaoSus: data['cartao_sus'],
      telefone: data['telefone'],
      endereco: Endereco.fromMap(
        data['endereco'] as Map<String, dynamic>? ?? {},
      ),
      status: StatusPaciente.fromString(
        data['status'] ?? 'ativo',
      ),
      criadoEm:
          (data['criado_em'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      atualizadoEm:
          (data['atualizado_em'] as Timestamp?)?.toDate(),
      observacoes: data['observacoes'],
    );
  }

  // ==========================
  // 🔥 TO FIRESTORE
  // ==========================

  Map<String, dynamic> toFirestore() {
    return {
      'municipio_id': municipioId,
      'unidade_id': unidadeId,
      'acs_id': acsId,
      'nome_completo': nomeCompleto,
      'cpf': cpf,
      'data_nascimento': Timestamp.fromDate(dataNascimento),
      'cartao_sus': cartaoSus,
      'telefone': telefone,
      'endereco': endereco.toMap(),
      'status': status.value,
      'criado_em': Timestamp.fromDate(criadoEm),
      'atualizado_em': atualizadoEm != null
          ? Timestamp.fromDate(atualizadoEm!)
          : null,
      'observacoes': observacoes,
    };
  }

  // ==========================
  // 📅 IDADE CALCULADA
  // ==========================

  int get idade {
    final hoje = DateTime.now();
    int idade = hoje.year - dataNascimento.year;

    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month &&
            hoje.day < dataNascimento.day)) {
      idade--;
    }

    return idade;
  }

  // ==========================
  // 🪪 CPF FORMATADO
  // ==========================

  String get cpfFormatado {
    if (cpf.length != 11) return cpf;

    return '${cpf.substring(0, 3)}.'
        '${cpf.substring(3, 6)}.'
        '${cpf.substring(6, 9)}-'
        '${cpf.substring(9)}';
  }

  // ==========================
  // 🔄 COPY WITH (para updates)
  // ==========================

  Paciente copyWith({
    String? unidadeId,
    String? acsId,
    String? telefone,
    String? observacoes,
    StatusPaciente? status,
    DateTime? atualizadoEm,
  }) {
    return Paciente(
      id: id,
      municipioId: municipioId,
      unidadeId: unidadeId ?? this.unidadeId,
      acsId: acsId ?? this.acsId,
      nomeCompleto: nomeCompleto,
      cpf: cpf,
      dataNascimento: dataNascimento,
      cartaoSus: cartaoSus,
      telefone: telefone ?? this.telefone,
      endereco: endereco,
      status: status ?? this.status,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
      observacoes: observacoes ?? this.observacoes,
    );
  }
}