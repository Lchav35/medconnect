import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class Usuario {
  final String id;
  final String nome;
  final String email;
  final UserRole role;
  final String status; // 🔐 Campo de aprovação
  final String? municipioId;
  final String? unidadeId;
  final String? cpf;
  final String? crm;
  final bool ativo;
  final DateTime criadoEm;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
    this.status = 'pendente', // ✅ DEFAULT SEGURO
    this.municipioId,
    this.unidadeId,
    this.cpf,
    this.crm,
    this.ativo = true,
    required this.criadoEm,
  });

  /// ================================
  /// TO FIRESTORE
  /// ================================

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'email': email,
      'role': role.value,
      'status': status,
      'municipio_id': municipioId,
      'unidade_id': unidadeId,
      'cpf': cpf,
      'crm': crm,
      'ativo': ativo,
      'criado_em': Timestamp.fromDate(criadoEm),
    };
  }

  /// ================================
  /// FROM FIRESTORE
  /// ================================

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Usuario(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'acs'),
      status: data['status'] ?? 'pendente',
      municipioId: data['municipio_id'],
      unidadeId: data['unidade_id'],
      cpf: data['cpf'],
      crm: data['crm'],
      ativo: data['ativo'] ?? true,
      criadoEm:
          (data['created_at'] as Timestamp?)?.toDate() ??
              (data['criado_em'] as Timestamp?)?.toDate() ??
              DateTime.now(),
    );
  }

  /// ================================
  /// PERMISSÕES
  /// ================================

  bool get canViewPacientes =>
      role == UserRole.superAdmin ||
      role == UserRole.gestorMunicipal ||
      role == UserRole.gestorUnidade ||
      role == UserRole.acs ||
      role == UserRole.medico;
}