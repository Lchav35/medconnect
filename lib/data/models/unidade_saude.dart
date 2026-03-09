import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Unidade de Saúde (UBS/USF)
class UnidadeSaude {
  final String id;
  final String municipioId;
  final String nome;
  final String? cnes; // Cadastro Nacional de Estabelecimentos de Saúde
  final Endereco endereco;
  final String? telefone;
  final String? email;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;

  UnidadeSaude({
    required this.id,
    required this.municipioId,
    required this.nome,
    this.cnes,
    required this.endereco,
    this.telefone,
    this.email,
    this.ativo = true,
    required this.criadoEm,
    this.atualizadoEm,
  });

  factory UnidadeSaude.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UnidadeSaude(
      id: doc.id,
      municipioId: data['municipio_id'] as String? ?? '',
      nome: data['nome'] as String? ?? '',
      cnes: data['cnes'] as String?,
      endereco: Endereco.fromMap(data['endereco'] as Map<String, dynamic>? ?? {}),
      telefone: data['telefone'] as String?,
      email: data['email'] as String?,
      ativo: data['ativo'] as bool? ?? true,
      criadoEm: (data['criado_em'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm: (data['atualizado_em'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'municipio_id': municipioId,
      'nome': nome,
      'cnes': cnes,
      'endereco': endereco.toMap(),
      'telefone': telefone,
      'email': email,
      'ativo': ativo,
      'criado_em': Timestamp.fromDate(criadoEm),
      'atualizado_em': atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
    };
  }

  UnidadeSaude copyWith({
    String? nome,
    String? cnes,
    Endereco? endereco,
    String? telefone,
    String? email,
    bool? ativo,
    DateTime? atualizadoEm,
  }) {
    return UnidadeSaude(
      id: id,
      municipioId: municipioId,
      nome: nome ?? this.nome,
      cnes: cnes ?? this.cnes,
      endereco: endereco ?? this.endereco,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }
}

/// Modelo de Endereço
class Endereco {
  final String logradouro;
  final String? numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;

  Endereco({
    required this.logradouro,
    this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  factory Endereco.fromMap(Map<String, dynamic> map) {
    return Endereco(
      logradouro: map['logradouro'] as String? ?? '',
      numero: map['numero'] as String?,
      complemento: map['complemento'] as String?,
      bairro: map['bairro'] as String? ?? '',
      cidade: map['cidade'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      cep: map['cep'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
    };
  }

  String get enderecoCompleto {
    final partes = <String>[
      logradouro,
      if (numero != null) numero!,
      if (complemento != null) complemento!,
      bairro,
      '$cidade - $estado',
      'CEP: $cep',
    ];
    return partes.join(', ');
  }

  String get enderecoResumido {
    return '$logradouro${numero != null ? ", $numero" : ""} - $bairro, $cidade/$estado';
  }
}
