import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paciente.dart';

class PacienteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pacientes';

  // ========================
  // CADASTRAR (CREATE)
  // ========================
  Future<void> cadastrarPaciente(Paciente paciente) async {
    await _firestore
        .collection(_collection)
        .doc(paciente.id)
        .set(paciente.toFirestore());
  }

  // ========================
  // LISTAR POR UNIDADE (READ)
  // ========================
  Stream<List<Paciente>> getPacientesPorUnidade(String unidadeId) {
    return _firestore
        .collection(_collection)
        .where('unidade_id', isEqualTo: unidadeId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Paciente.fromFirestore(doc))
              .toList(),
        );
  }

  // ========================
  // LISTAR POR MUNICIPIO
  // ========================
  Stream<List<Paciente>> getPacientesPorMunicipio(String municipioId) {
    return _firestore
        .collection(_collection)
        .where('municipio_id', isEqualTo: municipioId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Paciente.fromFirestore(doc))
              .toList(),
        );
  }

  // ========================
  // TRANSFERIR (UPDATE)
  // ========================
  Future<void> transferirPaciente({
    required Paciente paciente,
    required String novaUnidadeId,
    required String novoAcsId,
  }) async {
    final pacienteRef =
        _firestore.collection(_collection).doc(paciente.id);

    await pacienteRef.update({
      'unidade_id': novaUnidadeId,
      'acs_id': novoAcsId,
      'atualizado_em': Timestamp.now(),
    });
  }

  // ========================
  // ATUALIZAR COMPLETO
  // ========================
  Future<void> atualizarPaciente(Paciente paciente) async {
    await _firestore
        .collection(_collection)
        .doc(paciente.id)
        .update(paciente.toFirestore());
  }

  // ========================
  // EXCLUIR
  // ========================
  Future<void> excluirPaciente(String pacienteId) async {
    await _firestore
        .collection(_collection)
        .doc(pacienteId)
        .delete();
  }
}