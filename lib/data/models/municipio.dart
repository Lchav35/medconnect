import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Município - Entidade raiz para isolamento multilocatário
class Municipio {
  final String id;
  final String nome;
  final String estado;
  final String codigoIBGE;
  final PlanoMunicipio plano;
  final ConfiguracaoVisual? configuracaoVisual;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;

  Municipio({
    required this.id,
    required this.nome,
    required this.estado,
    required this.codigoIBGE,
    required this.plano,
    this.configuracaoVisual,
    this.ativo = true,
    required this.criadoEm,
    this.atualizadoEm,
  });

  factory Municipio.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Municipio(
      id: doc.id,
      nome: data['nome'] as String? ?? '',
      estado: data['estado'] as String? ?? '',
      codigoIBGE: data['codigo_ibge'] as String? ?? '',
      plano: PlanoMunicipio.fromMap(data['plano'] as Map<String, dynamic>? ?? {}),
      configuracaoVisual: data['configuracao_visual'] != null
          ? ConfiguracaoVisual.fromMap(data['configuracao_visual'] as Map<String, dynamic>)
          : null,
      ativo: data['ativo'] as bool? ?? true,
      criadoEm: (data['criado_em'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm: (data['atualizado_em'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'estado': estado,
      'codigo_ibge': codigoIBGE,
      'plano': plano.toMap(),
      'configuracao_visual': configuracaoVisual?.toMap(),
      'ativo': ativo,
      'criado_em': Timestamp.fromDate(criadoEm),
      'atualizado_em': atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
    };
  }

  Municipio copyWith({
    String? nome,
    String? estado,
    String? codigoIBGE,
    PlanoMunicipio? plano,
    ConfiguracaoVisual? configuracaoVisual,
    bool? ativo,
    DateTime? atualizadoEm,
  }) {
    return Municipio(
      id: id,
      nome: nome ?? this.nome,
      estado: estado ?? this.estado,
      codigoIBGE: codigoIBGE ?? this.codigoIBGE,
      plano: plano ?? this.plano,
      configuracaoVisual: configuracaoVisual ?? this.configuracaoVisual,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }
}

/// Plano de limites e configurações do município
class PlanoMunicipio {
  final int limiteVidas;
  final int limiteUsuarios;
  final int limiteUnidades;
  final int vidasAtivas;
  final int usuariosAtivos;
  final int unidadesAtivas;

  PlanoMunicipio({
    required this.limiteVidas,
    required this.limiteUsuarios,
    required this.limiteUnidades,
    this.vidasAtivas = 0,
    this.usuariosAtivos = 0,
    this.unidadesAtivas = 0,
  });

  factory PlanoMunicipio.fromMap(Map<String, dynamic> map) {
    return PlanoMunicipio(
      limiteVidas: map['limite_vidas'] as int? ?? 1000,
      limiteUsuarios: map['limite_usuarios'] as int? ?? 50,
      limiteUnidades: map['limite_unidades'] as int? ?? 10,
      vidasAtivas: map['vidas_ativas'] as int? ?? 0,
      usuariosAtivos: map['usuarios_ativos'] as int? ?? 0,
      unidadesAtivas: map['unidades_ativas'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'limite_vidas': limiteVidas,
      'limite_usuarios': limiteUsuarios,
      'limite_unidades': limiteUnidades,
      'vidas_ativas': vidasAtivas,
      'usuarios_ativos': usuariosAtivos,
      'unidades_ativas': unidadesAtivas,
    };
  }

  bool podeAdicionarVida() => vidasAtivas < limiteVidas;
  bool podeAdicionarUsuario() => usuariosAtivos < limiteUsuarios;
  bool podeAdicionarUnidade() => unidadesAtivas < limiteUnidades;
}

/// Configuração visual white-label para PDFs e interface
class ConfiguracaoVisual {
  final String? logoUrl;
  final String? cabecalho;
  final String? rodape;
  final String? corPrimaria;
  final String? corSecundaria;

  ConfiguracaoVisual({
    this.logoUrl,
    this.cabecalho,
    this.rodape,
    this.corPrimaria,
    this.corSecundaria,
  });

  factory ConfiguracaoVisual.fromMap(Map<String, dynamic> map) {
    return ConfiguracaoVisual(
      logoUrl: map['logo_url'] as String?,
      cabecalho: map['cabecalho'] as String?,
      rodape: map['rodape'] as String?,
      corPrimaria: map['cor_primaria'] as String?,
      corSecundaria: map['cor_secundaria'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logo_url': logoUrl,
      'cabecalho': cabecalho,
      'rodape': rodape,
      'cor_primaria': corPrimaria,
      'cor_secundaria': corSecundaria,
    };
  }
}
