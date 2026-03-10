import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Serviço de gerenciamento de receitas com motor de agrupamento inteligente
class ReceitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria nova receita
  Future<Receita> criarReceita(Receita receita) async {
    try {
      final docRef = _firestore
          .collection('municipios')
          .doc(receita.municipioId)
          .collection('receitas')
          .doc();

      final novaReceita = Receita(
        id: docRef.id,
        municipioId: receita.municipioId,
        unidadeId: receita.unidadeId,
        pacienteId: receita.pacienteId,
        pacienteNome: receita.pacienteNome,
        medicoId: receita.medicoId,
        medicoNome: receita.medicoNome,
        medicoCRM: receita.medicoCRM,
        acsId: receita.acsId,
        medicamentos: receita.medicamentos,
        status: StatusReceita.pendente,
        dataReceita: DateTime.now(),
        validadeDias: receita.validadeDias,
        fotoReceitaUrl: receita.fotoReceitaUrl,
        observacoes: receita.observacoes,
        criadoEm: DateTime.now(),
      );

      await docRef.set(novaReceita.toFirestore());
      return novaReceita;
    } catch (e) {
      throw Exception('Erro ao criar receita: $e');
    }
  }

  /// Motor de agrupamento inteligente de receitas
  List<GrupoReceita> agruparMedicamentos(List<Medicamento> medicamentos) {
    final Map<TipoReceita, List<Medicamento>> grupos = {};

    for (final medicamento in medicamentos) {
      if (!grupos.containsKey(medicamento.tipoReceita)) {
        grupos[medicamento.tipoReceita] = [];
      }
      grupos[medicamento.tipoReceita]!.add(medicamento);
    }

    return grupos.entries.map((entry) {
      return GrupoReceita(
        tipoReceita: entry.key,
        medicamentos: entry.value,
        validadeDias: entry.key.validadeDias,
      );
    }).toList();
  }

  /// Verifica se há medicamentos controlados
  Map<String, dynamic> verificarMedicamentosControlados(
      List<Medicamento> medicamentos) {
    final controlados = medicamentos.where((m) => m.isControlado).toList();

    return {
      'tem_controlados': controlados.isNotEmpty,
      'medicamentos_controlados': controlados,
      'mensagem': controlados.isNotEmpty
          ? 'ALERTA: Esta prescrição contém medicamentos controlados que devem ser prescritos em receituário específico (azul ou amarelo)'
          : null,
    };
  }

  /// Lista receitas pendentes da unidade
  Future<List<Receita>> listarReceitasPendentes(
    String unidadeId,
    String municipioId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('municipios')
          .doc(municipioId)
          .collection('receitas')
          .where('unidade_id', isEqualTo: unidadeId)
          .where('status', isEqualTo: StatusReceita.pendente.value)
          .get();

      final receitas =
          querySnapshot.docs.map((doc) => Receita.fromFirestore(doc)).toList();

      // Ordenar em memória (evitar index composto)
      receitas.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
      return receitas;
    } catch (e) {
      throw Exception('Erro ao listar receitas pendentes: $e');
    }
  }

  /// Lista receitas vencendo (próximos 7 dias)
  Future<List<Receita>> listarReceitasVencendo(
    String municipioId, {
    String? unidadeId,
  }) async {
    try {
      Query query = _firestore
          .collection('municipios')
          .doc(municipioId)
          .collection('receitas')
          .where('status', isEqualTo: StatusReceita.assinada.value);

      if (unidadeId != null) {
        query = query.where('unidade_id', isEqualTo: unidadeId);
      }

      final querySnapshot = await query.get();

      final receitas =
          querySnapshot.docs.map((doc) => Receita.fromFirestore(doc)).toList();

      // Filtrar em memória receitas que vencem nos próximos 7 dias
      final receitasVencendo = receitas.where((receita) {
        return !receita.estaVencida && receita.estaVencendo;
      }).toList();

      // Ordenar por dias para vencer
      receitasVencendo.sort((a, b) => a.diasParaVencer.compareTo(b.diasParaVencer));

      return receitasVencendo;
    } catch (e) {
      throw Exception('Erro ao listar receitas vencendo: $e');
    }
  }

  /// Assina receita
  Future<void> assinarReceita(String receitaId, String municipioId) async {
    try {
      await _firestore
          .collection('municipios')
          .doc(municipioId)
          .collection('receitas')
          .doc(receitaId)
          .update({
        'status': StatusReceita.assinada.value,
        'data_assinatura': FieldValue.serverTimestamp(),
        'atualizado_em': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao assinar receita: $e');
    }
  }

  /// Marca receita como impressa
  Future<void> marcarComoImpressa(String receitaId, String municipioId) async {
    try {
      await _firestore
          .collection('municipios')
          .doc(municipioId)
          .collection('receitas')
          .doc(receitaId)
          .update({
        'status': StatusReceita.impressa.value,
        'data_impressao': FieldValue.serverTimestamp(),
        'atualizado_em': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao marcar como impressa: $e');
    }
  }
}
