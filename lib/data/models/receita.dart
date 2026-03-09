import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

/// Modelo de Medicamento na prescrição
class Medicamento {
  final String nome;
  final String dosagem;
  final String frequencia;
  final String? duracao;
  final CategoriaMedicamento categoria;
  final TipoReceita tipoReceita;
  final String? observacoes;

  Medicamento({
    required this.nome,
    required this.dosagem,
    required this.frequencia,
    this.duracao,
    required this.categoria,
    required this.tipoReceita,
    this.observacoes,
  });

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      nome: map['nome'] as String? ?? '',
      dosagem: map['dosagem'] as String? ?? '',
      frequencia: map['frequencia'] as String? ?? '',
      duracao: map['duracao'] as String?,
      categoria: CategoriaMedicamento.fromString(map['categoria'] as String? ?? 'outros'),
      tipoReceita: TipoReceita.fromString(map['tipo_receita'] as String? ?? 'branca_aguda'),
      observacoes: map['observacoes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dosagem': dosagem,
      'frequencia': frequencia,
      'duracao': duracao,
      'categoria': categoria.value,
      'tipo_receita': tipoReceita.value,
      'observacoes': observacoes,
    };
  }

  bool get isControlado =>
      tipoReceita == TipoReceita.azul || tipoReceita == TipoReceita.amarela;
}

/// Modelo de Receita Médica
class Receita {
  final String id;
  final String municipioId;
  final String unidadeId;
  final String pacienteId;
  final String pacienteNome;
  final String medicoId;
  final String medicoNome;
  final String? medicoCRM;
  final String acsId;
  final List<Medicamento> medicamentos;
  final StatusReceita status;
  final DateTime dataReceita;
  final int validadeDias;
  final DateTime? dataAssinatura;
  final DateTime? dataImpressao;
  final String? fotoReceitaUrl;
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;

  Receita({
    required this.id,
    required this.municipioId,
    required this.unidadeId,
    required this.pacienteId,
    required this.pacienteNome,
    required this.medicoId,
    required this.medicoNome,
    this.medicoCRM,
    required this.acsId,
    required this.medicamentos,
    this.status = StatusReceita.pendente,
    required this.dataReceita,
    this.validadeDias = 30,
    this.dataAssinatura,
    this.dataImpressao,
    this.fotoReceitaUrl,
    this.observacoes,
    required this.criadoEm,
    this.atualizadoEm,
  });

  factory Receita.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Receita(
      id: doc.id,
      municipioId: data['municipio_id'] as String? ?? '',
      unidadeId: data['unidade_id'] as String? ?? '',
      pacienteId: data['paciente_id'] as String? ?? '',
      pacienteNome: data['paciente_nome'] as String? ?? '',
      medicoId: data['medico_id'] as String? ?? '',
      medicoNome: data['medico_nome'] as String? ?? '',
      medicoCRM: data['medico_crm'] as String?,
      acsId: data['acs_id'] as String? ?? '',
      medicamentos: (data['medicamentos'] as List<dynamic>?)
              ?.map((m) => Medicamento.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      status: StatusReceita.fromString(data['status'] as String? ?? 'pendente'),
      dataReceita: (data['data_receita'] as Timestamp?)?.toDate() ?? DateTime.now(),
      validadeDias: data['validade_dias'] as int? ?? 30,
      dataAssinatura: (data['data_assinatura'] as Timestamp?)?.toDate(),
      dataImpressao: (data['data_impressao'] as Timestamp?)?.toDate(),
      fotoReceitaUrl: data['foto_receita_url'] as String?,
      observacoes: data['observacoes'] as String?,
      criadoEm: (data['criado_em'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm: (data['atualizado_em'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'municipio_id': municipioId,
      'unidade_id': unidadeId,
      'paciente_id': pacienteId,
      'paciente_nome': pacienteNome,
      'medico_id': medicoId,
      'medico_nome': medicoNome,
      'medico_crm': medicoCRM,
      'acs_id': acsId,
      'medicamentos': medicamentos.map((m) => m.toMap()).toList(),
      'status': status.value,
      'data_receita': Timestamp.fromDate(dataReceita),
      'validade_dias': validadeDias,
      'data_assinatura': dataAssinatura != null ? Timestamp.fromDate(dataAssinatura!) : null,
      'data_impressao': dataImpressao != null ? Timestamp.fromDate(dataImpressao!) : null,
      'foto_receita_url': fotoReceitaUrl,
      'observacoes': observacoes,
      'criado_em': Timestamp.fromDate(criadoEm),
      'atualizado_em': atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
    };
  }

  DateTime get dataValidade => dataReceita.add(Duration(days: validadeDias));

  bool get estaVencida => DateTime.now().isAfter(dataValidade);

  int get diasParaVencer => dataValidade.difference(DateTime.now()).inDays;

  bool get estaVencendo => diasParaVencer <= 7 && diasParaVencer > 0;

  bool get temMedicamentoControlado =>
      medicamentos.any((m) => m.isControlado);
}

/// Agrupamento de receitas para impressão
class GrupoReceita {
  final TipoReceita tipoReceita;
  final List<Medicamento> medicamentos;
  final int validadeDias;

  GrupoReceita({
    required this.tipoReceita,
    required this.medicamentos,
    required this.validadeDias,
  });

  String get descricao => '${tipoReceita.displayName} (${medicamentos.length} medicamentos)';
}
