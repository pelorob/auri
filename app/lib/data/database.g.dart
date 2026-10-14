// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CorsiTable extends Corsi with TableInfo<$CorsiTable, Corso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CorsiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cfuMeta = const VerificationMeta('cfu');
  @override
  late final GeneratedColumn<int> cfu = GeneratedColumn<int>(
    'cfu',
    aliasedName,
    false,
    check: () => ComparableExpr(cfu).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annoMeta = const VerificationMeta('anno');
  @override
  late final GeneratedColumn<int> anno = GeneratedColumn<int>(
    'anno',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _semestreMeta = const VerificationMeta(
    'semestre',
  );
  @override
  late final GeneratedColumn<int> semestre = GeneratedColumn<int>(
    'semestre',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _docenteMeta = const VerificationMeta(
    'docente',
  );
  @override
  late final GeneratedColumn<String> docente = GeneratedColumn<String>(
    'docente',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coloreMeta = const VerificationMeta('colore');
  @override
  late final GeneratedColumn<String> colore = GeneratedColumn<String>(
    'colore',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#5B3DE6'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Valutazione, int> valutazione =
      GeneratedColumn<int>(
        'valutazione',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Valutazione>($CorsiTable.$convertervalutazione);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    cfu,
    anno,
    semestre,
    docente,
    colore,
    valutazione,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'corsi';
  @override
  VerificationContext validateIntegrity(
    Insertable<Corso> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('cfu')) {
      context.handle(
        _cfuMeta,
        cfu.isAcceptableOrUnknown(data['cfu']!, _cfuMeta),
      );
    } else if (isInserting) {
      context.missing(_cfuMeta);
    }
    if (data.containsKey('anno')) {
      context.handle(
        _annoMeta,
        anno.isAcceptableOrUnknown(data['anno']!, _annoMeta),
      );
    }
    if (data.containsKey('semestre')) {
      context.handle(
        _semestreMeta,
        semestre.isAcceptableOrUnknown(data['semestre']!, _semestreMeta),
      );
    }
    if (data.containsKey('docente')) {
      context.handle(
        _docenteMeta,
        docente.isAcceptableOrUnknown(data['docente']!, _docenteMeta),
      );
    }
    if (data.containsKey('colore')) {
      context.handle(
        _coloreMeta,
        colore.isAcceptableOrUnknown(data['colore']!, _coloreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Corso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Corso(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      cfu: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cfu'],
      )!,
      anno: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anno'],
      )!,
      semestre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}semestre'],
      ),
      docente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}docente'],
      ),
      colore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colore'],
      )!,
      valutazione: $CorsiTable.$convertervalutazione.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}valutazione'],
        )!,
      ),
    );
  }

  @override
  $CorsiTable createAlias(String alias) {
    return $CorsiTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Valutazione, int, int> $convertervalutazione =
      const EnumIndexConverter<Valutazione>(Valutazione.values);
}

class Corso extends DataClass implements Insertable<Corso> {
  final int id;
  final String nome;
  final int cfu;
  final int anno;
  final int? semestre;
  final String? docente;
  final String colore;
  final Valutazione valutazione;
  const Corso({
    required this.id,
    required this.nome,
    required this.cfu,
    required this.anno,
    this.semestre,
    this.docente,
    required this.colore,
    required this.valutazione,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['cfu'] = Variable<int>(cfu);
    map['anno'] = Variable<int>(anno);
    if (!nullToAbsent || semestre != null) {
      map['semestre'] = Variable<int>(semestre);
    }
    if (!nullToAbsent || docente != null) {
      map['docente'] = Variable<String>(docente);
    }
    map['colore'] = Variable<String>(colore);
    {
      map['valutazione'] = Variable<int>(
        $CorsiTable.$convertervalutazione.toSql(valutazione),
      );
    }
    return map;
  }

  CorsiCompanion toCompanion(bool nullToAbsent) {
    return CorsiCompanion(
      id: Value(id),
      nome: Value(nome),
      cfu: Value(cfu),
      anno: Value(anno),
      semestre: semestre == null && nullToAbsent
          ? const Value.absent()
          : Value(semestre),
      docente: docente == null && nullToAbsent
          ? const Value.absent()
          : Value(docente),
      colore: Value(colore),
      valutazione: Value(valutazione),
    );
  }

  factory Corso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Corso(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      cfu: serializer.fromJson<int>(json['cfu']),
      anno: serializer.fromJson<int>(json['anno']),
      semestre: serializer.fromJson<int?>(json['semestre']),
      docente: serializer.fromJson<String?>(json['docente']),
      colore: serializer.fromJson<String>(json['colore']),
      valutazione: $CorsiTable.$convertervalutazione.fromJson(
        serializer.fromJson<int>(json['valutazione']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'cfu': serializer.toJson<int>(cfu),
      'anno': serializer.toJson<int>(anno),
      'semestre': serializer.toJson<int?>(semestre),
      'docente': serializer.toJson<String?>(docente),
      'colore': serializer.toJson<String>(colore),
      'valutazione': serializer.toJson<int>(
        $CorsiTable.$convertervalutazione.toJson(valutazione),
      ),
    };
  }

  Corso copyWith({
    int? id,
    String? nome,
    int? cfu,
    int? anno,
    Value<int?> semestre = const Value.absent(),
    Value<String?> docente = const Value.absent(),
    String? colore,
    Valutazione? valutazione,
  }) => Corso(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    cfu: cfu ?? this.cfu,
    anno: anno ?? this.anno,
    semestre: semestre.present ? semestre.value : this.semestre,
    docente: docente.present ? docente.value : this.docente,
    colore: colore ?? this.colore,
    valutazione: valutazione ?? this.valutazione,
  );
  Corso copyWithCompanion(CorsiCompanion data) {
    return Corso(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      cfu: data.cfu.present ? data.cfu.value : this.cfu,
      anno: data.anno.present ? data.anno.value : this.anno,
      semestre: data.semestre.present ? data.semestre.value : this.semestre,
      docente: data.docente.present ? data.docente.value : this.docente,
      colore: data.colore.present ? data.colore.value : this.colore,
      valutazione: data.valutazione.present
          ? data.valutazione.value
          : this.valutazione,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Corso(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('cfu: $cfu, ')
          ..write('anno: $anno, ')
          ..write('semestre: $semestre, ')
          ..write('docente: $docente, ')
          ..write('colore: $colore, ')
          ..write('valutazione: $valutazione')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, cfu, anno, semestre, docente, colore, valutazione);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Corso &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.cfu == this.cfu &&
          other.anno == this.anno &&
          other.semestre == this.semestre &&
          other.docente == this.docente &&
          other.colore == this.colore &&
          other.valutazione == this.valutazione);
}

class CorsiCompanion extends UpdateCompanion<Corso> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> cfu;
  final Value<int> anno;
  final Value<int?> semestre;
  final Value<String?> docente;
  final Value<String> colore;
  final Value<Valutazione> valutazione;
  const CorsiCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.cfu = const Value.absent(),
    this.anno = const Value.absent(),
    this.semestre = const Value.absent(),
    this.docente = const Value.absent(),
    this.colore = const Value.absent(),
    this.valutazione = const Value.absent(),
  });
  CorsiCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int cfu,
    this.anno = const Value.absent(),
    this.semestre = const Value.absent(),
    this.docente = const Value.absent(),
    this.colore = const Value.absent(),
    required Valutazione valutazione,
  }) : nome = Value(nome),
       cfu = Value(cfu),
       valutazione = Value(valutazione);
  static Insertable<Corso> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? cfu,
    Expression<int>? anno,
    Expression<int>? semestre,
    Expression<String>? docente,
    Expression<String>? colore,
    Expression<int>? valutazione,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (cfu != null) 'cfu': cfu,
      if (anno != null) 'anno': anno,
      if (semestre != null) 'semestre': semestre,
      if (docente != null) 'docente': docente,
      if (colore != null) 'colore': colore,
      if (valutazione != null) 'valutazione': valutazione,
    });
  }

  CorsiCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int>? cfu,
    Value<int>? anno,
    Value<int?>? semestre,
    Value<String?>? docente,
    Value<String>? colore,
    Value<Valutazione>? valutazione,
  }) {
    return CorsiCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cfu: cfu ?? this.cfu,
      anno: anno ?? this.anno,
      semestre: semestre ?? this.semestre,
      docente: docente ?? this.docente,
      colore: colore ?? this.colore,
      valutazione: valutazione ?? this.valutazione,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (cfu.present) {
      map['cfu'] = Variable<int>(cfu.value);
    }
    if (anno.present) {
      map['anno'] = Variable<int>(anno.value);
    }
    if (semestre.present) {
      map['semestre'] = Variable<int>(semestre.value);
    }
    if (docente.present) {
      map['docente'] = Variable<String>(docente.value);
    }
    if (colore.present) {
      map['colore'] = Variable<String>(colore.value);
    }
    if (valutazione.present) {
      map['valutazione'] = Variable<int>(
        $CorsiTable.$convertervalutazione.toSql(valutazione.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CorsiCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('cfu: $cfu, ')
          ..write('anno: $anno, ')
          ..write('semestre: $semestre, ')
          ..write('docente: $docente, ')
          ..write('colore: $colore, ')
          ..write('valutazione: $valutazione')
          ..write(')'))
        .toString();
  }
}

class $EsitiTable extends Esiti with TableInfo<$EsitiTable, Esito> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EsitiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _corsoIdMeta = const VerificationMeta(
    'corsoId',
  );
  @override
  late final GeneratedColumn<int> corsoId = GeneratedColumn<int>(
    'corso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES corsi (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _votoMeta = const VerificationMeta('voto');
  @override
  late final GeneratedColumn<int> voto = GeneratedColumn<int>(
    'voto',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lodeMeta = const VerificationMeta('lode');
  @override
  late final GeneratedColumn<bool> lode = GeneratedColumn<bool>(
    'lode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [corsoId, voto, lode, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'esiti';
  @override
  VerificationContext validateIntegrity(
    Insertable<Esito> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('corso_id')) {
      context.handle(
        _corsoIdMeta,
        corsoId.isAcceptableOrUnknown(data['corso_id']!, _corsoIdMeta),
      );
    }
    if (data.containsKey('voto')) {
      context.handle(
        _votoMeta,
        voto.isAcceptableOrUnknown(data['voto']!, _votoMeta),
      );
    }
    if (data.containsKey('lode')) {
      context.handle(
        _lodeMeta,
        lode.isAcceptableOrUnknown(data['lode']!, _lodeMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {corsoId};
  @override
  Esito map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Esito(
      corsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corso_id'],
      )!,
      voto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voto'],
      ),
      lode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lode'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $EsitiTable createAlias(String alias) {
    return $EsitiTable(attachedDatabase, alias);
  }
}

class Esito extends DataClass implements Insertable<Esito> {
  final int corsoId;
  final int? voto;
  final bool lode;
  final DateTime data;
  const Esito({
    required this.corsoId,
    this.voto,
    required this.lode,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['corso_id'] = Variable<int>(corsoId);
    if (!nullToAbsent || voto != null) {
      map['voto'] = Variable<int>(voto);
    }
    map['lode'] = Variable<bool>(lode);
    map['data'] = Variable<DateTime>(data);
    return map;
  }

  EsitiCompanion toCompanion(bool nullToAbsent) {
    return EsitiCompanion(
      corsoId: Value(corsoId),
      voto: voto == null && nullToAbsent ? const Value.absent() : Value(voto),
      lode: Value(lode),
      data: Value(data),
    );
  }

  factory Esito.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Esito(
      corsoId: serializer.fromJson<int>(json['corsoId']),
      voto: serializer.fromJson<int?>(json['voto']),
      lode: serializer.fromJson<bool>(json['lode']),
      data: serializer.fromJson<DateTime>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'corsoId': serializer.toJson<int>(corsoId),
      'voto': serializer.toJson<int?>(voto),
      'lode': serializer.toJson<bool>(lode),
      'data': serializer.toJson<DateTime>(data),
    };
  }

  Esito copyWith({
    int? corsoId,
    Value<int?> voto = const Value.absent(),
    bool? lode,
    DateTime? data,
  }) => Esito(
    corsoId: corsoId ?? this.corsoId,
    voto: voto.present ? voto.value : this.voto,
    lode: lode ?? this.lode,
    data: data ?? this.data,
  );
  Esito copyWithCompanion(EsitiCompanion data) {
    return Esito(
      corsoId: data.corsoId.present ? data.corsoId.value : this.corsoId,
      voto: data.voto.present ? data.voto.value : this.voto,
      lode: data.lode.present ? data.lode.value : this.lode,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Esito(')
          ..write('corsoId: $corsoId, ')
          ..write('voto: $voto, ')
          ..write('lode: $lode, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(corsoId, voto, lode, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Esito &&
          other.corsoId == this.corsoId &&
          other.voto == this.voto &&
          other.lode == this.lode &&
          other.data == this.data);
}

class EsitiCompanion extends UpdateCompanion<Esito> {
  final Value<int> corsoId;
  final Value<int?> voto;
  final Value<bool> lode;
  final Value<DateTime> data;
  const EsitiCompanion({
    this.corsoId = const Value.absent(),
    this.voto = const Value.absent(),
    this.lode = const Value.absent(),
    this.data = const Value.absent(),
  });
  EsitiCompanion.insert({
    this.corsoId = const Value.absent(),
    this.voto = const Value.absent(),
    this.lode = const Value.absent(),
    required DateTime data,
  }) : data = Value(data);
  static Insertable<Esito> custom({
    Expression<int>? corsoId,
    Expression<int>? voto,
    Expression<bool>? lode,
    Expression<DateTime>? data,
  }) {
    return RawValuesInsertable({
      if (corsoId != null) 'corso_id': corsoId,
      if (voto != null) 'voto': voto,
      if (lode != null) 'lode': lode,
      if (data != null) 'data': data,
    });
  }

  EsitiCompanion copyWith({
    Value<int>? corsoId,
    Value<int?>? voto,
    Value<bool>? lode,
    Value<DateTime>? data,
  }) {
    return EsitiCompanion(
      corsoId: corsoId ?? this.corsoId,
      voto: voto ?? this.voto,
      lode: lode ?? this.lode,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (corsoId.present) {
      map['corso_id'] = Variable<int>(corsoId.value);
    }
    if (voto.present) {
      map['voto'] = Variable<int>(voto.value);
    }
    if (lode.present) {
      map['lode'] = Variable<bool>(lode.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EsitiCompanion(')
          ..write('corsoId: $corsoId, ')
          ..write('voto: $voto, ')
          ..write('lode: $lode, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $AppelliTable extends Appelli with TableInfo<$AppelliTable, Appello> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppelliTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _corsoIdMeta = const VerificationMeta(
    'corsoId',
  );
  @override
  late final GeneratedColumn<int> corsoId = GeneratedColumn<int>(
    'corso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES corsi (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dataOraMeta = const VerificationMeta(
    'dataOra',
  );
  @override
  late final GeneratedColumn<DateTime> dataOra = GeneratedColumn<DateTime>(
    'data_ora',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoAppello, int> tipo =
      GeneratedColumn<int>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoAppello>($AppelliTable.$convertertipo);
  static const VerificationMeta _aulaMeta = const VerificationMeta('aula');
  @override
  late final GeneratedColumn<String> aula = GeneratedColumn<String>(
    'aula',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iscrittaMeta = const VerificationMeta(
    'iscritta',
  );
  @override
  late final GeneratedColumn<bool> iscritta = GeneratedColumn<bool>(
    'iscritta',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("iscritta" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _preavvisiMeta = const VerificationMeta(
    'preavvisi',
  );
  @override
  late final GeneratedColumn<String> preavvisi = GeneratedColumn<String>(
    'preavvisi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(preavvisiPredefiniti),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    corsoId,
    dataOra,
    tipo,
    aula,
    iscritta,
    preavvisi,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appelli';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appello> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('corso_id')) {
      context.handle(
        _corsoIdMeta,
        corsoId.isAcceptableOrUnknown(data['corso_id']!, _corsoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_corsoIdMeta);
    }
    if (data.containsKey('data_ora')) {
      context.handle(
        _dataOraMeta,
        dataOra.isAcceptableOrUnknown(data['data_ora']!, _dataOraMeta),
      );
    } else if (isInserting) {
      context.missing(_dataOraMeta);
    }
    if (data.containsKey('aula')) {
      context.handle(
        _aulaMeta,
        aula.isAcceptableOrUnknown(data['aula']!, _aulaMeta),
      );
    }
    if (data.containsKey('iscritta')) {
      context.handle(
        _iscrittaMeta,
        iscritta.isAcceptableOrUnknown(data['iscritta']!, _iscrittaMeta),
      );
    }
    if (data.containsKey('preavvisi')) {
      context.handle(
        _preavvisiMeta,
        preavvisi.isAcceptableOrUnknown(data['preavvisi']!, _preavvisiMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appello map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appello(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      corsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corso_id'],
      )!,
      dataOra: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_ora'],
      )!,
      tipo: $AppelliTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      aula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aula'],
      ),
      iscritta: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}iscritta'],
      )!,
      preavvisi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preavvisi'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $AppelliTable createAlias(String alias) {
    return $AppelliTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoAppello, int, int> $convertertipo =
      const EnumIndexConverter<TipoAppello>(TipoAppello.values);
}

class Appello extends DataClass implements Insertable<Appello> {
  final int id;
  final int corsoId;
  final DateTime dataOra;
  final TipoAppello tipo;
  final String? aula;
  final bool iscritta;
  final String preavvisi;
  final String? note;
  const Appello({
    required this.id,
    required this.corsoId,
    required this.dataOra,
    required this.tipo,
    this.aula,
    required this.iscritta,
    required this.preavvisi,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['corso_id'] = Variable<int>(corsoId);
    map['data_ora'] = Variable<DateTime>(dataOra);
    {
      map['tipo'] = Variable<int>($AppelliTable.$convertertipo.toSql(tipo));
    }
    if (!nullToAbsent || aula != null) {
      map['aula'] = Variable<String>(aula);
    }
    map['iscritta'] = Variable<bool>(iscritta);
    map['preavvisi'] = Variable<String>(preavvisi);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AppelliCompanion toCompanion(bool nullToAbsent) {
    return AppelliCompanion(
      id: Value(id),
      corsoId: Value(corsoId),
      dataOra: Value(dataOra),
      tipo: Value(tipo),
      aula: aula == null && nullToAbsent ? const Value.absent() : Value(aula),
      iscritta: Value(iscritta),
      preavvisi: Value(preavvisi),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Appello.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appello(
      id: serializer.fromJson<int>(json['id']),
      corsoId: serializer.fromJson<int>(json['corsoId']),
      dataOra: serializer.fromJson<DateTime>(json['dataOra']),
      tipo: $AppelliTable.$convertertipo.fromJson(
        serializer.fromJson<int>(json['tipo']),
      ),
      aula: serializer.fromJson<String?>(json['aula']),
      iscritta: serializer.fromJson<bool>(json['iscritta']),
      preavvisi: serializer.fromJson<String>(json['preavvisi']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'corsoId': serializer.toJson<int>(corsoId),
      'dataOra': serializer.toJson<DateTime>(dataOra),
      'tipo': serializer.toJson<int>($AppelliTable.$convertertipo.toJson(tipo)),
      'aula': serializer.toJson<String?>(aula),
      'iscritta': serializer.toJson<bool>(iscritta),
      'preavvisi': serializer.toJson<String>(preavvisi),
      'note': serializer.toJson<String?>(note),
    };
  }

  Appello copyWith({
    int? id,
    int? corsoId,
    DateTime? dataOra,
    TipoAppello? tipo,
    Value<String?> aula = const Value.absent(),
    bool? iscritta,
    String? preavvisi,
    Value<String?> note = const Value.absent(),
  }) => Appello(
    id: id ?? this.id,
    corsoId: corsoId ?? this.corsoId,
    dataOra: dataOra ?? this.dataOra,
    tipo: tipo ?? this.tipo,
    aula: aula.present ? aula.value : this.aula,
    iscritta: iscritta ?? this.iscritta,
    preavvisi: preavvisi ?? this.preavvisi,
    note: note.present ? note.value : this.note,
  );
  Appello copyWithCompanion(AppelliCompanion data) {
    return Appello(
      id: data.id.present ? data.id.value : this.id,
      corsoId: data.corsoId.present ? data.corsoId.value : this.corsoId,
      dataOra: data.dataOra.present ? data.dataOra.value : this.dataOra,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      aula: data.aula.present ? data.aula.value : this.aula,
      iscritta: data.iscritta.present ? data.iscritta.value : this.iscritta,
      preavvisi: data.preavvisi.present ? data.preavvisi.value : this.preavvisi,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appello(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('dataOra: $dataOra, ')
          ..write('tipo: $tipo, ')
          ..write('aula: $aula, ')
          ..write('iscritta: $iscritta, ')
          ..write('preavvisi: $preavvisi, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, corsoId, dataOra, tipo, aula, iscritta, preavvisi, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appello &&
          other.id == this.id &&
          other.corsoId == this.corsoId &&
          other.dataOra == this.dataOra &&
          other.tipo == this.tipo &&
          other.aula == this.aula &&
          other.iscritta == this.iscritta &&
          other.preavvisi == this.preavvisi &&
          other.note == this.note);
}

class AppelliCompanion extends UpdateCompanion<Appello> {
  final Value<int> id;
  final Value<int> corsoId;
  final Value<DateTime> dataOra;
  final Value<TipoAppello> tipo;
  final Value<String?> aula;
  final Value<bool> iscritta;
  final Value<String> preavvisi;
  final Value<String?> note;
  const AppelliCompanion({
    this.id = const Value.absent(),
    this.corsoId = const Value.absent(),
    this.dataOra = const Value.absent(),
    this.tipo = const Value.absent(),
    this.aula = const Value.absent(),
    this.iscritta = const Value.absent(),
    this.preavvisi = const Value.absent(),
    this.note = const Value.absent(),
  });
  AppelliCompanion.insert({
    this.id = const Value.absent(),
    required int corsoId,
    required DateTime dataOra,
    required TipoAppello tipo,
    this.aula = const Value.absent(),
    this.iscritta = const Value.absent(),
    this.preavvisi = const Value.absent(),
    this.note = const Value.absent(),
  }) : corsoId = Value(corsoId),
       dataOra = Value(dataOra),
       tipo = Value(tipo);
  static Insertable<Appello> custom({
    Expression<int>? id,
    Expression<int>? corsoId,
    Expression<DateTime>? dataOra,
    Expression<int>? tipo,
    Expression<String>? aula,
    Expression<bool>? iscritta,
    Expression<String>? preavvisi,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (corsoId != null) 'corso_id': corsoId,
      if (dataOra != null) 'data_ora': dataOra,
      if (tipo != null) 'tipo': tipo,
      if (aula != null) 'aula': aula,
      if (iscritta != null) 'iscritta': iscritta,
      if (preavvisi != null) 'preavvisi': preavvisi,
      if (note != null) 'note': note,
    });
  }

  AppelliCompanion copyWith({
    Value<int>? id,
    Value<int>? corsoId,
    Value<DateTime>? dataOra,
    Value<TipoAppello>? tipo,
    Value<String?>? aula,
    Value<bool>? iscritta,
    Value<String>? preavvisi,
    Value<String?>? note,
  }) {
    return AppelliCompanion(
      id: id ?? this.id,
      corsoId: corsoId ?? this.corsoId,
      dataOra: dataOra ?? this.dataOra,
      tipo: tipo ?? this.tipo,
      aula: aula ?? this.aula,
      iscritta: iscritta ?? this.iscritta,
      preavvisi: preavvisi ?? this.preavvisi,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (corsoId.present) {
      map['corso_id'] = Variable<int>(corsoId.value);
    }
    if (dataOra.present) {
      map['data_ora'] = Variable<DateTime>(dataOra.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<int>(
        $AppelliTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (aula.present) {
      map['aula'] = Variable<String>(aula.value);
    }
    if (iscritta.present) {
      map['iscritta'] = Variable<bool>(iscritta.value);
    }
    if (preavvisi.present) {
      map['preavvisi'] = Variable<String>(preavvisi.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppelliCompanion(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('dataOra: $dataOra, ')
          ..write('tipo: $tipo, ')
          ..write('aula: $aula, ')
          ..write('iscritta: $iscritta, ')
          ..write('preavvisi: $preavvisi, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ImpostazioniTable extends Impostazioni
    with TableInfo<$ImpostazioniTable, Impostazione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImpostazioniTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chiaveMeta = const VerificationMeta('chiave');
  @override
  late final GeneratedColumn<String> chiave = GeneratedColumn<String>(
    'chiave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valoreMeta = const VerificationMeta('valore');
  @override
  late final GeneratedColumn<String> valore = GeneratedColumn<String>(
    'valore',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chiave, valore];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'impostazioni';
  @override
  VerificationContext validateIntegrity(
    Insertable<Impostazione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chiave')) {
      context.handle(
        _chiaveMeta,
        chiave.isAcceptableOrUnknown(data['chiave']!, _chiaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chiaveMeta);
    }
    if (data.containsKey('valore')) {
      context.handle(
        _valoreMeta,
        valore.isAcceptableOrUnknown(data['valore']!, _valoreMeta),
      );
    } else if (isInserting) {
      context.missing(_valoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chiave};
  @override
  Impostazione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Impostazione(
      chiave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chiave'],
      )!,
      valore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valore'],
      )!,
    );
  }

  @override
  $ImpostazioniTable createAlias(String alias) {
    return $ImpostazioniTable(attachedDatabase, alias);
  }
}

class Impostazione extends DataClass implements Insertable<Impostazione> {
  final String chiave;
  final String valore;
  const Impostazione({required this.chiave, required this.valore});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chiave'] = Variable<String>(chiave);
    map['valore'] = Variable<String>(valore);
    return map;
  }

  ImpostazioniCompanion toCompanion(bool nullToAbsent) {
    return ImpostazioniCompanion(chiave: Value(chiave), valore: Value(valore));
  }

  factory Impostazione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Impostazione(
      chiave: serializer.fromJson<String>(json['chiave']),
      valore: serializer.fromJson<String>(json['valore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chiave': serializer.toJson<String>(chiave),
      'valore': serializer.toJson<String>(valore),
    };
  }

  Impostazione copyWith({String? chiave, String? valore}) => Impostazione(
    chiave: chiave ?? this.chiave,
    valore: valore ?? this.valore,
  );
  Impostazione copyWithCompanion(ImpostazioniCompanion data) {
    return Impostazione(
      chiave: data.chiave.present ? data.chiave.value : this.chiave,
      valore: data.valore.present ? data.valore.value : this.valore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Impostazione(')
          ..write('chiave: $chiave, ')
          ..write('valore: $valore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chiave, valore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Impostazione &&
          other.chiave == this.chiave &&
          other.valore == this.valore);
}

class ImpostazioniCompanion extends UpdateCompanion<Impostazione> {
  final Value<String> chiave;
  final Value<String> valore;
  final Value<int> rowid;
  const ImpostazioniCompanion({
    this.chiave = const Value.absent(),
    this.valore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImpostazioniCompanion.insert({
    required String chiave,
    required String valore,
    this.rowid = const Value.absent(),
  }) : chiave = Value(chiave),
       valore = Value(valore);
  static Insertable<Impostazione> custom({
    Expression<String>? chiave,
    Expression<String>? valore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chiave != null) 'chiave': chiave,
      if (valore != null) 'valore': valore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImpostazioniCompanion copyWith({
    Value<String>? chiave,
    Value<String>? valore,
    Value<int>? rowid,
  }) {
    return ImpostazioniCompanion(
      chiave: chiave ?? this.chiave,
      valore: valore ?? this.valore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chiave.present) {
      map['chiave'] = Variable<String>(chiave.value);
    }
    if (valore.present) {
      map['valore'] = Variable<String>(valore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImpostazioniCompanion(')
          ..write('chiave: $chiave, ')
          ..write('valore: $valore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentiTable extends Documenti
    with TableInfo<$DocumentiTable, Documento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _corsoIdMeta = const VerificationMeta(
    'corsoId',
  );
  @override
  late final GeneratedColumn<int> corsoId = GeneratedColumn<int>(
    'corso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES corsi (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titoloMeta = const VerificationMeta('titolo');
  @override
  late final GeneratedColumn<String> titolo = GeneratedColumn<String>(
    'titolo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeFileMeta = const VerificationMeta(
    'nomeFile',
  );
  @override
  late final GeneratedColumn<String> nomeFile = GeneratedColumn<String>(
    'nome_file',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroPagineMeta = const VerificationMeta(
    'numeroPagine',
  );
  @override
  late final GeneratedColumn<int> numeroPagine = GeneratedColumn<int>(
    'numero_pagine',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importatoIlMeta = const VerificationMeta(
    'importatoIl',
  );
  @override
  late final GeneratedColumn<DateTime> importatoIl = GeneratedColumn<DateTime>(
    'importato_il',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    corsoId,
    titolo,
    nomeFile,
    numeroPagine,
    importatoIl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documenti';
  @override
  VerificationContext validateIntegrity(
    Insertable<Documento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('corso_id')) {
      context.handle(
        _corsoIdMeta,
        corsoId.isAcceptableOrUnknown(data['corso_id']!, _corsoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_corsoIdMeta);
    }
    if (data.containsKey('titolo')) {
      context.handle(
        _titoloMeta,
        titolo.isAcceptableOrUnknown(data['titolo']!, _titoloMeta),
      );
    } else if (isInserting) {
      context.missing(_titoloMeta);
    }
    if (data.containsKey('nome_file')) {
      context.handle(
        _nomeFileMeta,
        nomeFile.isAcceptableOrUnknown(data['nome_file']!, _nomeFileMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeFileMeta);
    }
    if (data.containsKey('numero_pagine')) {
      context.handle(
        _numeroPagineMeta,
        numeroPagine.isAcceptableOrUnknown(
          data['numero_pagine']!,
          _numeroPagineMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numeroPagineMeta);
    }
    if (data.containsKey('importato_il')) {
      context.handle(
        _importatoIlMeta,
        importatoIl.isAcceptableOrUnknown(
          data['importato_il']!,
          _importatoIlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_importatoIlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Documento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Documento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      corsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corso_id'],
      )!,
      titolo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titolo'],
      )!,
      nomeFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_file'],
      )!,
      numeroPagine: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero_pagine'],
      )!,
      importatoIl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}importato_il'],
      )!,
    );
  }

  @override
  $DocumentiTable createAlias(String alias) {
    return $DocumentiTable(attachedDatabase, alias);
  }
}

class Documento extends DataClass implements Insertable<Documento> {
  final int id;
  final int corsoId;
  final String titolo;
  final String nomeFile;
  final int numeroPagine;
  final DateTime importatoIl;
  const Documento({
    required this.id,
    required this.corsoId,
    required this.titolo,
    required this.nomeFile,
    required this.numeroPagine,
    required this.importatoIl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['corso_id'] = Variable<int>(corsoId);
    map['titolo'] = Variable<String>(titolo);
    map['nome_file'] = Variable<String>(nomeFile);
    map['numero_pagine'] = Variable<int>(numeroPagine);
    map['importato_il'] = Variable<DateTime>(importatoIl);
    return map;
  }

  DocumentiCompanion toCompanion(bool nullToAbsent) {
    return DocumentiCompanion(
      id: Value(id),
      corsoId: Value(corsoId),
      titolo: Value(titolo),
      nomeFile: Value(nomeFile),
      numeroPagine: Value(numeroPagine),
      importatoIl: Value(importatoIl),
    );
  }

  factory Documento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Documento(
      id: serializer.fromJson<int>(json['id']),
      corsoId: serializer.fromJson<int>(json['corsoId']),
      titolo: serializer.fromJson<String>(json['titolo']),
      nomeFile: serializer.fromJson<String>(json['nomeFile']),
      numeroPagine: serializer.fromJson<int>(json['numeroPagine']),
      importatoIl: serializer.fromJson<DateTime>(json['importatoIl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'corsoId': serializer.toJson<int>(corsoId),
      'titolo': serializer.toJson<String>(titolo),
      'nomeFile': serializer.toJson<String>(nomeFile),
      'numeroPagine': serializer.toJson<int>(numeroPagine),
      'importatoIl': serializer.toJson<DateTime>(importatoIl),
    };
  }

  Documento copyWith({
    int? id,
    int? corsoId,
    String? titolo,
    String? nomeFile,
    int? numeroPagine,
    DateTime? importatoIl,
  }) => Documento(
    id: id ?? this.id,
    corsoId: corsoId ?? this.corsoId,
    titolo: titolo ?? this.titolo,
    nomeFile: nomeFile ?? this.nomeFile,
    numeroPagine: numeroPagine ?? this.numeroPagine,
    importatoIl: importatoIl ?? this.importatoIl,
  );
  Documento copyWithCompanion(DocumentiCompanion data) {
    return Documento(
      id: data.id.present ? data.id.value : this.id,
      corsoId: data.corsoId.present ? data.corsoId.value : this.corsoId,
      titolo: data.titolo.present ? data.titolo.value : this.titolo,
      nomeFile: data.nomeFile.present ? data.nomeFile.value : this.nomeFile,
      numeroPagine: data.numeroPagine.present
          ? data.numeroPagine.value
          : this.numeroPagine,
      importatoIl: data.importatoIl.present
          ? data.importatoIl.value
          : this.importatoIl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Documento(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('titolo: $titolo, ')
          ..write('nomeFile: $nomeFile, ')
          ..write('numeroPagine: $numeroPagine, ')
          ..write('importatoIl: $importatoIl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, corsoId, titolo, nomeFile, numeroPagine, importatoIl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Documento &&
          other.id == this.id &&
          other.corsoId == this.corsoId &&
          other.titolo == this.titolo &&
          other.nomeFile == this.nomeFile &&
          other.numeroPagine == this.numeroPagine &&
          other.importatoIl == this.importatoIl);
}

class DocumentiCompanion extends UpdateCompanion<Documento> {
  final Value<int> id;
  final Value<int> corsoId;
  final Value<String> titolo;
  final Value<String> nomeFile;
  final Value<int> numeroPagine;
  final Value<DateTime> importatoIl;
  const DocumentiCompanion({
    this.id = const Value.absent(),
    this.corsoId = const Value.absent(),
    this.titolo = const Value.absent(),
    this.nomeFile = const Value.absent(),
    this.numeroPagine = const Value.absent(),
    this.importatoIl = const Value.absent(),
  });
  DocumentiCompanion.insert({
    this.id = const Value.absent(),
    required int corsoId,
    required String titolo,
    required String nomeFile,
    required int numeroPagine,
    required DateTime importatoIl,
  }) : corsoId = Value(corsoId),
       titolo = Value(titolo),
       nomeFile = Value(nomeFile),
       numeroPagine = Value(numeroPagine),
       importatoIl = Value(importatoIl);
  static Insertable<Documento> custom({
    Expression<int>? id,
    Expression<int>? corsoId,
    Expression<String>? titolo,
    Expression<String>? nomeFile,
    Expression<int>? numeroPagine,
    Expression<DateTime>? importatoIl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (corsoId != null) 'corso_id': corsoId,
      if (titolo != null) 'titolo': titolo,
      if (nomeFile != null) 'nome_file': nomeFile,
      if (numeroPagine != null) 'numero_pagine': numeroPagine,
      if (importatoIl != null) 'importato_il': importatoIl,
    });
  }

  DocumentiCompanion copyWith({
    Value<int>? id,
    Value<int>? corsoId,
    Value<String>? titolo,
    Value<String>? nomeFile,
    Value<int>? numeroPagine,
    Value<DateTime>? importatoIl,
  }) {
    return DocumentiCompanion(
      id: id ?? this.id,
      corsoId: corsoId ?? this.corsoId,
      titolo: titolo ?? this.titolo,
      nomeFile: nomeFile ?? this.nomeFile,
      numeroPagine: numeroPagine ?? this.numeroPagine,
      importatoIl: importatoIl ?? this.importatoIl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (corsoId.present) {
      map['corso_id'] = Variable<int>(corsoId.value);
    }
    if (titolo.present) {
      map['titolo'] = Variable<String>(titolo.value);
    }
    if (nomeFile.present) {
      map['nome_file'] = Variable<String>(nomeFile.value);
    }
    if (numeroPagine.present) {
      map['numero_pagine'] = Variable<int>(numeroPagine.value);
    }
    if (importatoIl.present) {
      map['importato_il'] = Variable<DateTime>(importatoIl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentiCompanion(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('titolo: $titolo, ')
          ..write('nomeFile: $nomeFile, ')
          ..write('numeroPagine: $numeroPagine, ')
          ..write('importatoIl: $importatoIl')
          ..write(')'))
        .toString();
  }
}

class $PagineTable extends Pagine with TableInfo<$PagineTable, Pagina> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentoIdMeta = const VerificationMeta(
    'documentoId',
  );
  @override
  late final GeneratedColumn<int> documentoId = GeneratedColumn<int>(
    'documento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documenti (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titoloMeta = const VerificationMeta('titolo');
  @override
  late final GeneratedColumn<String> titolo = GeneratedColumn<String>(
    'titolo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _testoMeta = const VerificationMeta('testo');
  @override
  late final GeneratedColumn<String> testo = GeneratedColumn<String>(
    'testo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentoId,
    numero,
    titolo,
    testo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagine';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pagina> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('documento_id')) {
      context.handle(
        _documentoIdMeta,
        documentoId.isAcceptableOrUnknown(
          data['documento_id']!,
          _documentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentoIdMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('titolo')) {
      context.handle(
        _titoloMeta,
        titolo.isAcceptableOrUnknown(data['titolo']!, _titoloMeta),
      );
    } else if (isInserting) {
      context.missing(_titoloMeta);
    }
    if (data.containsKey('testo')) {
      context.handle(
        _testoMeta,
        testo.isAcceptableOrUnknown(data['testo']!, _testoMeta),
      );
    } else if (isInserting) {
      context.missing(_testoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pagina map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pagina(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}documento_id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      )!,
      titolo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titolo'],
      )!,
      testo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}testo'],
      )!,
    );
  }

  @override
  $PagineTable createAlias(String alias) {
    return $PagineTable(attachedDatabase, alias);
  }
}

class Pagina extends DataClass implements Insertable<Pagina> {
  final int id;
  final int documentoId;
  final int numero;
  final String titolo;
  final String testo;
  const Pagina({
    required this.id,
    required this.documentoId,
    required this.numero,
    required this.titolo,
    required this.testo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['documento_id'] = Variable<int>(documentoId);
    map['numero'] = Variable<int>(numero);
    map['titolo'] = Variable<String>(titolo);
    map['testo'] = Variable<String>(testo);
    return map;
  }

  PagineCompanion toCompanion(bool nullToAbsent) {
    return PagineCompanion(
      id: Value(id),
      documentoId: Value(documentoId),
      numero: Value(numero),
      titolo: Value(titolo),
      testo: Value(testo),
    );
  }

  factory Pagina.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pagina(
      id: serializer.fromJson<int>(json['id']),
      documentoId: serializer.fromJson<int>(json['documentoId']),
      numero: serializer.fromJson<int>(json['numero']),
      titolo: serializer.fromJson<String>(json['titolo']),
      testo: serializer.fromJson<String>(json['testo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentoId': serializer.toJson<int>(documentoId),
      'numero': serializer.toJson<int>(numero),
      'titolo': serializer.toJson<String>(titolo),
      'testo': serializer.toJson<String>(testo),
    };
  }

  Pagina copyWith({
    int? id,
    int? documentoId,
    int? numero,
    String? titolo,
    String? testo,
  }) => Pagina(
    id: id ?? this.id,
    documentoId: documentoId ?? this.documentoId,
    numero: numero ?? this.numero,
    titolo: titolo ?? this.titolo,
    testo: testo ?? this.testo,
  );
  Pagina copyWithCompanion(PagineCompanion data) {
    return Pagina(
      id: data.id.present ? data.id.value : this.id,
      documentoId: data.documentoId.present
          ? data.documentoId.value
          : this.documentoId,
      numero: data.numero.present ? data.numero.value : this.numero,
      titolo: data.titolo.present ? data.titolo.value : this.titolo,
      testo: data.testo.present ? data.testo.value : this.testo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pagina(')
          ..write('id: $id, ')
          ..write('documentoId: $documentoId, ')
          ..write('numero: $numero, ')
          ..write('titolo: $titolo, ')
          ..write('testo: $testo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, documentoId, numero, titolo, testo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pagina &&
          other.id == this.id &&
          other.documentoId == this.documentoId &&
          other.numero == this.numero &&
          other.titolo == this.titolo &&
          other.testo == this.testo);
}

class PagineCompanion extends UpdateCompanion<Pagina> {
  final Value<int> id;
  final Value<int> documentoId;
  final Value<int> numero;
  final Value<String> titolo;
  final Value<String> testo;
  const PagineCompanion({
    this.id = const Value.absent(),
    this.documentoId = const Value.absent(),
    this.numero = const Value.absent(),
    this.titolo = const Value.absent(),
    this.testo = const Value.absent(),
  });
  PagineCompanion.insert({
    this.id = const Value.absent(),
    required int documentoId,
    required int numero,
    required String titolo,
    required String testo,
  }) : documentoId = Value(documentoId),
       numero = Value(numero),
       titolo = Value(titolo),
       testo = Value(testo);
  static Insertable<Pagina> custom({
    Expression<int>? id,
    Expression<int>? documentoId,
    Expression<int>? numero,
    Expression<String>? titolo,
    Expression<String>? testo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentoId != null) 'documento_id': documentoId,
      if (numero != null) 'numero': numero,
      if (titolo != null) 'titolo': titolo,
      if (testo != null) 'testo': testo,
    });
  }

  PagineCompanion copyWith({
    Value<int>? id,
    Value<int>? documentoId,
    Value<int>? numero,
    Value<String>? titolo,
    Value<String>? testo,
  }) {
    return PagineCompanion(
      id: id ?? this.id,
      documentoId: documentoId ?? this.documentoId,
      numero: numero ?? this.numero,
      titolo: titolo ?? this.titolo,
      testo: testo ?? this.testo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentoId.present) {
      map['documento_id'] = Variable<int>(documentoId.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (titolo.present) {
      map['titolo'] = Variable<String>(titolo.value);
    }
    if (testo.present) {
      map['testo'] = Variable<String>(testo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagineCompanion(')
          ..write('id: $id, ')
          ..write('documentoId: $documentoId, ')
          ..write('numero: $numero, ')
          ..write('titolo: $titolo, ')
          ..write('testo: $testo')
          ..write(')'))
        .toString();
  }
}

class $CarteTable extends Carte with TableInfo<$CarteTable, Carta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _corsoIdMeta = const VerificationMeta(
    'corsoId',
  );
  @override
  late final GeneratedColumn<int> corsoId = GeneratedColumn<int>(
    'corso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES corsi (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _documentoIdMeta = const VerificationMeta(
    'documentoId',
  );
  @override
  late final GeneratedColumn<int> documentoId = GeneratedColumn<int>(
    'documento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documenti (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _paginaMeta = const VerificationMeta('pagina');
  @override
  late final GeneratedColumn<int> pagina = GeneratedColumn<int>(
    'pagina',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fronteMeta = const VerificationMeta('fronte');
  @override
  late final GeneratedColumn<String> fronte = GeneratedColumn<String>(
    'fronte',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retroMeta = const VerificationMeta('retro');
  @override
  late final GeneratedColumn<String> retro = GeneratedColumn<String>(
    'retro',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OrigineCarta, int> origine =
      GeneratedColumn<int>(
        'origine',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<OrigineCarta>($CarteTable.$converterorigine);
  static const VerificationMeta _ripetizioniMeta = const VerificationMeta(
    'ripetizioni',
  );
  @override
  late final GeneratedColumn<int> ripetizioni = GeneratedColumn<int>(
    'ripetizioni',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intervalloMeta = const VerificationMeta(
    'intervallo',
  );
  @override
  late final GeneratedColumn<int> intervallo = GeneratedColumn<int>(
    'intervallo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _facilitaMeta = const VerificationMeta(
    'facilita',
  );
  @override
  late final GeneratedColumn<double> facilita = GeneratedColumn<double>(
    'facilita',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _prossimaMeta = const VerificationMeta(
    'prossima',
  );
  @override
  late final GeneratedColumn<DateTime> prossima = GeneratedColumn<DateTime>(
    'prossima',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _esclusaMeta = const VerificationMeta(
    'esclusa',
  );
  @override
  late final GeneratedColumn<bool> esclusa = GeneratedColumn<bool>(
    'esclusa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("esclusa" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    corsoId,
    documentoId,
    pagina,
    fronte,
    retro,
    origine,
    ripetizioni,
    intervallo,
    facilita,
    prossima,
    esclusa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'carte';
  @override
  VerificationContext validateIntegrity(
    Insertable<Carta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('corso_id')) {
      context.handle(
        _corsoIdMeta,
        corsoId.isAcceptableOrUnknown(data['corso_id']!, _corsoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_corsoIdMeta);
    }
    if (data.containsKey('documento_id')) {
      context.handle(
        _documentoIdMeta,
        documentoId.isAcceptableOrUnknown(
          data['documento_id']!,
          _documentoIdMeta,
        ),
      );
    }
    if (data.containsKey('pagina')) {
      context.handle(
        _paginaMeta,
        pagina.isAcceptableOrUnknown(data['pagina']!, _paginaMeta),
      );
    }
    if (data.containsKey('fronte')) {
      context.handle(
        _fronteMeta,
        fronte.isAcceptableOrUnknown(data['fronte']!, _fronteMeta),
      );
    } else if (isInserting) {
      context.missing(_fronteMeta);
    }
    if (data.containsKey('retro')) {
      context.handle(
        _retroMeta,
        retro.isAcceptableOrUnknown(data['retro']!, _retroMeta),
      );
    } else if (isInserting) {
      context.missing(_retroMeta);
    }
    if (data.containsKey('ripetizioni')) {
      context.handle(
        _ripetizioniMeta,
        ripetizioni.isAcceptableOrUnknown(
          data['ripetizioni']!,
          _ripetizioniMeta,
        ),
      );
    }
    if (data.containsKey('intervallo')) {
      context.handle(
        _intervalloMeta,
        intervallo.isAcceptableOrUnknown(data['intervallo']!, _intervalloMeta),
      );
    }
    if (data.containsKey('facilita')) {
      context.handle(
        _facilitaMeta,
        facilita.isAcceptableOrUnknown(data['facilita']!, _facilitaMeta),
      );
    }
    if (data.containsKey('prossima')) {
      context.handle(
        _prossimaMeta,
        prossima.isAcceptableOrUnknown(data['prossima']!, _prossimaMeta),
      );
    }
    if (data.containsKey('esclusa')) {
      context.handle(
        _esclusaMeta,
        esclusa.isAcceptableOrUnknown(data['esclusa']!, _esclusaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Carta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Carta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      corsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corso_id'],
      )!,
      documentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}documento_id'],
      ),
      pagina: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pagina'],
      ),
      fronte: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fronte'],
      )!,
      retro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retro'],
      )!,
      origine: $CarteTable.$converterorigine.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}origine'],
        )!,
      ),
      ripetizioni: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ripetizioni'],
      )!,
      intervallo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intervallo'],
      )!,
      facilita: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}facilita'],
      )!,
      prossima: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}prossima'],
      ),
      esclusa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}esclusa'],
      )!,
    );
  }

  @override
  $CarteTable createAlias(String alias) {
    return $CarteTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OrigineCarta, int, int> $converterorigine =
      const EnumIndexConverter<OrigineCarta>(OrigineCarta.values);
}

class Carta extends DataClass implements Insertable<Carta> {
  final int id;
  final int corsoId;
  final int? documentoId;
  final int? pagina;
  final String fronte;
  final String retro;
  final OrigineCarta origine;
  final int ripetizioni;
  final int intervallo;
  final double facilita;
  final DateTime? prossima;
  final bool esclusa;
  const Carta({
    required this.id,
    required this.corsoId,
    this.documentoId,
    this.pagina,
    required this.fronte,
    required this.retro,
    required this.origine,
    required this.ripetizioni,
    required this.intervallo,
    required this.facilita,
    this.prossima,
    required this.esclusa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['corso_id'] = Variable<int>(corsoId);
    if (!nullToAbsent || documentoId != null) {
      map['documento_id'] = Variable<int>(documentoId);
    }
    if (!nullToAbsent || pagina != null) {
      map['pagina'] = Variable<int>(pagina);
    }
    map['fronte'] = Variable<String>(fronte);
    map['retro'] = Variable<String>(retro);
    {
      map['origine'] = Variable<int>(
        $CarteTable.$converterorigine.toSql(origine),
      );
    }
    map['ripetizioni'] = Variable<int>(ripetizioni);
    map['intervallo'] = Variable<int>(intervallo);
    map['facilita'] = Variable<double>(facilita);
    if (!nullToAbsent || prossima != null) {
      map['prossima'] = Variable<DateTime>(prossima);
    }
    map['esclusa'] = Variable<bool>(esclusa);
    return map;
  }

  CarteCompanion toCompanion(bool nullToAbsent) {
    return CarteCompanion(
      id: Value(id),
      corsoId: Value(corsoId),
      documentoId: documentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentoId),
      pagina: pagina == null && nullToAbsent
          ? const Value.absent()
          : Value(pagina),
      fronte: Value(fronte),
      retro: Value(retro),
      origine: Value(origine),
      ripetizioni: Value(ripetizioni),
      intervallo: Value(intervallo),
      facilita: Value(facilita),
      prossima: prossima == null && nullToAbsent
          ? const Value.absent()
          : Value(prossima),
      esclusa: Value(esclusa),
    );
  }

  factory Carta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Carta(
      id: serializer.fromJson<int>(json['id']),
      corsoId: serializer.fromJson<int>(json['corsoId']),
      documentoId: serializer.fromJson<int?>(json['documentoId']),
      pagina: serializer.fromJson<int?>(json['pagina']),
      fronte: serializer.fromJson<String>(json['fronte']),
      retro: serializer.fromJson<String>(json['retro']),
      origine: $CarteTable.$converterorigine.fromJson(
        serializer.fromJson<int>(json['origine']),
      ),
      ripetizioni: serializer.fromJson<int>(json['ripetizioni']),
      intervallo: serializer.fromJson<int>(json['intervallo']),
      facilita: serializer.fromJson<double>(json['facilita']),
      prossima: serializer.fromJson<DateTime?>(json['prossima']),
      esclusa: serializer.fromJson<bool>(json['esclusa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'corsoId': serializer.toJson<int>(corsoId),
      'documentoId': serializer.toJson<int?>(documentoId),
      'pagina': serializer.toJson<int?>(pagina),
      'fronte': serializer.toJson<String>(fronte),
      'retro': serializer.toJson<String>(retro),
      'origine': serializer.toJson<int>(
        $CarteTable.$converterorigine.toJson(origine),
      ),
      'ripetizioni': serializer.toJson<int>(ripetizioni),
      'intervallo': serializer.toJson<int>(intervallo),
      'facilita': serializer.toJson<double>(facilita),
      'prossima': serializer.toJson<DateTime?>(prossima),
      'esclusa': serializer.toJson<bool>(esclusa),
    };
  }

  Carta copyWith({
    int? id,
    int? corsoId,
    Value<int?> documentoId = const Value.absent(),
    Value<int?> pagina = const Value.absent(),
    String? fronte,
    String? retro,
    OrigineCarta? origine,
    int? ripetizioni,
    int? intervallo,
    double? facilita,
    Value<DateTime?> prossima = const Value.absent(),
    bool? esclusa,
  }) => Carta(
    id: id ?? this.id,
    corsoId: corsoId ?? this.corsoId,
    documentoId: documentoId.present ? documentoId.value : this.documentoId,
    pagina: pagina.present ? pagina.value : this.pagina,
    fronte: fronte ?? this.fronte,
    retro: retro ?? this.retro,
    origine: origine ?? this.origine,
    ripetizioni: ripetizioni ?? this.ripetizioni,
    intervallo: intervallo ?? this.intervallo,
    facilita: facilita ?? this.facilita,
    prossima: prossima.present ? prossima.value : this.prossima,
    esclusa: esclusa ?? this.esclusa,
  );
  Carta copyWithCompanion(CarteCompanion data) {
    return Carta(
      id: data.id.present ? data.id.value : this.id,
      corsoId: data.corsoId.present ? data.corsoId.value : this.corsoId,
      documentoId: data.documentoId.present
          ? data.documentoId.value
          : this.documentoId,
      pagina: data.pagina.present ? data.pagina.value : this.pagina,
      fronte: data.fronte.present ? data.fronte.value : this.fronte,
      retro: data.retro.present ? data.retro.value : this.retro,
      origine: data.origine.present ? data.origine.value : this.origine,
      ripetizioni: data.ripetizioni.present
          ? data.ripetizioni.value
          : this.ripetizioni,
      intervallo: data.intervallo.present
          ? data.intervallo.value
          : this.intervallo,
      facilita: data.facilita.present ? data.facilita.value : this.facilita,
      prossima: data.prossima.present ? data.prossima.value : this.prossima,
      esclusa: data.esclusa.present ? data.esclusa.value : this.esclusa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Carta(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('documentoId: $documentoId, ')
          ..write('pagina: $pagina, ')
          ..write('fronte: $fronte, ')
          ..write('retro: $retro, ')
          ..write('origine: $origine, ')
          ..write('ripetizioni: $ripetizioni, ')
          ..write('intervallo: $intervallo, ')
          ..write('facilita: $facilita, ')
          ..write('prossima: $prossima, ')
          ..write('esclusa: $esclusa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    corsoId,
    documentoId,
    pagina,
    fronte,
    retro,
    origine,
    ripetizioni,
    intervallo,
    facilita,
    prossima,
    esclusa,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Carta &&
          other.id == this.id &&
          other.corsoId == this.corsoId &&
          other.documentoId == this.documentoId &&
          other.pagina == this.pagina &&
          other.fronte == this.fronte &&
          other.retro == this.retro &&
          other.origine == this.origine &&
          other.ripetizioni == this.ripetizioni &&
          other.intervallo == this.intervallo &&
          other.facilita == this.facilita &&
          other.prossima == this.prossima &&
          other.esclusa == this.esclusa);
}

class CarteCompanion extends UpdateCompanion<Carta> {
  final Value<int> id;
  final Value<int> corsoId;
  final Value<int?> documentoId;
  final Value<int?> pagina;
  final Value<String> fronte;
  final Value<String> retro;
  final Value<OrigineCarta> origine;
  final Value<int> ripetizioni;
  final Value<int> intervallo;
  final Value<double> facilita;
  final Value<DateTime?> prossima;
  final Value<bool> esclusa;
  const CarteCompanion({
    this.id = const Value.absent(),
    this.corsoId = const Value.absent(),
    this.documentoId = const Value.absent(),
    this.pagina = const Value.absent(),
    this.fronte = const Value.absent(),
    this.retro = const Value.absent(),
    this.origine = const Value.absent(),
    this.ripetizioni = const Value.absent(),
    this.intervallo = const Value.absent(),
    this.facilita = const Value.absent(),
    this.prossima = const Value.absent(),
    this.esclusa = const Value.absent(),
  });
  CarteCompanion.insert({
    this.id = const Value.absent(),
    required int corsoId,
    this.documentoId = const Value.absent(),
    this.pagina = const Value.absent(),
    required String fronte,
    required String retro,
    required OrigineCarta origine,
    this.ripetizioni = const Value.absent(),
    this.intervallo = const Value.absent(),
    this.facilita = const Value.absent(),
    this.prossima = const Value.absent(),
    this.esclusa = const Value.absent(),
  }) : corsoId = Value(corsoId),
       fronte = Value(fronte),
       retro = Value(retro),
       origine = Value(origine);
  static Insertable<Carta> custom({
    Expression<int>? id,
    Expression<int>? corsoId,
    Expression<int>? documentoId,
    Expression<int>? pagina,
    Expression<String>? fronte,
    Expression<String>? retro,
    Expression<int>? origine,
    Expression<int>? ripetizioni,
    Expression<int>? intervallo,
    Expression<double>? facilita,
    Expression<DateTime>? prossima,
    Expression<bool>? esclusa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (corsoId != null) 'corso_id': corsoId,
      if (documentoId != null) 'documento_id': documentoId,
      if (pagina != null) 'pagina': pagina,
      if (fronte != null) 'fronte': fronte,
      if (retro != null) 'retro': retro,
      if (origine != null) 'origine': origine,
      if (ripetizioni != null) 'ripetizioni': ripetizioni,
      if (intervallo != null) 'intervallo': intervallo,
      if (facilita != null) 'facilita': facilita,
      if (prossima != null) 'prossima': prossima,
      if (esclusa != null) 'esclusa': esclusa,
    });
  }

  CarteCompanion copyWith({
    Value<int>? id,
    Value<int>? corsoId,
    Value<int?>? documentoId,
    Value<int?>? pagina,
    Value<String>? fronte,
    Value<String>? retro,
    Value<OrigineCarta>? origine,
    Value<int>? ripetizioni,
    Value<int>? intervallo,
    Value<double>? facilita,
    Value<DateTime?>? prossima,
    Value<bool>? esclusa,
  }) {
    return CarteCompanion(
      id: id ?? this.id,
      corsoId: corsoId ?? this.corsoId,
      documentoId: documentoId ?? this.documentoId,
      pagina: pagina ?? this.pagina,
      fronte: fronte ?? this.fronte,
      retro: retro ?? this.retro,
      origine: origine ?? this.origine,
      ripetizioni: ripetizioni ?? this.ripetizioni,
      intervallo: intervallo ?? this.intervallo,
      facilita: facilita ?? this.facilita,
      prossima: prossima ?? this.prossima,
      esclusa: esclusa ?? this.esclusa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (corsoId.present) {
      map['corso_id'] = Variable<int>(corsoId.value);
    }
    if (documentoId.present) {
      map['documento_id'] = Variable<int>(documentoId.value);
    }
    if (pagina.present) {
      map['pagina'] = Variable<int>(pagina.value);
    }
    if (fronte.present) {
      map['fronte'] = Variable<String>(fronte.value);
    }
    if (retro.present) {
      map['retro'] = Variable<String>(retro.value);
    }
    if (origine.present) {
      map['origine'] = Variable<int>(
        $CarteTable.$converterorigine.toSql(origine.value),
      );
    }
    if (ripetizioni.present) {
      map['ripetizioni'] = Variable<int>(ripetizioni.value);
    }
    if (intervallo.present) {
      map['intervallo'] = Variable<int>(intervallo.value);
    }
    if (facilita.present) {
      map['facilita'] = Variable<double>(facilita.value);
    }
    if (prossima.present) {
      map['prossima'] = Variable<DateTime>(prossima.value);
    }
    if (esclusa.present) {
      map['esclusa'] = Variable<bool>(esclusa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarteCompanion(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('documentoId: $documentoId, ')
          ..write('pagina: $pagina, ')
          ..write('fronte: $fronte, ')
          ..write('retro: $retro, ')
          ..write('origine: $origine, ')
          ..write('ripetizioni: $ripetizioni, ')
          ..write('intervallo: $intervallo, ')
          ..write('facilita: $facilita, ')
          ..write('prossima: $prossima, ')
          ..write('esclusa: $esclusa')
          ..write(')'))
        .toString();
  }
}

class $RevisioniTable extends Revisioni
    with TableInfo<$RevisioniTable, Revisione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevisioniTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cartaIdMeta = const VerificationMeta(
    'cartaId',
  );
  @override
  late final GeneratedColumn<int> cartaId = GeneratedColumn<int>(
    'carta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES carte (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Risposta, int> risposta =
      GeneratedColumn<int>(
        'risposta',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Risposta>($RevisioniTable.$converterrisposta);
  @override
  List<GeneratedColumn> get $columns => [id, cartaId, data, risposta];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revisioni';
  @override
  VerificationContext validateIntegrity(
    Insertable<Revisione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('carta_id')) {
      context.handle(
        _cartaIdMeta,
        cartaId.isAcceptableOrUnknown(data['carta_id']!, _cartaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cartaIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Revisione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Revisione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cartaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carta_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      risposta: $RevisioniTable.$converterrisposta.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}risposta'],
        )!,
      ),
    );
  }

  @override
  $RevisioniTable createAlias(String alias) {
    return $RevisioniTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Risposta, int, int> $converterrisposta =
      const EnumIndexConverter<Risposta>(Risposta.values);
}

class Revisione extends DataClass implements Insertable<Revisione> {
  final int id;
  final int cartaId;
  final DateTime data;
  final Risposta risposta;
  const Revisione({
    required this.id,
    required this.cartaId,
    required this.data,
    required this.risposta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['carta_id'] = Variable<int>(cartaId);
    map['data'] = Variable<DateTime>(data);
    {
      map['risposta'] = Variable<int>(
        $RevisioniTable.$converterrisposta.toSql(risposta),
      );
    }
    return map;
  }

  RevisioniCompanion toCompanion(bool nullToAbsent) {
    return RevisioniCompanion(
      id: Value(id),
      cartaId: Value(cartaId),
      data: Value(data),
      risposta: Value(risposta),
    );
  }

  factory Revisione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Revisione(
      id: serializer.fromJson<int>(json['id']),
      cartaId: serializer.fromJson<int>(json['cartaId']),
      data: serializer.fromJson<DateTime>(json['data']),
      risposta: $RevisioniTable.$converterrisposta.fromJson(
        serializer.fromJson<int>(json['risposta']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cartaId': serializer.toJson<int>(cartaId),
      'data': serializer.toJson<DateTime>(data),
      'risposta': serializer.toJson<int>(
        $RevisioniTable.$converterrisposta.toJson(risposta),
      ),
    };
  }

  Revisione copyWith({
    int? id,
    int? cartaId,
    DateTime? data,
    Risposta? risposta,
  }) => Revisione(
    id: id ?? this.id,
    cartaId: cartaId ?? this.cartaId,
    data: data ?? this.data,
    risposta: risposta ?? this.risposta,
  );
  Revisione copyWithCompanion(RevisioniCompanion data) {
    return Revisione(
      id: data.id.present ? data.id.value : this.id,
      cartaId: data.cartaId.present ? data.cartaId.value : this.cartaId,
      data: data.data.present ? data.data.value : this.data,
      risposta: data.risposta.present ? data.risposta.value : this.risposta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Revisione(')
          ..write('id: $id, ')
          ..write('cartaId: $cartaId, ')
          ..write('data: $data, ')
          ..write('risposta: $risposta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cartaId, data, risposta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Revisione &&
          other.id == this.id &&
          other.cartaId == this.cartaId &&
          other.data == this.data &&
          other.risposta == this.risposta);
}

class RevisioniCompanion extends UpdateCompanion<Revisione> {
  final Value<int> id;
  final Value<int> cartaId;
  final Value<DateTime> data;
  final Value<Risposta> risposta;
  const RevisioniCompanion({
    this.id = const Value.absent(),
    this.cartaId = const Value.absent(),
    this.data = const Value.absent(),
    this.risposta = const Value.absent(),
  });
  RevisioniCompanion.insert({
    this.id = const Value.absent(),
    required int cartaId,
    required DateTime data,
    required Risposta risposta,
  }) : cartaId = Value(cartaId),
       data = Value(data),
       risposta = Value(risposta);
  static Insertable<Revisione> custom({
    Expression<int>? id,
    Expression<int>? cartaId,
    Expression<DateTime>? data,
    Expression<int>? risposta,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cartaId != null) 'carta_id': cartaId,
      if (data != null) 'data': data,
      if (risposta != null) 'risposta': risposta,
    });
  }

  RevisioniCompanion copyWith({
    Value<int>? id,
    Value<int>? cartaId,
    Value<DateTime>? data,
    Value<Risposta>? risposta,
  }) {
    return RevisioniCompanion(
      id: id ?? this.id,
      cartaId: cartaId ?? this.cartaId,
      data: data ?? this.data,
      risposta: risposta ?? this.risposta,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cartaId.present) {
      map['carta_id'] = Variable<int>(cartaId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (risposta.present) {
      map['risposta'] = Variable<int>(
        $RevisioniTable.$converterrisposta.toSql(risposta.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevisioniCompanion(')
          ..write('id: $id, ')
          ..write('cartaId: $cartaId, ')
          ..write('data: $data, ')
          ..write('risposta: $risposta')
          ..write(')'))
        .toString();
  }
}

class $SimulazioniTable extends Simulazioni
    with TableInfo<$SimulazioniTable, Simulazione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimulazioniTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _corsoIdMeta = const VerificationMeta(
    'corsoId',
  );
  @override
  late final GeneratedColumn<int> corsoId = GeneratedColumn<int>(
    'corso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES corsi (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domandeMeta = const VerificationMeta(
    'domande',
  );
  @override
  late final GeneratedColumn<int> domande = GeneratedColumn<int>(
    'domande',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _giusteMeta = const VerificationMeta('giuste');
  @override
  late final GeneratedColumn<int> giuste = GeneratedColumn<int>(
    'giuste',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _votoMeta = const VerificationMeta('voto');
  @override
  late final GeneratedColumn<int> voto = GeneratedColumn<int>(
    'voto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    corsoId,
    data,
    domande,
    giuste,
    voto,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'simulazioni';
  @override
  VerificationContext validateIntegrity(
    Insertable<Simulazione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('corso_id')) {
      context.handle(
        _corsoIdMeta,
        corsoId.isAcceptableOrUnknown(data['corso_id']!, _corsoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_corsoIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('domande')) {
      context.handle(
        _domandeMeta,
        domande.isAcceptableOrUnknown(data['domande']!, _domandeMeta),
      );
    } else if (isInserting) {
      context.missing(_domandeMeta);
    }
    if (data.containsKey('giuste')) {
      context.handle(
        _giusteMeta,
        giuste.isAcceptableOrUnknown(data['giuste']!, _giusteMeta),
      );
    } else if (isInserting) {
      context.missing(_giusteMeta);
    }
    if (data.containsKey('voto')) {
      context.handle(
        _votoMeta,
        voto.isAcceptableOrUnknown(data['voto']!, _votoMeta),
      );
    } else if (isInserting) {
      context.missing(_votoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Simulazione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Simulazione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      corsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corso_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      domande: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}domande'],
      )!,
      giuste: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}giuste'],
      )!,
      voto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voto'],
      )!,
    );
  }

  @override
  $SimulazioniTable createAlias(String alias) {
    return $SimulazioniTable(attachedDatabase, alias);
  }
}

class Simulazione extends DataClass implements Insertable<Simulazione> {
  final int id;
  final int corsoId;
  final DateTime data;
  final int domande;
  final int giuste;
  final int voto;
  const Simulazione({
    required this.id,
    required this.corsoId,
    required this.data,
    required this.domande,
    required this.giuste,
    required this.voto,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['corso_id'] = Variable<int>(corsoId);
    map['data'] = Variable<DateTime>(data);
    map['domande'] = Variable<int>(domande);
    map['giuste'] = Variable<int>(giuste);
    map['voto'] = Variable<int>(voto);
    return map;
  }

  SimulazioniCompanion toCompanion(bool nullToAbsent) {
    return SimulazioniCompanion(
      id: Value(id),
      corsoId: Value(corsoId),
      data: Value(data),
      domande: Value(domande),
      giuste: Value(giuste),
      voto: Value(voto),
    );
  }

  factory Simulazione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Simulazione(
      id: serializer.fromJson<int>(json['id']),
      corsoId: serializer.fromJson<int>(json['corsoId']),
      data: serializer.fromJson<DateTime>(json['data']),
      domande: serializer.fromJson<int>(json['domande']),
      giuste: serializer.fromJson<int>(json['giuste']),
      voto: serializer.fromJson<int>(json['voto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'corsoId': serializer.toJson<int>(corsoId),
      'data': serializer.toJson<DateTime>(data),
      'domande': serializer.toJson<int>(domande),
      'giuste': serializer.toJson<int>(giuste),
      'voto': serializer.toJson<int>(voto),
    };
  }

  Simulazione copyWith({
    int? id,
    int? corsoId,
    DateTime? data,
    int? domande,
    int? giuste,
    int? voto,
  }) => Simulazione(
    id: id ?? this.id,
    corsoId: corsoId ?? this.corsoId,
    data: data ?? this.data,
    domande: domande ?? this.domande,
    giuste: giuste ?? this.giuste,
    voto: voto ?? this.voto,
  );
  Simulazione copyWithCompanion(SimulazioniCompanion data) {
    return Simulazione(
      id: data.id.present ? data.id.value : this.id,
      corsoId: data.corsoId.present ? data.corsoId.value : this.corsoId,
      data: data.data.present ? data.data.value : this.data,
      domande: data.domande.present ? data.domande.value : this.domande,
      giuste: data.giuste.present ? data.giuste.value : this.giuste,
      voto: data.voto.present ? data.voto.value : this.voto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Simulazione(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('data: $data, ')
          ..write('domande: $domande, ')
          ..write('giuste: $giuste, ')
          ..write('voto: $voto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, corsoId, data, domande, giuste, voto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Simulazione &&
          other.id == this.id &&
          other.corsoId == this.corsoId &&
          other.data == this.data &&
          other.domande == this.domande &&
          other.giuste == this.giuste &&
          other.voto == this.voto);
}

class SimulazioniCompanion extends UpdateCompanion<Simulazione> {
  final Value<int> id;
  final Value<int> corsoId;
  final Value<DateTime> data;
  final Value<int> domande;
  final Value<int> giuste;
  final Value<int> voto;
  const SimulazioniCompanion({
    this.id = const Value.absent(),
    this.corsoId = const Value.absent(),
    this.data = const Value.absent(),
    this.domande = const Value.absent(),
    this.giuste = const Value.absent(),
    this.voto = const Value.absent(),
  });
  SimulazioniCompanion.insert({
    this.id = const Value.absent(),
    required int corsoId,
    required DateTime data,
    required int domande,
    required int giuste,
    required int voto,
  }) : corsoId = Value(corsoId),
       data = Value(data),
       domande = Value(domande),
       giuste = Value(giuste),
       voto = Value(voto);
  static Insertable<Simulazione> custom({
    Expression<int>? id,
    Expression<int>? corsoId,
    Expression<DateTime>? data,
    Expression<int>? domande,
    Expression<int>? giuste,
    Expression<int>? voto,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (corsoId != null) 'corso_id': corsoId,
      if (data != null) 'data': data,
      if (domande != null) 'domande': domande,
      if (giuste != null) 'giuste': giuste,
      if (voto != null) 'voto': voto,
    });
  }

  SimulazioniCompanion copyWith({
    Value<int>? id,
    Value<int>? corsoId,
    Value<DateTime>? data,
    Value<int>? domande,
    Value<int>? giuste,
    Value<int>? voto,
  }) {
    return SimulazioniCompanion(
      id: id ?? this.id,
      corsoId: corsoId ?? this.corsoId,
      data: data ?? this.data,
      domande: domande ?? this.domande,
      giuste: giuste ?? this.giuste,
      voto: voto ?? this.voto,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (corsoId.present) {
      map['corso_id'] = Variable<int>(corsoId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (domande.present) {
      map['domande'] = Variable<int>(domande.value);
    }
    if (giuste.present) {
      map['giuste'] = Variable<int>(giuste.value);
    }
    if (voto.present) {
      map['voto'] = Variable<int>(voto.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimulazioniCompanion(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('data: $data, ')
          ..write('domande: $domande, ')
          ..write('giuste: $giuste, ')
          ..write('voto: $voto')
          ..write(')'))
        .toString();
  }
}

class $SessioniTable extends Sessioni with TableInfo<$SessioniTable, Sessione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessioniTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _corsoIdMeta = const VerificationMeta(
    'corsoId',
  );
  @override
  late final GeneratedColumn<int> corsoId = GeneratedColumn<int>(
    'corso_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES corsi (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _inizioMeta = const VerificationMeta('inizio');
  @override
  late final GeneratedColumn<DateTime> inizio = GeneratedColumn<DateTime>(
    'inizio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutiMeta = const VerificationMeta('minuti');
  @override
  late final GeneratedColumn<int> minuti = GeneratedColumn<int>(
    'minuti',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, corsoId, inizio, minuti];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessioni';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sessione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('corso_id')) {
      context.handle(
        _corsoIdMeta,
        corsoId.isAcceptableOrUnknown(data['corso_id']!, _corsoIdMeta),
      );
    }
    if (data.containsKey('inizio')) {
      context.handle(
        _inizioMeta,
        inizio.isAcceptableOrUnknown(data['inizio']!, _inizioMeta),
      );
    } else if (isInserting) {
      context.missing(_inizioMeta);
    }
    if (data.containsKey('minuti')) {
      context.handle(
        _minutiMeta,
        minuti.isAcceptableOrUnknown(data['minuti']!, _minutiMeta),
      );
    } else if (isInserting) {
      context.missing(_minutiMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sessione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sessione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      corsoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corso_id'],
      ),
      inizio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inizio'],
      )!,
      minuti: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minuti'],
      )!,
    );
  }

  @override
  $SessioniTable createAlias(String alias) {
    return $SessioniTable(attachedDatabase, alias);
  }
}

class Sessione extends DataClass implements Insertable<Sessione> {
  final int id;
  final int? corsoId;
  final DateTime inizio;
  final int minuti;
  const Sessione({
    required this.id,
    this.corsoId,
    required this.inizio,
    required this.minuti,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || corsoId != null) {
      map['corso_id'] = Variable<int>(corsoId);
    }
    map['inizio'] = Variable<DateTime>(inizio);
    map['minuti'] = Variable<int>(minuti);
    return map;
  }

  SessioniCompanion toCompanion(bool nullToAbsent) {
    return SessioniCompanion(
      id: Value(id),
      corsoId: corsoId == null && nullToAbsent
          ? const Value.absent()
          : Value(corsoId),
      inizio: Value(inizio),
      minuti: Value(minuti),
    );
  }

  factory Sessione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sessione(
      id: serializer.fromJson<int>(json['id']),
      corsoId: serializer.fromJson<int?>(json['corsoId']),
      inizio: serializer.fromJson<DateTime>(json['inizio']),
      minuti: serializer.fromJson<int>(json['minuti']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'corsoId': serializer.toJson<int?>(corsoId),
      'inizio': serializer.toJson<DateTime>(inizio),
      'minuti': serializer.toJson<int>(minuti),
    };
  }

  Sessione copyWith({
    int? id,
    Value<int?> corsoId = const Value.absent(),
    DateTime? inizio,
    int? minuti,
  }) => Sessione(
    id: id ?? this.id,
    corsoId: corsoId.present ? corsoId.value : this.corsoId,
    inizio: inizio ?? this.inizio,
    minuti: minuti ?? this.minuti,
  );
  Sessione copyWithCompanion(SessioniCompanion data) {
    return Sessione(
      id: data.id.present ? data.id.value : this.id,
      corsoId: data.corsoId.present ? data.corsoId.value : this.corsoId,
      inizio: data.inizio.present ? data.inizio.value : this.inizio,
      minuti: data.minuti.present ? data.minuti.value : this.minuti,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sessione(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('inizio: $inizio, ')
          ..write('minuti: $minuti')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, corsoId, inizio, minuti);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sessione &&
          other.id == this.id &&
          other.corsoId == this.corsoId &&
          other.inizio == this.inizio &&
          other.minuti == this.minuti);
}

class SessioniCompanion extends UpdateCompanion<Sessione> {
  final Value<int> id;
  final Value<int?> corsoId;
  final Value<DateTime> inizio;
  final Value<int> minuti;
  const SessioniCompanion({
    this.id = const Value.absent(),
    this.corsoId = const Value.absent(),
    this.inizio = const Value.absent(),
    this.minuti = const Value.absent(),
  });
  SessioniCompanion.insert({
    this.id = const Value.absent(),
    this.corsoId = const Value.absent(),
    required DateTime inizio,
    required int minuti,
  }) : inizio = Value(inizio),
       minuti = Value(minuti);
  static Insertable<Sessione> custom({
    Expression<int>? id,
    Expression<int>? corsoId,
    Expression<DateTime>? inizio,
    Expression<int>? minuti,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (corsoId != null) 'corso_id': corsoId,
      if (inizio != null) 'inizio': inizio,
      if (minuti != null) 'minuti': minuti,
    });
  }

  SessioniCompanion copyWith({
    Value<int>? id,
    Value<int?>? corsoId,
    Value<DateTime>? inizio,
    Value<int>? minuti,
  }) {
    return SessioniCompanion(
      id: id ?? this.id,
      corsoId: corsoId ?? this.corsoId,
      inizio: inizio ?? this.inizio,
      minuti: minuti ?? this.minuti,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (corsoId.present) {
      map['corso_id'] = Variable<int>(corsoId.value);
    }
    if (inizio.present) {
      map['inizio'] = Variable<DateTime>(inizio.value);
    }
    if (minuti.present) {
      map['minuti'] = Variable<int>(minuti.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessioniCompanion(')
          ..write('id: $id, ')
          ..write('corsoId: $corsoId, ')
          ..write('inizio: $inizio, ')
          ..write('minuti: $minuti')
          ..write(')'))
        .toString();
  }
}

class $PagineStudiateTable extends PagineStudiate
    with TableInfo<$PagineStudiateTable, PaginaStudiata> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagineStudiateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentoIdMeta = const VerificationMeta(
    'documentoId',
  );
  @override
  late final GeneratedColumn<int> documentoId = GeneratedColumn<int>(
    'documento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documenti (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _paginaMeta = const VerificationMeta('pagina');
  @override
  late final GeneratedColumn<int> pagina = GeneratedColumn<int>(
    'pagina',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [documentoId, pagina, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagine_studiate';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaginaStudiata> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('documento_id')) {
      context.handle(
        _documentoIdMeta,
        documentoId.isAcceptableOrUnknown(
          data['documento_id']!,
          _documentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentoIdMeta);
    }
    if (data.containsKey('pagina')) {
      context.handle(
        _paginaMeta,
        pagina.isAcceptableOrUnknown(data['pagina']!, _paginaMeta),
      );
    } else if (isInserting) {
      context.missing(_paginaMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentoId, pagina};
  @override
  PaginaStudiata map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaginaStudiata(
      documentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}documento_id'],
      )!,
      pagina: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pagina'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $PagineStudiateTable createAlias(String alias) {
    return $PagineStudiateTable(attachedDatabase, alias);
  }
}

class PaginaStudiata extends DataClass implements Insertable<PaginaStudiata> {
  final int documentoId;
  final int pagina;
  final DateTime data;
  const PaginaStudiata({
    required this.documentoId,
    required this.pagina,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['documento_id'] = Variable<int>(documentoId);
    map['pagina'] = Variable<int>(pagina);
    map['data'] = Variable<DateTime>(data);
    return map;
  }

  PagineStudiateCompanion toCompanion(bool nullToAbsent) {
    return PagineStudiateCompanion(
      documentoId: Value(documentoId),
      pagina: Value(pagina),
      data: Value(data),
    );
  }

  factory PaginaStudiata.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaginaStudiata(
      documentoId: serializer.fromJson<int>(json['documentoId']),
      pagina: serializer.fromJson<int>(json['pagina']),
      data: serializer.fromJson<DateTime>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentoId': serializer.toJson<int>(documentoId),
      'pagina': serializer.toJson<int>(pagina),
      'data': serializer.toJson<DateTime>(data),
    };
  }

  PaginaStudiata copyWith({int? documentoId, int? pagina, DateTime? data}) =>
      PaginaStudiata(
        documentoId: documentoId ?? this.documentoId,
        pagina: pagina ?? this.pagina,
        data: data ?? this.data,
      );
  PaginaStudiata copyWithCompanion(PagineStudiateCompanion data) {
    return PaginaStudiata(
      documentoId: data.documentoId.present
          ? data.documentoId.value
          : this.documentoId,
      pagina: data.pagina.present ? data.pagina.value : this.pagina,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaginaStudiata(')
          ..write('documentoId: $documentoId, ')
          ..write('pagina: $pagina, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(documentoId, pagina, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaginaStudiata &&
          other.documentoId == this.documentoId &&
          other.pagina == this.pagina &&
          other.data == this.data);
}

class PagineStudiateCompanion extends UpdateCompanion<PaginaStudiata> {
  final Value<int> documentoId;
  final Value<int> pagina;
  final Value<DateTime> data;
  final Value<int> rowid;
  const PagineStudiateCompanion({
    this.documentoId = const Value.absent(),
    this.pagina = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagineStudiateCompanion.insert({
    required int documentoId,
    required int pagina,
    required DateTime data,
    this.rowid = const Value.absent(),
  }) : documentoId = Value(documentoId),
       pagina = Value(pagina),
       data = Value(data);
  static Insertable<PaginaStudiata> custom({
    Expression<int>? documentoId,
    Expression<int>? pagina,
    Expression<DateTime>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentoId != null) 'documento_id': documentoId,
      if (pagina != null) 'pagina': pagina,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagineStudiateCompanion copyWith({
    Value<int>? documentoId,
    Value<int>? pagina,
    Value<DateTime>? data,
    Value<int>? rowid,
  }) {
    return PagineStudiateCompanion(
      documentoId: documentoId ?? this.documentoId,
      pagina: pagina ?? this.pagina,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentoId.present) {
      map['documento_id'] = Variable<int>(documentoId.value);
    }
    if (pagina.present) {
      map['pagina'] = Variable<int>(pagina.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagineStudiateCompanion(')
          ..write('documentoId: $documentoId, ')
          ..write('pagina: $pagina, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrattiTable extends Tratti with TableInfo<$TrattiTable, Tratto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrattiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentoIdMeta = const VerificationMeta(
    'documentoId',
  );
  @override
  late final GeneratedColumn<int> documentoId = GeneratedColumn<int>(
    'documento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documenti (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _paginaMeta = const VerificationMeta('pagina');
  @override
  late final GeneratedColumn<int> pagina = GeneratedColumn<int>(
    'pagina',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coloreMeta = const VerificationMeta('colore');
  @override
  late final GeneratedColumn<int> colore = GeneratedColumn<int>(
    'colore',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spessoreMeta = const VerificationMeta(
    'spessore',
  );
  @override
  late final GeneratedColumn<double> spessore = GeneratedColumn<double>(
    'spessore',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenziatoreMeta = const VerificationMeta(
    'evidenziatore',
  );
  @override
  late final GeneratedColumn<bool> evidenziatore = GeneratedColumn<bool>(
    'evidenziatore',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("evidenziatore" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _puntiMeta = const VerificationMeta('punti');
  @override
  late final GeneratedColumn<String> punti = GeneratedColumn<String>(
    'punti',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentoId,
    pagina,
    colore,
    spessore,
    evidenziatore,
    punti,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tratti';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tratto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('documento_id')) {
      context.handle(
        _documentoIdMeta,
        documentoId.isAcceptableOrUnknown(
          data['documento_id']!,
          _documentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentoIdMeta);
    }
    if (data.containsKey('pagina')) {
      context.handle(
        _paginaMeta,
        pagina.isAcceptableOrUnknown(data['pagina']!, _paginaMeta),
      );
    } else if (isInserting) {
      context.missing(_paginaMeta);
    }
    if (data.containsKey('colore')) {
      context.handle(
        _coloreMeta,
        colore.isAcceptableOrUnknown(data['colore']!, _coloreMeta),
      );
    } else if (isInserting) {
      context.missing(_coloreMeta);
    }
    if (data.containsKey('spessore')) {
      context.handle(
        _spessoreMeta,
        spessore.isAcceptableOrUnknown(data['spessore']!, _spessoreMeta),
      );
    } else if (isInserting) {
      context.missing(_spessoreMeta);
    }
    if (data.containsKey('evidenziatore')) {
      context.handle(
        _evidenziatoreMeta,
        evidenziatore.isAcceptableOrUnknown(
          data['evidenziatore']!,
          _evidenziatoreMeta,
        ),
      );
    }
    if (data.containsKey('punti')) {
      context.handle(
        _puntiMeta,
        punti.isAcceptableOrUnknown(data['punti']!, _puntiMeta),
      );
    } else if (isInserting) {
      context.missing(_puntiMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tratto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tratto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}documento_id'],
      )!,
      pagina: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pagina'],
      )!,
      colore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colore'],
      )!,
      spessore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spessore'],
      )!,
      evidenziatore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}evidenziatore'],
      )!,
      punti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}punti'],
      )!,
    );
  }

  @override
  $TrattiTable createAlias(String alias) {
    return $TrattiTable(attachedDatabase, alias);
  }
}

class Tratto extends DataClass implements Insertable<Tratto> {
  final int id;
  final int documentoId;
  final int pagina;
  final int colore;
  final double spessore;
  final bool evidenziatore;
  final String punti;
  const Tratto({
    required this.id,
    required this.documentoId,
    required this.pagina,
    required this.colore,
    required this.spessore,
    required this.evidenziatore,
    required this.punti,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['documento_id'] = Variable<int>(documentoId);
    map['pagina'] = Variable<int>(pagina);
    map['colore'] = Variable<int>(colore);
    map['spessore'] = Variable<double>(spessore);
    map['evidenziatore'] = Variable<bool>(evidenziatore);
    map['punti'] = Variable<String>(punti);
    return map;
  }

  TrattiCompanion toCompanion(bool nullToAbsent) {
    return TrattiCompanion(
      id: Value(id),
      documentoId: Value(documentoId),
      pagina: Value(pagina),
      colore: Value(colore),
      spessore: Value(spessore),
      evidenziatore: Value(evidenziatore),
      punti: Value(punti),
    );
  }

  factory Tratto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tratto(
      id: serializer.fromJson<int>(json['id']),
      documentoId: serializer.fromJson<int>(json['documentoId']),
      pagina: serializer.fromJson<int>(json['pagina']),
      colore: serializer.fromJson<int>(json['colore']),
      spessore: serializer.fromJson<double>(json['spessore']),
      evidenziatore: serializer.fromJson<bool>(json['evidenziatore']),
      punti: serializer.fromJson<String>(json['punti']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentoId': serializer.toJson<int>(documentoId),
      'pagina': serializer.toJson<int>(pagina),
      'colore': serializer.toJson<int>(colore),
      'spessore': serializer.toJson<double>(spessore),
      'evidenziatore': serializer.toJson<bool>(evidenziatore),
      'punti': serializer.toJson<String>(punti),
    };
  }

  Tratto copyWith({
    int? id,
    int? documentoId,
    int? pagina,
    int? colore,
    double? spessore,
    bool? evidenziatore,
    String? punti,
  }) => Tratto(
    id: id ?? this.id,
    documentoId: documentoId ?? this.documentoId,
    pagina: pagina ?? this.pagina,
    colore: colore ?? this.colore,
    spessore: spessore ?? this.spessore,
    evidenziatore: evidenziatore ?? this.evidenziatore,
    punti: punti ?? this.punti,
  );
  Tratto copyWithCompanion(TrattiCompanion data) {
    return Tratto(
      id: data.id.present ? data.id.value : this.id,
      documentoId: data.documentoId.present
          ? data.documentoId.value
          : this.documentoId,
      pagina: data.pagina.present ? data.pagina.value : this.pagina,
      colore: data.colore.present ? data.colore.value : this.colore,
      spessore: data.spessore.present ? data.spessore.value : this.spessore,
      evidenziatore: data.evidenziatore.present
          ? data.evidenziatore.value
          : this.evidenziatore,
      punti: data.punti.present ? data.punti.value : this.punti,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tratto(')
          ..write('id: $id, ')
          ..write('documentoId: $documentoId, ')
          ..write('pagina: $pagina, ')
          ..write('colore: $colore, ')
          ..write('spessore: $spessore, ')
          ..write('evidenziatore: $evidenziatore, ')
          ..write('punti: $punti')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentoId,
    pagina,
    colore,
    spessore,
    evidenziatore,
    punti,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tratto &&
          other.id == this.id &&
          other.documentoId == this.documentoId &&
          other.pagina == this.pagina &&
          other.colore == this.colore &&
          other.spessore == this.spessore &&
          other.evidenziatore == this.evidenziatore &&
          other.punti == this.punti);
}

class TrattiCompanion extends UpdateCompanion<Tratto> {
  final Value<int> id;
  final Value<int> documentoId;
  final Value<int> pagina;
  final Value<int> colore;
  final Value<double> spessore;
  final Value<bool> evidenziatore;
  final Value<String> punti;
  const TrattiCompanion({
    this.id = const Value.absent(),
    this.documentoId = const Value.absent(),
    this.pagina = const Value.absent(),
    this.colore = const Value.absent(),
    this.spessore = const Value.absent(),
    this.evidenziatore = const Value.absent(),
    this.punti = const Value.absent(),
  });
  TrattiCompanion.insert({
    this.id = const Value.absent(),
    required int documentoId,
    required int pagina,
    required int colore,
    required double spessore,
    this.evidenziatore = const Value.absent(),
    required String punti,
  }) : documentoId = Value(documentoId),
       pagina = Value(pagina),
       colore = Value(colore),
       spessore = Value(spessore),
       punti = Value(punti);
  static Insertable<Tratto> custom({
    Expression<int>? id,
    Expression<int>? documentoId,
    Expression<int>? pagina,
    Expression<int>? colore,
    Expression<double>? spessore,
    Expression<bool>? evidenziatore,
    Expression<String>? punti,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentoId != null) 'documento_id': documentoId,
      if (pagina != null) 'pagina': pagina,
      if (colore != null) 'colore': colore,
      if (spessore != null) 'spessore': spessore,
      if (evidenziatore != null) 'evidenziatore': evidenziatore,
      if (punti != null) 'punti': punti,
    });
  }

  TrattiCompanion copyWith({
    Value<int>? id,
    Value<int>? documentoId,
    Value<int>? pagina,
    Value<int>? colore,
    Value<double>? spessore,
    Value<bool>? evidenziatore,
    Value<String>? punti,
  }) {
    return TrattiCompanion(
      id: id ?? this.id,
      documentoId: documentoId ?? this.documentoId,
      pagina: pagina ?? this.pagina,
      colore: colore ?? this.colore,
      spessore: spessore ?? this.spessore,
      evidenziatore: evidenziatore ?? this.evidenziatore,
      punti: punti ?? this.punti,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentoId.present) {
      map['documento_id'] = Variable<int>(documentoId.value);
    }
    if (pagina.present) {
      map['pagina'] = Variable<int>(pagina.value);
    }
    if (colore.present) {
      map['colore'] = Variable<int>(colore.value);
    }
    if (spessore.present) {
      map['spessore'] = Variable<double>(spessore.value);
    }
    if (evidenziatore.present) {
      map['evidenziatore'] = Variable<bool>(evidenziatore.value);
    }
    if (punti.present) {
      map['punti'] = Variable<String>(punti.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrattiCompanion(')
          ..write('id: $id, ')
          ..write('documentoId: $documentoId, ')
          ..write('pagina: $pagina, ')
          ..write('colore: $colore, ')
          ..write('spessore: $spessore, ')
          ..write('evidenziatore: $evidenziatore, ')
          ..write('punti: $punti')
          ..write(')'))
        .toString();
  }
}

class $DomandeEscluseTable extends DomandeEscluse
    with TableInfo<$DomandeEscluseTable, DomandaEsclusa> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DomandeEscluseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentoIdMeta = const VerificationMeta(
    'documentoId',
  );
  @override
  late final GeneratedColumn<int> documentoId = GeneratedColumn<int>(
    'documento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documenti (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fraseMeta = const VerificationMeta('frase');
  @override
  late final GeneratedColumn<String> frase = GeneratedColumn<String>(
    'frase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [documentoId, frase];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'domande_escluse';
  @override
  VerificationContext validateIntegrity(
    Insertable<DomandaEsclusa> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('documento_id')) {
      context.handle(
        _documentoIdMeta,
        documentoId.isAcceptableOrUnknown(
          data['documento_id']!,
          _documentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentoIdMeta);
    }
    if (data.containsKey('frase')) {
      context.handle(
        _fraseMeta,
        frase.isAcceptableOrUnknown(data['frase']!, _fraseMeta),
      );
    } else if (isInserting) {
      context.missing(_fraseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentoId, frase};
  @override
  DomandaEsclusa map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DomandaEsclusa(
      documentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}documento_id'],
      )!,
      frase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frase'],
      )!,
    );
  }

  @override
  $DomandeEscluseTable createAlias(String alias) {
    return $DomandeEscluseTable(attachedDatabase, alias);
  }
}

class DomandaEsclusa extends DataClass implements Insertable<DomandaEsclusa> {
  final int documentoId;
  final String frase;
  const DomandaEsclusa({required this.documentoId, required this.frase});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['documento_id'] = Variable<int>(documentoId);
    map['frase'] = Variable<String>(frase);
    return map;
  }

  DomandeEscluseCompanion toCompanion(bool nullToAbsent) {
    return DomandeEscluseCompanion(
      documentoId: Value(documentoId),
      frase: Value(frase),
    );
  }

  factory DomandaEsclusa.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DomandaEsclusa(
      documentoId: serializer.fromJson<int>(json['documentoId']),
      frase: serializer.fromJson<String>(json['frase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentoId': serializer.toJson<int>(documentoId),
      'frase': serializer.toJson<String>(frase),
    };
  }

  DomandaEsclusa copyWith({int? documentoId, String? frase}) => DomandaEsclusa(
    documentoId: documentoId ?? this.documentoId,
    frase: frase ?? this.frase,
  );
  DomandaEsclusa copyWithCompanion(DomandeEscluseCompanion data) {
    return DomandaEsclusa(
      documentoId: data.documentoId.present
          ? data.documentoId.value
          : this.documentoId,
      frase: data.frase.present ? data.frase.value : this.frase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DomandaEsclusa(')
          ..write('documentoId: $documentoId, ')
          ..write('frase: $frase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(documentoId, frase);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DomandaEsclusa &&
          other.documentoId == this.documentoId &&
          other.frase == this.frase);
}

class DomandeEscluseCompanion extends UpdateCompanion<DomandaEsclusa> {
  final Value<int> documentoId;
  final Value<String> frase;
  final Value<int> rowid;
  const DomandeEscluseCompanion({
    this.documentoId = const Value.absent(),
    this.frase = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DomandeEscluseCompanion.insert({
    required int documentoId,
    required String frase,
    this.rowid = const Value.absent(),
  }) : documentoId = Value(documentoId),
       frase = Value(frase);
  static Insertable<DomandaEsclusa> custom({
    Expression<int>? documentoId,
    Expression<String>? frase,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentoId != null) 'documento_id': documentoId,
      if (frase != null) 'frase': frase,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DomandeEscluseCompanion copyWith({
    Value<int>? documentoId,
    Value<String>? frase,
    Value<int>? rowid,
  }) {
    return DomandeEscluseCompanion(
      documentoId: documentoId ?? this.documentoId,
      frase: frase ?? this.frase,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentoId.present) {
      map['documento_id'] = Variable<int>(documentoId.value);
    }
    if (frase.present) {
      map['frase'] = Variable<String>(frase.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DomandeEscluseCompanion(')
          ..write('documentoId: $documentoId, ')
          ..write('frase: $frase, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AuriDb extends GeneratedDatabase {
  _$AuriDb(QueryExecutor e) : super(e);
  $AuriDbManager get managers => $AuriDbManager(this);
  late final $CorsiTable corsi = $CorsiTable(this);
  late final $EsitiTable esiti = $EsitiTable(this);
  late final $AppelliTable appelli = $AppelliTable(this);
  late final $ImpostazioniTable impostazioni = $ImpostazioniTable(this);
  late final $DocumentiTable documenti = $DocumentiTable(this);
  late final $PagineTable pagine = $PagineTable(this);
  late final $CarteTable carte = $CarteTable(this);
  late final $RevisioniTable revisioni = $RevisioniTable(this);
  late final $SimulazioniTable simulazioni = $SimulazioniTable(this);
  late final $SessioniTable sessioni = $SessioniTable(this);
  late final $PagineStudiateTable pagineStudiate = $PagineStudiateTable(this);
  late final $TrattiTable tratti = $TrattiTable(this);
  late final $DomandeEscluseTable domandeEscluse = $DomandeEscluseTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    corsi,
    esiti,
    appelli,
    impostazioni,
    documenti,
    pagine,
    carte,
    revisioni,
    simulazioni,
    sessioni,
    pagineStudiate,
    tratti,
    domandeEscluse,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'corsi',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('esiti', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'corsi',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('appelli', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'corsi',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('documenti', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documenti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pagine', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'corsi',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('carte', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documenti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('carte', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'carte',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('revisioni', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'corsi',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('simulazioni', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'corsi',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessioni', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documenti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pagine_studiate', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documenti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tratti', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documenti',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('domande_escluse', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CorsiTableCreateCompanionBuilder = CorsiCompanion Function({
  Value<int> id,
  required String nome,
  required int cfu,
  Value<int> anno,
  Value<int?> semestre,
  Value<String?> docente,
  Value<String> colore,
  required Valutazione valutazione,
});
typedef $$CorsiTableUpdateCompanionBuilder = CorsiCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> cfu,
  Value<int> anno,
  Value<int?> semestre,
  Value<String?> docente,
  Value<String> colore,
  Value<Valutazione> valutazione,
});

final class $$CorsiTableReferences
    extends BaseReferences<_$AuriDb, $CorsiTable, Corso> {
  $$CorsiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EsitiTable, List<Esito>> _esitiRefsTable(
    _$AuriDb db,
  ) => MultiTypedResultKey.fromTable(
    db.esiti,
    aliasName: 'corsi__id__esiti__corso_id',
  );

  $$EsitiTableProcessedTableManager get esitiRefs {
    final manager = $$EsitiTableTableManager(
      $_db,
      $_db.esiti,
    ).filter((f) => f.corsoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_esitiRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppelliTable, List<Appello>> _appelliRefsTable(
    _$AuriDb db,
  ) => MultiTypedResultKey.fromTable(
    db.appelli,
    aliasName: 'corsi__id__appelli__corso_id',
  );

  $$AppelliTableProcessedTableManager get appelliRefs {
    final manager = $$AppelliTableTableManager(
      $_db,
      $_db.appelli,
    ).filter((f) => f.corsoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appelliRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentiTable, List<Documento>>
  _documentiRefsTable(_$AuriDb db) => MultiTypedResultKey.fromTable(
    db.documenti,
    aliasName: 'corsi__id__documenti__corso_id',
  );

  $$DocumentiTableProcessedTableManager get documentiRefs {
    final manager = $$DocumentiTableTableManager(
      $_db,
      $_db.documenti,
    ).filter((f) => f.corsoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentiRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CarteTable, List<Carta>> _carteRefsTable(
    _$AuriDb db,
  ) => MultiTypedResultKey.fromTable(
    db.carte,
    aliasName: 'corsi__id__carte__corso_id',
  );

  $$CarteTableProcessedTableManager get carteRefs {
    final manager = $$CarteTableTableManager(
      $_db,
      $_db.carte,
    ).filter((f) => f.corsoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_carteRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SimulazioniTable, List<Simulazione>>
  _simulazioniRefsTable(_$AuriDb db) => MultiTypedResultKey.fromTable(
    db.simulazioni,
    aliasName: 'corsi__id__simulazioni__corso_id',
  );

  $$SimulazioniTableProcessedTableManager get simulazioniRefs {
    final manager = $$SimulazioniTableTableManager(
      $_db,
      $_db.simulazioni,
    ).filter((f) => f.corsoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_simulazioniRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessioniTable, List<Sessione>> _sessioniRefsTable(
    _$AuriDb db,
  ) => MultiTypedResultKey.fromTable(
    db.sessioni,
    aliasName: 'corsi__id__sessioni__corso_id',
  );

  $$SessioniTableProcessedTableManager get sessioniRefs {
    final manager = $$SessioniTableTableManager(
      $_db,
      $_db.sessioni,
    ).filter((f) => f.corsoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessioniRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CorsiTableFilterComposer extends Composer<_$AuriDb, $CorsiTable> {
  $$CorsiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cfu => $composableBuilder(
    column: $table.cfu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anno => $composableBuilder(
    column: $table.anno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get semestre => $composableBuilder(
    column: $table.semestre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docente => $composableBuilder(
    column: $table.docente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colore => $composableBuilder(
    column: $table.colore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Valutazione, Valutazione, int>
  get valutazione => $composableBuilder(
    column: $table.valutazione,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> esitiRefs(
    Expression<bool> Function($$EsitiTableFilterComposer f) f,
  ) {
    final $$EsitiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.esiti,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsitiTableFilterComposer(
            $db: $db,
            $table: $db.esiti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appelliRefs(
    Expression<bool> Function($$AppelliTableFilterComposer f) f,
  ) {
    final $$AppelliTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appelli,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppelliTableFilterComposer(
            $db: $db,
            $table: $db.appelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentiRefs(
    Expression<bool> Function($$DocumentiTableFilterComposer f) f,
  ) {
    final $$DocumentiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableFilterComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> carteRefs(
    Expression<bool> Function($$CarteTableFilterComposer f) f,
  ) {
    final $$CarteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carte,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarteTableFilterComposer(
            $db: $db,
            $table: $db.carte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> simulazioniRefs(
    Expression<bool> Function($$SimulazioniTableFilterComposer f) f,
  ) {
    final $$SimulazioniTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.simulazioni,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SimulazioniTableFilterComposer(
            $db: $db,
            $table: $db.simulazioni,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessioniRefs(
    Expression<bool> Function($$SessioniTableFilterComposer f) f,
  ) {
    final $$SessioniTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessioni,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessioniTableFilterComposer(
            $db: $db,
            $table: $db.sessioni,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CorsiTableOrderingComposer extends Composer<_$AuriDb, $CorsiTable> {
  $$CorsiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cfu => $composableBuilder(
    column: $table.cfu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anno => $composableBuilder(
    column: $table.anno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get semestre => $composableBuilder(
    column: $table.semestre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docente => $composableBuilder(
    column: $table.docente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colore => $composableBuilder(
    column: $table.colore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valutazione => $composableBuilder(
    column: $table.valutazione,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CorsiTableAnnotationComposer extends Composer<_$AuriDb, $CorsiTable> {
  $$CorsiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get cfu =>
      $composableBuilder(column: $table.cfu, builder: (column) => column);

  GeneratedColumn<int> get anno =>
      $composableBuilder(column: $table.anno, builder: (column) => column);

  GeneratedColumn<int> get semestre =>
      $composableBuilder(column: $table.semestre, builder: (column) => column);

  GeneratedColumn<String> get docente =>
      $composableBuilder(column: $table.docente, builder: (column) => column);

  GeneratedColumn<String> get colore =>
      $composableBuilder(column: $table.colore, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Valutazione, int> get valutazione =>
      $composableBuilder(
        column: $table.valutazione,
        builder: (column) => column,
      );

  Expression<T> esitiRefs<T extends Object>(
    Expression<T> Function($$EsitiTableAnnotationComposer a) f,
  ) {
    final $$EsitiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.esiti,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsitiTableAnnotationComposer(
            $db: $db,
            $table: $db.esiti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> appelliRefs<T extends Object>(
    Expression<T> Function($$AppelliTableAnnotationComposer a) f,
  ) {
    final $$AppelliTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appelli,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppelliTableAnnotationComposer(
            $db: $db,
            $table: $db.appelli,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentiRefs<T extends Object>(
    Expression<T> Function($$DocumentiTableAnnotationComposer a) f,
  ) {
    final $$DocumentiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableAnnotationComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> carteRefs<T extends Object>(
    Expression<T> Function($$CarteTableAnnotationComposer a) f,
  ) {
    final $$CarteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carte,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarteTableAnnotationComposer(
            $db: $db,
            $table: $db.carte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> simulazioniRefs<T extends Object>(
    Expression<T> Function($$SimulazioniTableAnnotationComposer a) f,
  ) {
    final $$SimulazioniTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.simulazioni,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SimulazioniTableAnnotationComposer(
            $db: $db,
            $table: $db.simulazioni,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessioniRefs<T extends Object>(
    Expression<T> Function($$SessioniTableAnnotationComposer a) f,
  ) {
    final $$SessioniTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessioni,
      getReferencedColumn: (t) => t.corsoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessioniTableAnnotationComposer(
            $db: $db,
            $table: $db.sessioni,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CorsiTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $CorsiTable,
          Corso,
          $$CorsiTableFilterComposer,
          $$CorsiTableOrderingComposer,
          $$CorsiTableAnnotationComposer,
          $$CorsiTableCreateCompanionBuilder,
          $$CorsiTableUpdateCompanionBuilder,
          (Corso, $$CorsiTableReferences),
          Corso,
          PrefetchHooks Function({
            bool esitiRefs,
            bool appelliRefs,
            bool documentiRefs,
            bool carteRefs,
            bool simulazioniRefs,
            bool sessioniRefs,
          })
        > {
  $$CorsiTableTableManager(_$AuriDb db, $CorsiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CorsiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CorsiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CorsiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> cfu = const Value.absent(),
                Value<int> anno = const Value.absent(),
                Value<int?> semestre = const Value.absent(),
                Value<String?> docente = const Value.absent(),
                Value<String> colore = const Value.absent(),
                Value<Valutazione> valutazione = const Value.absent(),
              }) => CorsiCompanion(
                id: id,
                nome: nome,
                cfu: cfu,
                anno: anno,
                semestre: semestre,
                docente: docente,
                colore: colore,
                valutazione: valutazione,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required int cfu,
                Value<int> anno = const Value.absent(),
                Value<int?> semestre = const Value.absent(),
                Value<String?> docente = const Value.absent(),
                Value<String> colore = const Value.absent(),
                required Valutazione valutazione,
              }) => CorsiCompanion.insert(
                id: id,
                nome: nome,
                cfu: cfu,
                anno: anno,
                semestre: semestre,
                docente: docente,
                colore: colore,
                valutazione: valutazione,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CorsiTable, Corso>(table),
                  $$CorsiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                esitiRefs = false,
                appelliRefs = false,
                documentiRefs = false,
                carteRefs = false,
                simulazioniRefs = false,
                sessioniRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (esitiRefs) db.esiti,
                    if (appelliRefs) db.appelli,
                    if (documentiRefs) db.documenti,
                    if (carteRefs) db.carte,
                    if (simulazioniRefs) db.simulazioni,
                    if (sessioniRefs) db.sessioni,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (esitiRefs)
                        await $_getPrefetchedData<Corso, $CorsiTable, Esito>(
                          currentTable: table,
                          referencedTable: $$CorsiTableReferences
                              ._esitiRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CorsiTableReferences(db, table, p0).esitiRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.corsoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (appelliRefs)
                        await $_getPrefetchedData<Corso, $CorsiTable, Appello>(
                          currentTable: table,
                          referencedTable: $$CorsiTableReferences
                              ._appelliRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CorsiTableReferences(db, table, p0).appelliRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.corsoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentiRefs)
                        await $_getPrefetchedData<
                          Corso,
                          $CorsiTable,
                          Documento
                        >(
                          currentTable: table,
                          referencedTable: $$CorsiTableReferences
                              ._documentiRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CorsiTableReferences(
                                db,
                                table,
                                p0,
                              ).documentiRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.corsoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (carteRefs)
                        await $_getPrefetchedData<Corso, $CorsiTable, Carta>(
                          currentTable: table,
                          referencedTable: $$CorsiTableReferences
                              ._carteRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CorsiTableReferences(db, table, p0).carteRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.corsoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (simulazioniRefs)
                        await $_getPrefetchedData<
                          Corso,
                          $CorsiTable,
                          Simulazione
                        >(
                          currentTable: table,
                          referencedTable: $$CorsiTableReferences
                              ._simulazioniRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CorsiTableReferences(
                                db,
                                table,
                                p0,
                              ).simulazioniRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.corsoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessioniRefs)
                        await $_getPrefetchedData<Corso, $CorsiTable, Sessione>(
                          currentTable: table,
                          referencedTable: $$CorsiTableReferences
                              ._sessioniRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CorsiTableReferences(
                                db,
                                table,
                                p0,
                              ).sessioniRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.corsoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CorsiTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $CorsiTable,
      Corso,
      $$CorsiTableFilterComposer,
      $$CorsiTableOrderingComposer,
      $$CorsiTableAnnotationComposer,
      $$CorsiTableCreateCompanionBuilder,
      $$CorsiTableUpdateCompanionBuilder,
      (Corso, $$CorsiTableReferences),
      Corso,
      PrefetchHooks Function({
        bool esitiRefs,
        bool appelliRefs,
        bool documentiRefs,
        bool carteRefs,
        bool simulazioniRefs,
        bool sessioniRefs,
      })
    >;
typedef $$EsitiTableCreateCompanionBuilder = EsitiCompanion Function({
  Value<int> corsoId,
  Value<int?> voto,
  Value<bool> lode,
  required DateTime data,
});
typedef $$EsitiTableUpdateCompanionBuilder = EsitiCompanion Function({
  Value<int> corsoId,
  Value<int?> voto,
  Value<bool> lode,
  Value<DateTime> data,
});

final class $$EsitiTableReferences
    extends BaseReferences<_$AuriDb, $EsitiTable, Esito> {
  $$EsitiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CorsiTable _corsoIdTable(_$AuriDb db) =>
      db.corsi.createAlias('esiti__corso_id__corsi__id');

  $$CorsiTableProcessedTableManager get corsoId {
    final $_column = $_itemColumn<int>('corso_id')!;

    final manager = $$CorsiTableTableManager(
      $_db,
      $_db.corsi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_corsoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EsitiTableFilterComposer extends Composer<_$AuriDb, $EsitiTable> {
  $$EsitiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get voto => $composableBuilder(
    column: $table.voto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lode => $composableBuilder(
    column: $table.lode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  $$CorsiTableFilterComposer get corsoId {
    final $$CorsiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableFilterComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EsitiTableOrderingComposer extends Composer<_$AuriDb, $EsitiTable> {
  $$EsitiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get voto => $composableBuilder(
    column: $table.voto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lode => $composableBuilder(
    column: $table.lode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  $$CorsiTableOrderingComposer get corsoId {
    final $$CorsiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableOrderingComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EsitiTableAnnotationComposer extends Composer<_$AuriDb, $EsitiTable> {
  $$EsitiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get voto =>
      $composableBuilder(column: $table.voto, builder: (column) => column);

  GeneratedColumn<bool> get lode =>
      $composableBuilder(column: $table.lode, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  $$CorsiTableAnnotationComposer get corsoId {
    final $$CorsiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableAnnotationComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EsitiTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $EsitiTable,
          Esito,
          $$EsitiTableFilterComposer,
          $$EsitiTableOrderingComposer,
          $$EsitiTableAnnotationComposer,
          $$EsitiTableCreateCompanionBuilder,
          $$EsitiTableUpdateCompanionBuilder,
          (Esito, $$EsitiTableReferences),
          Esito,
          PrefetchHooks Function({bool corsoId})
        > {
  $$EsitiTableTableManager(_$AuriDb db, $EsitiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EsitiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EsitiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EsitiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> corsoId = const Value.absent(),
                Value<int?> voto = const Value.absent(),
                Value<bool> lode = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
              }) => EsitiCompanion(
                corsoId: corsoId,
                voto: voto,
                lode: lode,
                data: data,
              ),
          createCompanionCallback:
              ({
                Value<int> corsoId = const Value.absent(),
                Value<int?> voto = const Value.absent(),
                Value<bool> lode = const Value.absent(),
                required DateTime data,
              }) => EsitiCompanion.insert(
                corsoId: corsoId,
                voto: voto,
                lode: lode,
                data: data,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EsitiTable, Esito>(table),
                  $$EsitiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({corsoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (corsoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.corsoId,
                        referencedTable: $$EsitiTableReferences._corsoIdTable(
                          db,
                        ),
                        referencedColumn: $$EsitiTableReferences
                            ._corsoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EsitiTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $EsitiTable,
      Esito,
      $$EsitiTableFilterComposer,
      $$EsitiTableOrderingComposer,
      $$EsitiTableAnnotationComposer,
      $$EsitiTableCreateCompanionBuilder,
      $$EsitiTableUpdateCompanionBuilder,
      (Esito, $$EsitiTableReferences),
      Esito,
      PrefetchHooks Function({bool corsoId})
    >;
typedef $$AppelliTableCreateCompanionBuilder = AppelliCompanion Function({
  Value<int> id,
  required int corsoId,
  required DateTime dataOra,
  required TipoAppello tipo,
  Value<String?> aula,
  Value<bool> iscritta,
  Value<String> preavvisi,
  Value<String?> note,
});
typedef $$AppelliTableUpdateCompanionBuilder = AppelliCompanion Function({
  Value<int> id,
  Value<int> corsoId,
  Value<DateTime> dataOra,
  Value<TipoAppello> tipo,
  Value<String?> aula,
  Value<bool> iscritta,
  Value<String> preavvisi,
  Value<String?> note,
});

final class $$AppelliTableReferences
    extends BaseReferences<_$AuriDb, $AppelliTable, Appello> {
  $$AppelliTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CorsiTable _corsoIdTable(_$AuriDb db) =>
      db.corsi.createAlias('appelli__corso_id__corsi__id');

  $$CorsiTableProcessedTableManager get corsoId {
    final $_column = $_itemColumn<int>('corso_id')!;

    final manager = $$CorsiTableTableManager(
      $_db,
      $_db.corsi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_corsoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppelliTableFilterComposer extends Composer<_$AuriDb, $AppelliTable> {
  $$AppelliTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataOra => $composableBuilder(
    column: $table.dataOra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoAppello, TipoAppello, int> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get aula => $composableBuilder(
    column: $table.aula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get iscritta => $composableBuilder(
    column: $table.iscritta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preavvisi => $composableBuilder(
    column: $table.preavvisi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$CorsiTableFilterComposer get corsoId {
    final $$CorsiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableFilterComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppelliTableOrderingComposer extends Composer<_$AuriDb, $AppelliTable> {
  $$AppelliTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataOra => $composableBuilder(
    column: $table.dataOra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aula => $composableBuilder(
    column: $table.aula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get iscritta => $composableBuilder(
    column: $table.iscritta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preavvisi => $composableBuilder(
    column: $table.preavvisi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$CorsiTableOrderingComposer get corsoId {
    final $$CorsiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableOrderingComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppelliTableAnnotationComposer
    extends Composer<_$AuriDb, $AppelliTable> {
  $$AppelliTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dataOra =>
      $composableBuilder(column: $table.dataOra, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoAppello, int> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get aula =>
      $composableBuilder(column: $table.aula, builder: (column) => column);

  GeneratedColumn<bool> get iscritta =>
      $composableBuilder(column: $table.iscritta, builder: (column) => column);

  GeneratedColumn<String> get preavvisi =>
      $composableBuilder(column: $table.preavvisi, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$CorsiTableAnnotationComposer get corsoId {
    final $$CorsiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableAnnotationComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppelliTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $AppelliTable,
          Appello,
          $$AppelliTableFilterComposer,
          $$AppelliTableOrderingComposer,
          $$AppelliTableAnnotationComposer,
          $$AppelliTableCreateCompanionBuilder,
          $$AppelliTableUpdateCompanionBuilder,
          (Appello, $$AppelliTableReferences),
          Appello,
          PrefetchHooks Function({bool corsoId})
        > {
  $$AppelliTableTableManager(_$AuriDb db, $AppelliTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppelliTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppelliTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppelliTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> corsoId = const Value.absent(),
                Value<DateTime> dataOra = const Value.absent(),
                Value<TipoAppello> tipo = const Value.absent(),
                Value<String?> aula = const Value.absent(),
                Value<bool> iscritta = const Value.absent(),
                Value<String> preavvisi = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => AppelliCompanion(
                id: id,
                corsoId: corsoId,
                dataOra: dataOra,
                tipo: tipo,
                aula: aula,
                iscritta: iscritta,
                preavvisi: preavvisi,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int corsoId,
                required DateTime dataOra,
                required TipoAppello tipo,
                Value<String?> aula = const Value.absent(),
                Value<bool> iscritta = const Value.absent(),
                Value<String> preavvisi = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => AppelliCompanion.insert(
                id: id,
                corsoId: corsoId,
                dataOra: dataOra,
                tipo: tipo,
                aula: aula,
                iscritta: iscritta,
                preavvisi: preavvisi,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppelliTable, Appello>(table),
                  $$AppelliTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({corsoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (corsoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.corsoId,
                        referencedTable: $$AppelliTableReferences._corsoIdTable(
                          db,
                        ),
                        referencedColumn: $$AppelliTableReferences
                            ._corsoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AppelliTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $AppelliTable,
      Appello,
      $$AppelliTableFilterComposer,
      $$AppelliTableOrderingComposer,
      $$AppelliTableAnnotationComposer,
      $$AppelliTableCreateCompanionBuilder,
      $$AppelliTableUpdateCompanionBuilder,
      (Appello, $$AppelliTableReferences),
      Appello,
      PrefetchHooks Function({bool corsoId})
    >;
typedef $$ImpostazioniTableCreateCompanionBuilder =
    ImpostazioniCompanion Function({
      required String chiave,
      required String valore,
      Value<int> rowid,
    });
typedef $$ImpostazioniTableUpdateCompanionBuilder =
    ImpostazioniCompanion Function({
      Value<String> chiave,
      Value<String> valore,
      Value<int> rowid,
    });

class $$ImpostazioniTableFilterComposer
    extends Composer<_$AuriDb, $ImpostazioniTable> {
  $$ImpostazioniTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chiave => $composableBuilder(
    column: $table.chiave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valore => $composableBuilder(
    column: $table.valore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImpostazioniTableOrderingComposer
    extends Composer<_$AuriDb, $ImpostazioniTable> {
  $$ImpostazioniTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chiave => $composableBuilder(
    column: $table.chiave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valore => $composableBuilder(
    column: $table.valore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImpostazioniTableAnnotationComposer
    extends Composer<_$AuriDb, $ImpostazioniTable> {
  $$ImpostazioniTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chiave =>
      $composableBuilder(column: $table.chiave, builder: (column) => column);

  GeneratedColumn<String> get valore =>
      $composableBuilder(column: $table.valore, builder: (column) => column);
}

class $$ImpostazioniTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $ImpostazioniTable,
          Impostazione,
          $$ImpostazioniTableFilterComposer,
          $$ImpostazioniTableOrderingComposer,
          $$ImpostazioniTableAnnotationComposer,
          $$ImpostazioniTableCreateCompanionBuilder,
          $$ImpostazioniTableUpdateCompanionBuilder,
          (
            Impostazione,
            BaseReferences<_$AuriDb, $ImpostazioniTable, Impostazione>,
          ),
          Impostazione,
          PrefetchHooks Function()
        > {
  $$ImpostazioniTableTableManager(_$AuriDb db, $ImpostazioniTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImpostazioniTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImpostazioniTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImpostazioniTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chiave = const Value.absent(),
                Value<String> valore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImpostazioniCompanion(
                chiave: chiave,
                valore: valore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chiave,
                required String valore,
                Value<int> rowid = const Value.absent(),
              }) => ImpostazioniCompanion.insert(
                chiave: chiave,
                valore: valore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImpostazioniTable, Impostazione>(table),
                  BaseReferences<_$AuriDb, $ImpostazioniTable, Impostazione>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImpostazioniTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $ImpostazioniTable,
      Impostazione,
      $$ImpostazioniTableFilterComposer,
      $$ImpostazioniTableOrderingComposer,
      $$ImpostazioniTableAnnotationComposer,
      $$ImpostazioniTableCreateCompanionBuilder,
      $$ImpostazioniTableUpdateCompanionBuilder,
      (
        Impostazione,
        BaseReferences<_$AuriDb, $ImpostazioniTable, Impostazione>,
      ),
      Impostazione,
      PrefetchHooks Function()
    >;
typedef $$DocumentiTableCreateCompanionBuilder = DocumentiCompanion Function({
  Value<int> id,
  required int corsoId,
  required String titolo,
  required String nomeFile,
  required int numeroPagine,
  required DateTime importatoIl,
});
typedef $$DocumentiTableUpdateCompanionBuilder = DocumentiCompanion Function({
  Value<int> id,
  Value<int> corsoId,
  Value<String> titolo,
  Value<String> nomeFile,
  Value<int> numeroPagine,
  Value<DateTime> importatoIl,
});

final class $$DocumentiTableReferences
    extends BaseReferences<_$AuriDb, $DocumentiTable, Documento> {
  $$DocumentiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CorsiTable _corsoIdTable(_$AuriDb db) =>
      db.corsi.createAlias('documenti__corso_id__corsi__id');

  $$CorsiTableProcessedTableManager get corsoId {
    final $_column = $_itemColumn<int>('corso_id')!;

    final manager = $$CorsiTableTableManager(
      $_db,
      $_db.corsi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_corsoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PagineTable, List<Pagina>> _pagineRefsTable(
    _$AuriDb db,
  ) => MultiTypedResultKey.fromTable(
    db.pagine,
    aliasName: 'documenti__id__pagine__documento_id',
  );

  $$PagineTableProcessedTableManager get pagineRefs {
    final manager = $$PagineTableTableManager(
      $_db,
      $_db.pagine,
    ).filter((f) => f.documentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagineRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CarteTable, List<Carta>> _carteRefsTable(
    _$AuriDb db,
  ) => MultiTypedResultKey.fromTable(
    db.carte,
    aliasName: 'documenti__id__carte__documento_id',
  );

  $$CarteTableProcessedTableManager get carteRefs {
    final manager = $$CarteTableTableManager(
      $_db,
      $_db.carte,
    ).filter((f) => f.documentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_carteRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PagineStudiateTable, List<PaginaStudiata>>
  _pagineStudiateRefsTable(_$AuriDb db) => MultiTypedResultKey.fromTable(
    db.pagineStudiate,
    aliasName: 'documenti__id__pagine_studiate__documento_id',
  );

  $$PagineStudiateTableProcessedTableManager get pagineStudiateRefs {
    final manager = $$PagineStudiateTableTableManager(
      $_db,
      $_db.pagineStudiate,
    ).filter((f) => f.documentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagineStudiateRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrattiTable, List<Tratto>> _trattiRefsTable(
    _$AuriDb db,
  ) => MultiTypedResultKey.fromTable(
    db.tratti,
    aliasName: 'documenti__id__tratti__documento_id',
  );

  $$TrattiTableProcessedTableManager get trattiRefs {
    final manager = $$TrattiTableTableManager(
      $_db,
      $_db.tratti,
    ).filter((f) => f.documentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trattiRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DomandeEscluseTable, List<DomandaEsclusa>>
  _domandeEscluseRefsTable(_$AuriDb db) => MultiTypedResultKey.fromTable(
    db.domandeEscluse,
    aliasName: 'documenti__id__domande_escluse__documento_id',
  );

  $$DomandeEscluseTableProcessedTableManager get domandeEscluseRefs {
    final manager = $$DomandeEscluseTableTableManager(
      $_db,
      $_db.domandeEscluse,
    ).filter((f) => f.documentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_domandeEscluseRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentiTableFilterComposer
    extends Composer<_$AuriDb, $DocumentiTable> {
  $$DocumentiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeFile => $composableBuilder(
    column: $table.nomeFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numeroPagine => $composableBuilder(
    column: $table.numeroPagine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importatoIl => $composableBuilder(
    column: $table.importatoIl,
    builder: (column) => ColumnFilters(column),
  );

  $$CorsiTableFilterComposer get corsoId {
    final $$CorsiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableFilterComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> pagineRefs(
    Expression<bool> Function($$PagineTableFilterComposer f) f,
  ) {
    final $$PagineTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagine,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagineTableFilterComposer(
            $db: $db,
            $table: $db.pagine,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> carteRefs(
    Expression<bool> Function($$CarteTableFilterComposer f) f,
  ) {
    final $$CarteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carte,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarteTableFilterComposer(
            $db: $db,
            $table: $db.carte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pagineStudiateRefs(
    Expression<bool> Function($$PagineStudiateTableFilterComposer f) f,
  ) {
    final $$PagineStudiateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagineStudiate,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagineStudiateTableFilterComposer(
            $db: $db,
            $table: $db.pagineStudiate,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trattiRefs(
    Expression<bool> Function($$TrattiTableFilterComposer f) f,
  ) {
    final $$TrattiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tratti,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrattiTableFilterComposer(
            $db: $db,
            $table: $db.tratti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> domandeEscluseRefs(
    Expression<bool> Function($$DomandeEscluseTableFilterComposer f) f,
  ) {
    final $$DomandeEscluseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.domandeEscluse,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DomandeEscluseTableFilterComposer(
            $db: $db,
            $table: $db.domandeEscluse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentiTableOrderingComposer
    extends Composer<_$AuriDb, $DocumentiTable> {
  $$DocumentiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeFile => $composableBuilder(
    column: $table.nomeFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numeroPagine => $composableBuilder(
    column: $table.numeroPagine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importatoIl => $composableBuilder(
    column: $table.importatoIl,
    builder: (column) => ColumnOrderings(column),
  );

  $$CorsiTableOrderingComposer get corsoId {
    final $$CorsiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableOrderingComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentiTableAnnotationComposer
    extends Composer<_$AuriDb, $DocumentiTable> {
  $$DocumentiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titolo =>
      $composableBuilder(column: $table.titolo, builder: (column) => column);

  GeneratedColumn<String> get nomeFile =>
      $composableBuilder(column: $table.nomeFile, builder: (column) => column);

  GeneratedColumn<int> get numeroPagine => $composableBuilder(
    column: $table.numeroPagine,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importatoIl => $composableBuilder(
    column: $table.importatoIl,
    builder: (column) => column,
  );

  $$CorsiTableAnnotationComposer get corsoId {
    final $$CorsiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableAnnotationComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> pagineRefs<T extends Object>(
    Expression<T> Function($$PagineTableAnnotationComposer a) f,
  ) {
    final $$PagineTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagine,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagineTableAnnotationComposer(
            $db: $db,
            $table: $db.pagine,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> carteRefs<T extends Object>(
    Expression<T> Function($$CarteTableAnnotationComposer a) f,
  ) {
    final $$CarteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carte,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarteTableAnnotationComposer(
            $db: $db,
            $table: $db.carte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pagineStudiateRefs<T extends Object>(
    Expression<T> Function($$PagineStudiateTableAnnotationComposer a) f,
  ) {
    final $$PagineStudiateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagineStudiate,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagineStudiateTableAnnotationComposer(
            $db: $db,
            $table: $db.pagineStudiate,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trattiRefs<T extends Object>(
    Expression<T> Function($$TrattiTableAnnotationComposer a) f,
  ) {
    final $$TrattiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tratti,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrattiTableAnnotationComposer(
            $db: $db,
            $table: $db.tratti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> domandeEscluseRefs<T extends Object>(
    Expression<T> Function($$DomandeEscluseTableAnnotationComposer a) f,
  ) {
    final $$DomandeEscluseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.domandeEscluse,
      getReferencedColumn: (t) => t.documentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DomandeEscluseTableAnnotationComposer(
            $db: $db,
            $table: $db.domandeEscluse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentiTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $DocumentiTable,
          Documento,
          $$DocumentiTableFilterComposer,
          $$DocumentiTableOrderingComposer,
          $$DocumentiTableAnnotationComposer,
          $$DocumentiTableCreateCompanionBuilder,
          $$DocumentiTableUpdateCompanionBuilder,
          (Documento, $$DocumentiTableReferences),
          Documento,
          PrefetchHooks Function({
            bool corsoId,
            bool pagineRefs,
            bool carteRefs,
            bool pagineStudiateRefs,
            bool trattiRefs,
            bool domandeEscluseRefs,
          })
        > {
  $$DocumentiTableTableManager(_$AuriDb db, $DocumentiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> corsoId = const Value.absent(),
                Value<String> titolo = const Value.absent(),
                Value<String> nomeFile = const Value.absent(),
                Value<int> numeroPagine = const Value.absent(),
                Value<DateTime> importatoIl = const Value.absent(),
              }) => DocumentiCompanion(
                id: id,
                corsoId: corsoId,
                titolo: titolo,
                nomeFile: nomeFile,
                numeroPagine: numeroPagine,
                importatoIl: importatoIl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int corsoId,
                required String titolo,
                required String nomeFile,
                required int numeroPagine,
                required DateTime importatoIl,
              }) => DocumentiCompanion.insert(
                id: id,
                corsoId: corsoId,
                titolo: titolo,
                nomeFile: nomeFile,
                numeroPagine: numeroPagine,
                importatoIl: importatoIl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentiTable, Documento>(table),
                  $$DocumentiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                corsoId = false,
                pagineRefs = false,
                carteRefs = false,
                pagineStudiateRefs = false,
                trattiRefs = false,
                domandeEscluseRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pagineRefs) db.pagine,
                    if (carteRefs) db.carte,
                    if (pagineStudiateRefs) db.pagineStudiate,
                    if (trattiRefs) db.tratti,
                    if (domandeEscluseRefs) db.domandeEscluse,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (corsoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.corsoId,
                            referencedTable: $$DocumentiTableReferences
                                ._corsoIdTable(db),
                            referencedColumn: $$DocumentiTableReferences
                                ._corsoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pagineRefs)
                        await $_getPrefetchedData<
                          Documento,
                          $DocumentiTable,
                          Pagina
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentiTableReferences
                              ._pagineRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentiTableReferences(
                                db,
                                table,
                                p0,
                              ).pagineRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (carteRefs)
                        await $_getPrefetchedData<
                          Documento,
                          $DocumentiTable,
                          Carta
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentiTableReferences
                              ._carteRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentiTableReferences(
                                db,
                                table,
                                p0,
                              ).carteRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pagineStudiateRefs)
                        await $_getPrefetchedData<
                          Documento,
                          $DocumentiTable,
                          PaginaStudiata
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentiTableReferences
                              ._pagineStudiateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentiTableReferences(
                                db,
                                table,
                                p0,
                              ).pagineStudiateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trattiRefs)
                        await $_getPrefetchedData<
                          Documento,
                          $DocumentiTable,
                          Tratto
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentiTableReferences
                              ._trattiRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentiTableReferences(
                                db,
                                table,
                                p0,
                              ).trattiRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (domandeEscluseRefs)
                        await $_getPrefetchedData<
                          Documento,
                          $DocumentiTable,
                          DomandaEsclusa
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentiTableReferences
                              ._domandeEscluseRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentiTableReferences(
                                db,
                                table,
                                p0,
                              ).domandeEscluseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentiTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $DocumentiTable,
      Documento,
      $$DocumentiTableFilterComposer,
      $$DocumentiTableOrderingComposer,
      $$DocumentiTableAnnotationComposer,
      $$DocumentiTableCreateCompanionBuilder,
      $$DocumentiTableUpdateCompanionBuilder,
      (Documento, $$DocumentiTableReferences),
      Documento,
      PrefetchHooks Function({
        bool corsoId,
        bool pagineRefs,
        bool carteRefs,
        bool pagineStudiateRefs,
        bool trattiRefs,
        bool domandeEscluseRefs,
      })
    >;
typedef $$PagineTableCreateCompanionBuilder = PagineCompanion Function({
  Value<int> id,
  required int documentoId,
  required int numero,
  required String titolo,
  required String testo,
});
typedef $$PagineTableUpdateCompanionBuilder = PagineCompanion Function({
  Value<int> id,
  Value<int> documentoId,
  Value<int> numero,
  Value<String> titolo,
  Value<String> testo,
});

final class $$PagineTableReferences
    extends BaseReferences<_$AuriDb, $PagineTable, Pagina> {
  $$PagineTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentiTable _documentoIdTable(_$AuriDb db) =>
      db.documenti.createAlias('pagine__documento_id__documenti__id');

  $$DocumentiTableProcessedTableManager get documentoId {
    final $_column = $_itemColumn<int>('documento_id')!;

    final manager = $$DocumentiTableTableManager(
      $_db,
      $_db.documenti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PagineTableFilterComposer extends Composer<_$AuriDb, $PagineTable> {
  $$PagineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testo => $composableBuilder(
    column: $table.testo,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentiTableFilterComposer get documentoId {
    final $$DocumentiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableFilterComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagineTableOrderingComposer extends Composer<_$AuriDb, $PagineTable> {
  $$PagineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titolo => $composableBuilder(
    column: $table.titolo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testo => $composableBuilder(
    column: $table.testo,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentiTableOrderingComposer get documentoId {
    final $$DocumentiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableOrderingComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagineTableAnnotationComposer extends Composer<_$AuriDb, $PagineTable> {
  $$PagineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get titolo =>
      $composableBuilder(column: $table.titolo, builder: (column) => column);

  GeneratedColumn<String> get testo =>
      $composableBuilder(column: $table.testo, builder: (column) => column);

  $$DocumentiTableAnnotationComposer get documentoId {
    final $$DocumentiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableAnnotationComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagineTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $PagineTable,
          Pagina,
          $$PagineTableFilterComposer,
          $$PagineTableOrderingComposer,
          $$PagineTableAnnotationComposer,
          $$PagineTableCreateCompanionBuilder,
          $$PagineTableUpdateCompanionBuilder,
          (Pagina, $$PagineTableReferences),
          Pagina,
          PrefetchHooks Function({bool documentoId})
        > {
  $$PagineTableTableManager(_$AuriDb db, $PagineTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagineTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagineTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagineTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentoId = const Value.absent(),
                Value<int> numero = const Value.absent(),
                Value<String> titolo = const Value.absent(),
                Value<String> testo = const Value.absent(),
              }) => PagineCompanion(
                id: id,
                documentoId: documentoId,
                numero: numero,
                titolo: titolo,
                testo: testo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentoId,
                required int numero,
                required String titolo,
                required String testo,
              }) => PagineCompanion.insert(
                id: id,
                documentoId: documentoId,
                numero: numero,
                titolo: titolo,
                testo: testo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagineTable, Pagina>(table),
                  $$PagineTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentoId,
                        referencedTable: $$PagineTableReferences
                            ._documentoIdTable(db),
                        referencedColumn: $$PagineTableReferences
                            ._documentoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PagineTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $PagineTable,
      Pagina,
      $$PagineTableFilterComposer,
      $$PagineTableOrderingComposer,
      $$PagineTableAnnotationComposer,
      $$PagineTableCreateCompanionBuilder,
      $$PagineTableUpdateCompanionBuilder,
      (Pagina, $$PagineTableReferences),
      Pagina,
      PrefetchHooks Function({bool documentoId})
    >;
typedef $$CarteTableCreateCompanionBuilder = CarteCompanion Function({
  Value<int> id,
  required int corsoId,
  Value<int?> documentoId,
  Value<int?> pagina,
  required String fronte,
  required String retro,
  required OrigineCarta origine,
  Value<int> ripetizioni,
  Value<int> intervallo,
  Value<double> facilita,
  Value<DateTime?> prossima,
  Value<bool> esclusa,
});
typedef $$CarteTableUpdateCompanionBuilder = CarteCompanion Function({
  Value<int> id,
  Value<int> corsoId,
  Value<int?> documentoId,
  Value<int?> pagina,
  Value<String> fronte,
  Value<String> retro,
  Value<OrigineCarta> origine,
  Value<int> ripetizioni,
  Value<int> intervallo,
  Value<double> facilita,
  Value<DateTime?> prossima,
  Value<bool> esclusa,
});

final class $$CarteTableReferences
    extends BaseReferences<_$AuriDb, $CarteTable, Carta> {
  $$CarteTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CorsiTable _corsoIdTable(_$AuriDb db) =>
      db.corsi.createAlias('carte__corso_id__corsi__id');

  $$CorsiTableProcessedTableManager get corsoId {
    final $_column = $_itemColumn<int>('corso_id')!;

    final manager = $$CorsiTableTableManager(
      $_db,
      $_db.corsi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_corsoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentiTable _documentoIdTable(_$AuriDb db) =>
      db.documenti.createAlias('carte__documento_id__documenti__id');

  $$DocumentiTableProcessedTableManager? get documentoId {
    final $_column = $_itemColumn<int>('documento_id');
    if ($_column == null) return null;
    final manager = $$DocumentiTableTableManager(
      $_db,
      $_db.documenti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RevisioniTable, List<Revisione>>
  _revisioniRefsTable(_$AuriDb db) => MultiTypedResultKey.fromTable(
    db.revisioni,
    aliasName: 'carte__id__revisioni__carta_id',
  );

  $$RevisioniTableProcessedTableManager get revisioniRefs {
    final manager = $$RevisioniTableTableManager(
      $_db,
      $_db.revisioni,
    ).filter((f) => f.cartaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_revisioniRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CarteTableFilterComposer extends Composer<_$AuriDb, $CarteTable> {
  $$CarteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagina => $composableBuilder(
    column: $table.pagina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fronte => $composableBuilder(
    column: $table.fronte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retro => $composableBuilder(
    column: $table.retro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OrigineCarta, OrigineCarta, int> get origine =>
      $composableBuilder(
        column: $table.origine,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get ripetizioni => $composableBuilder(
    column: $table.ripetizioni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervallo => $composableBuilder(
    column: $table.intervallo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get facilita => $composableBuilder(
    column: $table.facilita,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get prossima => $composableBuilder(
    column: $table.prossima,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esclusa => $composableBuilder(
    column: $table.esclusa,
    builder: (column) => ColumnFilters(column),
  );

  $$CorsiTableFilterComposer get corsoId {
    final $$CorsiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableFilterComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentiTableFilterComposer get documentoId {
    final $$DocumentiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableFilterComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> revisioniRefs(
    Expression<bool> Function($$RevisioniTableFilterComposer f) f,
  ) {
    final $$RevisioniTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisioni,
      getReferencedColumn: (t) => t.cartaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisioniTableFilterComposer(
            $db: $db,
            $table: $db.revisioni,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarteTableOrderingComposer extends Composer<_$AuriDb, $CarteTable> {
  $$CarteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagina => $composableBuilder(
    column: $table.pagina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fronte => $composableBuilder(
    column: $table.fronte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retro => $composableBuilder(
    column: $table.retro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get origine => $composableBuilder(
    column: $table.origine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ripetizioni => $composableBuilder(
    column: $table.ripetizioni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervallo => $composableBuilder(
    column: $table.intervallo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get facilita => $composableBuilder(
    column: $table.facilita,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get prossima => $composableBuilder(
    column: $table.prossima,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esclusa => $composableBuilder(
    column: $table.esclusa,
    builder: (column) => ColumnOrderings(column),
  );

  $$CorsiTableOrderingComposer get corsoId {
    final $$CorsiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableOrderingComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentiTableOrderingComposer get documentoId {
    final $$DocumentiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableOrderingComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarteTableAnnotationComposer extends Composer<_$AuriDb, $CarteTable> {
  $$CarteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pagina =>
      $composableBuilder(column: $table.pagina, builder: (column) => column);

  GeneratedColumn<String> get fronte =>
      $composableBuilder(column: $table.fronte, builder: (column) => column);

  GeneratedColumn<String> get retro =>
      $composableBuilder(column: $table.retro, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OrigineCarta, int> get origine =>
      $composableBuilder(column: $table.origine, builder: (column) => column);

  GeneratedColumn<int> get ripetizioni => $composableBuilder(
    column: $table.ripetizioni,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervallo => $composableBuilder(
    column: $table.intervallo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get facilita =>
      $composableBuilder(column: $table.facilita, builder: (column) => column);

  GeneratedColumn<DateTime> get prossima =>
      $composableBuilder(column: $table.prossima, builder: (column) => column);

  GeneratedColumn<bool> get esclusa =>
      $composableBuilder(column: $table.esclusa, builder: (column) => column);

  $$CorsiTableAnnotationComposer get corsoId {
    final $$CorsiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableAnnotationComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentiTableAnnotationComposer get documentoId {
    final $$DocumentiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableAnnotationComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> revisioniRefs<T extends Object>(
    Expression<T> Function($$RevisioniTableAnnotationComposer a) f,
  ) {
    final $$RevisioniTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisioni,
      getReferencedColumn: (t) => t.cartaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisioniTableAnnotationComposer(
            $db: $db,
            $table: $db.revisioni,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarteTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $CarteTable,
          Carta,
          $$CarteTableFilterComposer,
          $$CarteTableOrderingComposer,
          $$CarteTableAnnotationComposer,
          $$CarteTableCreateCompanionBuilder,
          $$CarteTableUpdateCompanionBuilder,
          (Carta, $$CarteTableReferences),
          Carta,
          PrefetchHooks Function({
            bool corsoId,
            bool documentoId,
            bool revisioniRefs,
          })
        > {
  $$CarteTableTableManager(_$AuriDb db, $CarteTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> corsoId = const Value.absent(),
                Value<int?> documentoId = const Value.absent(),
                Value<int?> pagina = const Value.absent(),
                Value<String> fronte = const Value.absent(),
                Value<String> retro = const Value.absent(),
                Value<OrigineCarta> origine = const Value.absent(),
                Value<int> ripetizioni = const Value.absent(),
                Value<int> intervallo = const Value.absent(),
                Value<double> facilita = const Value.absent(),
                Value<DateTime?> prossima = const Value.absent(),
                Value<bool> esclusa = const Value.absent(),
              }) => CarteCompanion(
                id: id,
                corsoId: corsoId,
                documentoId: documentoId,
                pagina: pagina,
                fronte: fronte,
                retro: retro,
                origine: origine,
                ripetizioni: ripetizioni,
                intervallo: intervallo,
                facilita: facilita,
                prossima: prossima,
                esclusa: esclusa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int corsoId,
                Value<int?> documentoId = const Value.absent(),
                Value<int?> pagina = const Value.absent(),
                required String fronte,
                required String retro,
                required OrigineCarta origine,
                Value<int> ripetizioni = const Value.absent(),
                Value<int> intervallo = const Value.absent(),
                Value<double> facilita = const Value.absent(),
                Value<DateTime?> prossima = const Value.absent(),
                Value<bool> esclusa = const Value.absent(),
              }) => CarteCompanion.insert(
                id: id,
                corsoId: corsoId,
                documentoId: documentoId,
                pagina: pagina,
                fronte: fronte,
                retro: retro,
                origine: origine,
                ripetizioni: ripetizioni,
                intervallo: intervallo,
                facilita: facilita,
                prossima: prossima,
                esclusa: esclusa,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CarteTable, Carta>(table),
                  $$CarteTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({corsoId = false, documentoId = false, revisioniRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (revisioniRefs) db.revisioni],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (corsoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.corsoId,
                            referencedTable: $$CarteTableReferences
                                ._corsoIdTable(db),
                            referencedColumn: $$CarteTableReferences
                                ._corsoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (documentoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.documentoId,
                            referencedTable: $$CarteTableReferences
                                ._documentoIdTable(db),
                            referencedColumn: $$CarteTableReferences
                                ._documentoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (revisioniRefs)
                        await $_getPrefetchedData<
                          Carta,
                          $CarteTable,
                          Revisione
                        >(
                          currentTable: table,
                          referencedTable: $$CarteTableReferences
                              ._revisioniRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CarteTableReferences(
                                db,
                                table,
                                p0,
                              ).revisioniRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cartaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CarteTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $CarteTable,
      Carta,
      $$CarteTableFilterComposer,
      $$CarteTableOrderingComposer,
      $$CarteTableAnnotationComposer,
      $$CarteTableCreateCompanionBuilder,
      $$CarteTableUpdateCompanionBuilder,
      (Carta, $$CarteTableReferences),
      Carta,
      PrefetchHooks Function({
        bool corsoId,
        bool documentoId,
        bool revisioniRefs,
      })
    >;
typedef $$RevisioniTableCreateCompanionBuilder = RevisioniCompanion Function({
  Value<int> id,
  required int cartaId,
  required DateTime data,
  required Risposta risposta,
});
typedef $$RevisioniTableUpdateCompanionBuilder = RevisioniCompanion Function({
  Value<int> id,
  Value<int> cartaId,
  Value<DateTime> data,
  Value<Risposta> risposta,
});

final class $$RevisioniTableReferences
    extends BaseReferences<_$AuriDb, $RevisioniTable, Revisione> {
  $$RevisioniTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CarteTable _cartaIdTable(_$AuriDb db) =>
      db.carte.createAlias('revisioni__carta_id__carte__id');

  $$CarteTableProcessedTableManager get cartaId {
    final $_column = $_itemColumn<int>('carta_id')!;

    final manager = $$CarteTableTableManager(
      $_db,
      $_db.carte,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RevisioniTableFilterComposer
    extends Composer<_$AuriDb, $RevisioniTable> {
  $$RevisioniTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Risposta, Risposta, int> get risposta =>
      $composableBuilder(
        column: $table.risposta,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CarteTableFilterComposer get cartaId {
    final $$CarteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaId,
      referencedTable: $db.carte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarteTableFilterComposer(
            $db: $db,
            $table: $db.carte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisioniTableOrderingComposer
    extends Composer<_$AuriDb, $RevisioniTable> {
  $$RevisioniTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get risposta => $composableBuilder(
    column: $table.risposta,
    builder: (column) => ColumnOrderings(column),
  );

  $$CarteTableOrderingComposer get cartaId {
    final $$CarteTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaId,
      referencedTable: $db.carte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarteTableOrderingComposer(
            $db: $db,
            $table: $db.carte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisioniTableAnnotationComposer
    extends Composer<_$AuriDb, $RevisioniTable> {
  $$RevisioniTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Risposta, int> get risposta =>
      $composableBuilder(column: $table.risposta, builder: (column) => column);

  $$CarteTableAnnotationComposer get cartaId {
    final $$CarteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaId,
      referencedTable: $db.carte,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarteTableAnnotationComposer(
            $db: $db,
            $table: $db.carte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisioniTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $RevisioniTable,
          Revisione,
          $$RevisioniTableFilterComposer,
          $$RevisioniTableOrderingComposer,
          $$RevisioniTableAnnotationComposer,
          $$RevisioniTableCreateCompanionBuilder,
          $$RevisioniTableUpdateCompanionBuilder,
          (Revisione, $$RevisioniTableReferences),
          Revisione,
          PrefetchHooks Function({bool cartaId})
        > {
  $$RevisioniTableTableManager(_$AuriDb db, $RevisioniTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevisioniTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevisioniTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevisioniTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cartaId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<Risposta> risposta = const Value.absent(),
              }) => RevisioniCompanion(
                id: id,
                cartaId: cartaId,
                data: data,
                risposta: risposta,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cartaId,
                required DateTime data,
                required Risposta risposta,
              }) => RevisioniCompanion.insert(
                id: id,
                cartaId: cartaId,
                data: data,
                risposta: risposta,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RevisioniTable, Revisione>(table),
                  $$RevisioniTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cartaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cartaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cartaId,
                        referencedTable: $$RevisioniTableReferences
                            ._cartaIdTable(db),
                        referencedColumn: $$RevisioniTableReferences
                            ._cartaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RevisioniTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $RevisioniTable,
      Revisione,
      $$RevisioniTableFilterComposer,
      $$RevisioniTableOrderingComposer,
      $$RevisioniTableAnnotationComposer,
      $$RevisioniTableCreateCompanionBuilder,
      $$RevisioniTableUpdateCompanionBuilder,
      (Revisione, $$RevisioniTableReferences),
      Revisione,
      PrefetchHooks Function({bool cartaId})
    >;
typedef $$SimulazioniTableCreateCompanionBuilder =
    SimulazioniCompanion Function({
      Value<int> id,
      required int corsoId,
      required DateTime data,
      required int domande,
      required int giuste,
      required int voto,
    });
typedef $$SimulazioniTableUpdateCompanionBuilder =
    SimulazioniCompanion Function({
      Value<int> id,
      Value<int> corsoId,
      Value<DateTime> data,
      Value<int> domande,
      Value<int> giuste,
      Value<int> voto,
    });

final class $$SimulazioniTableReferences
    extends BaseReferences<_$AuriDb, $SimulazioniTable, Simulazione> {
  $$SimulazioniTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CorsiTable _corsoIdTable(_$AuriDb db) =>
      db.corsi.createAlias('simulazioni__corso_id__corsi__id');

  $$CorsiTableProcessedTableManager get corsoId {
    final $_column = $_itemColumn<int>('corso_id')!;

    final manager = $$CorsiTableTableManager(
      $_db,
      $_db.corsi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_corsoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SimulazioniTableFilterComposer
    extends Composer<_$AuriDb, $SimulazioniTable> {
  $$SimulazioniTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get domande => $composableBuilder(
    column: $table.domande,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get giuste => $composableBuilder(
    column: $table.giuste,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voto => $composableBuilder(
    column: $table.voto,
    builder: (column) => ColumnFilters(column),
  );

  $$CorsiTableFilterComposer get corsoId {
    final $$CorsiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableFilterComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SimulazioniTableOrderingComposer
    extends Composer<_$AuriDb, $SimulazioniTable> {
  $$SimulazioniTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get domande => $composableBuilder(
    column: $table.domande,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get giuste => $composableBuilder(
    column: $table.giuste,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voto => $composableBuilder(
    column: $table.voto,
    builder: (column) => ColumnOrderings(column),
  );

  $$CorsiTableOrderingComposer get corsoId {
    final $$CorsiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableOrderingComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SimulazioniTableAnnotationComposer
    extends Composer<_$AuriDb, $SimulazioniTable> {
  $$SimulazioniTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get domande =>
      $composableBuilder(column: $table.domande, builder: (column) => column);

  GeneratedColumn<int> get giuste =>
      $composableBuilder(column: $table.giuste, builder: (column) => column);

  GeneratedColumn<int> get voto =>
      $composableBuilder(column: $table.voto, builder: (column) => column);

  $$CorsiTableAnnotationComposer get corsoId {
    final $$CorsiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableAnnotationComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SimulazioniTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $SimulazioniTable,
          Simulazione,
          $$SimulazioniTableFilterComposer,
          $$SimulazioniTableOrderingComposer,
          $$SimulazioniTableAnnotationComposer,
          $$SimulazioniTableCreateCompanionBuilder,
          $$SimulazioniTableUpdateCompanionBuilder,
          (Simulazione, $$SimulazioniTableReferences),
          Simulazione,
          PrefetchHooks Function({bool corsoId})
        > {
  $$SimulazioniTableTableManager(_$AuriDb db, $SimulazioniTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimulazioniTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SimulazioniTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SimulazioniTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> corsoId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> domande = const Value.absent(),
                Value<int> giuste = const Value.absent(),
                Value<int> voto = const Value.absent(),
              }) => SimulazioniCompanion(
                id: id,
                corsoId: corsoId,
                data: data,
                domande: domande,
                giuste: giuste,
                voto: voto,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int corsoId,
                required DateTime data,
                required int domande,
                required int giuste,
                required int voto,
              }) => SimulazioniCompanion.insert(
                id: id,
                corsoId: corsoId,
                data: data,
                domande: domande,
                giuste: giuste,
                voto: voto,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SimulazioniTable, Simulazione>(table),
                  $$SimulazioniTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({corsoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (corsoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.corsoId,
                        referencedTable: $$SimulazioniTableReferences
                            ._corsoIdTable(db),
                        referencedColumn: $$SimulazioniTableReferences
                            ._corsoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SimulazioniTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $SimulazioniTable,
      Simulazione,
      $$SimulazioniTableFilterComposer,
      $$SimulazioniTableOrderingComposer,
      $$SimulazioniTableAnnotationComposer,
      $$SimulazioniTableCreateCompanionBuilder,
      $$SimulazioniTableUpdateCompanionBuilder,
      (Simulazione, $$SimulazioniTableReferences),
      Simulazione,
      PrefetchHooks Function({bool corsoId})
    >;
typedef $$SessioniTableCreateCompanionBuilder = SessioniCompanion Function({
  Value<int> id,
  Value<int?> corsoId,
  required DateTime inizio,
  required int minuti,
});
typedef $$SessioniTableUpdateCompanionBuilder = SessioniCompanion Function({
  Value<int> id,
  Value<int?> corsoId,
  Value<DateTime> inizio,
  Value<int> minuti,
});

final class $$SessioniTableReferences
    extends BaseReferences<_$AuriDb, $SessioniTable, Sessione> {
  $$SessioniTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CorsiTable _corsoIdTable(_$AuriDb db) =>
      db.corsi.createAlias('sessioni__corso_id__corsi__id');

  $$CorsiTableProcessedTableManager? get corsoId {
    final $_column = $_itemColumn<int>('corso_id');
    if ($_column == null) return null;
    final manager = $$CorsiTableTableManager(
      $_db,
      $_db.corsi,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_corsoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessioniTableFilterComposer extends Composer<_$AuriDb, $SessioniTable> {
  $$SessioniTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inizio => $composableBuilder(
    column: $table.inizio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minuti => $composableBuilder(
    column: $table.minuti,
    builder: (column) => ColumnFilters(column),
  );

  $$CorsiTableFilterComposer get corsoId {
    final $$CorsiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableFilterComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessioniTableOrderingComposer
    extends Composer<_$AuriDb, $SessioniTable> {
  $$SessioniTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inizio => $composableBuilder(
    column: $table.inizio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minuti => $composableBuilder(
    column: $table.minuti,
    builder: (column) => ColumnOrderings(column),
  );

  $$CorsiTableOrderingComposer get corsoId {
    final $$CorsiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableOrderingComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessioniTableAnnotationComposer
    extends Composer<_$AuriDb, $SessioniTable> {
  $$SessioniTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get inizio =>
      $composableBuilder(column: $table.inizio, builder: (column) => column);

  GeneratedColumn<int> get minuti =>
      $composableBuilder(column: $table.minuti, builder: (column) => column);

  $$CorsiTableAnnotationComposer get corsoId {
    final $$CorsiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.corsoId,
      referencedTable: $db.corsi,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorsiTableAnnotationComposer(
            $db: $db,
            $table: $db.corsi,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessioniTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $SessioniTable,
          Sessione,
          $$SessioniTableFilterComposer,
          $$SessioniTableOrderingComposer,
          $$SessioniTableAnnotationComposer,
          $$SessioniTableCreateCompanionBuilder,
          $$SessioniTableUpdateCompanionBuilder,
          (Sessione, $$SessioniTableReferences),
          Sessione,
          PrefetchHooks Function({bool corsoId})
        > {
  $$SessioniTableTableManager(_$AuriDb db, $SessioniTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessioniTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessioniTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessioniTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> corsoId = const Value.absent(),
                Value<DateTime> inizio = const Value.absent(),
                Value<int> minuti = const Value.absent(),
              }) => SessioniCompanion(
                id: id,
                corsoId: corsoId,
                inizio: inizio,
                minuti: minuti,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> corsoId = const Value.absent(),
                required DateTime inizio,
                required int minuti,
              }) => SessioniCompanion.insert(
                id: id,
                corsoId: corsoId,
                inizio: inizio,
                minuti: minuti,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessioniTable, Sessione>(table),
                  $$SessioniTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({corsoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (corsoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.corsoId,
                        referencedTable: $$SessioniTableReferences
                            ._corsoIdTable(db),
                        referencedColumn: $$SessioniTableReferences
                            ._corsoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessioniTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $SessioniTable,
      Sessione,
      $$SessioniTableFilterComposer,
      $$SessioniTableOrderingComposer,
      $$SessioniTableAnnotationComposer,
      $$SessioniTableCreateCompanionBuilder,
      $$SessioniTableUpdateCompanionBuilder,
      (Sessione, $$SessioniTableReferences),
      Sessione,
      PrefetchHooks Function({bool corsoId})
    >;
typedef $$PagineStudiateTableCreateCompanionBuilder =
    PagineStudiateCompanion Function({
      required int documentoId,
      required int pagina,
      required DateTime data,
      Value<int> rowid,
    });
typedef $$PagineStudiateTableUpdateCompanionBuilder =
    PagineStudiateCompanion Function({
      Value<int> documentoId,
      Value<int> pagina,
      Value<DateTime> data,
      Value<int> rowid,
    });

final class $$PagineStudiateTableReferences
    extends BaseReferences<_$AuriDb, $PagineStudiateTable, PaginaStudiata> {
  $$PagineStudiateTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentiTable _documentoIdTable(_$AuriDb db) =>
      db.documenti.createAlias('pagine_studiate__documento_id__documenti__id');

  $$DocumentiTableProcessedTableManager get documentoId {
    final $_column = $_itemColumn<int>('documento_id')!;

    final manager = $$DocumentiTableTableManager(
      $_db,
      $_db.documenti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PagineStudiateTableFilterComposer
    extends Composer<_$AuriDb, $PagineStudiateTable> {
  $$PagineStudiateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pagina => $composableBuilder(
    column: $table.pagina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentiTableFilterComposer get documentoId {
    final $$DocumentiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableFilterComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagineStudiateTableOrderingComposer
    extends Composer<_$AuriDb, $PagineStudiateTable> {
  $$PagineStudiateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pagina => $composableBuilder(
    column: $table.pagina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentiTableOrderingComposer get documentoId {
    final $$DocumentiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableOrderingComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagineStudiateTableAnnotationComposer
    extends Composer<_$AuriDb, $PagineStudiateTable> {
  $$PagineStudiateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pagina =>
      $composableBuilder(column: $table.pagina, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  $$DocumentiTableAnnotationComposer get documentoId {
    final $$DocumentiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableAnnotationComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagineStudiateTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $PagineStudiateTable,
          PaginaStudiata,
          $$PagineStudiateTableFilterComposer,
          $$PagineStudiateTableOrderingComposer,
          $$PagineStudiateTableAnnotationComposer,
          $$PagineStudiateTableCreateCompanionBuilder,
          $$PagineStudiateTableUpdateCompanionBuilder,
          (PaginaStudiata, $$PagineStudiateTableReferences),
          PaginaStudiata,
          PrefetchHooks Function({bool documentoId})
        > {
  $$PagineStudiateTableTableManager(_$AuriDb db, $PagineStudiateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagineStudiateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagineStudiateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagineStudiateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> documentoId = const Value.absent(),
                Value<int> pagina = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagineStudiateCompanion(
                documentoId: documentoId,
                pagina: pagina,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int documentoId,
                required int pagina,
                required DateTime data,
                Value<int> rowid = const Value.absent(),
              }) => PagineStudiateCompanion.insert(
                documentoId: documentoId,
                pagina: pagina,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagineStudiateTable, PaginaStudiata>(table),
                  $$PagineStudiateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentoId,
                        referencedTable: $$PagineStudiateTableReferences
                            ._documentoIdTable(db),
                        referencedColumn: $$PagineStudiateTableReferences
                            ._documentoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PagineStudiateTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $PagineStudiateTable,
      PaginaStudiata,
      $$PagineStudiateTableFilterComposer,
      $$PagineStudiateTableOrderingComposer,
      $$PagineStudiateTableAnnotationComposer,
      $$PagineStudiateTableCreateCompanionBuilder,
      $$PagineStudiateTableUpdateCompanionBuilder,
      (PaginaStudiata, $$PagineStudiateTableReferences),
      PaginaStudiata,
      PrefetchHooks Function({bool documentoId})
    >;
typedef $$TrattiTableCreateCompanionBuilder = TrattiCompanion Function({
  Value<int> id,
  required int documentoId,
  required int pagina,
  required int colore,
  required double spessore,
  Value<bool> evidenziatore,
  required String punti,
});
typedef $$TrattiTableUpdateCompanionBuilder = TrattiCompanion Function({
  Value<int> id,
  Value<int> documentoId,
  Value<int> pagina,
  Value<int> colore,
  Value<double> spessore,
  Value<bool> evidenziatore,
  Value<String> punti,
});

final class $$TrattiTableReferences
    extends BaseReferences<_$AuriDb, $TrattiTable, Tratto> {
  $$TrattiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DocumentiTable _documentoIdTable(_$AuriDb db) =>
      db.documenti.createAlias('tratti__documento_id__documenti__id');

  $$DocumentiTableProcessedTableManager get documentoId {
    final $_column = $_itemColumn<int>('documento_id')!;

    final manager = $$DocumentiTableTableManager(
      $_db,
      $_db.documenti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrattiTableFilterComposer extends Composer<_$AuriDb, $TrattiTable> {
  $$TrattiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagina => $composableBuilder(
    column: $table.pagina,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colore => $composableBuilder(
    column: $table.colore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spessore => $composableBuilder(
    column: $table.spessore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get evidenziatore => $composableBuilder(
    column: $table.evidenziatore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get punti => $composableBuilder(
    column: $table.punti,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentiTableFilterComposer get documentoId {
    final $$DocumentiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableFilterComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrattiTableOrderingComposer extends Composer<_$AuriDb, $TrattiTable> {
  $$TrattiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagina => $composableBuilder(
    column: $table.pagina,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colore => $composableBuilder(
    column: $table.colore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spessore => $composableBuilder(
    column: $table.spessore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get evidenziatore => $composableBuilder(
    column: $table.evidenziatore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get punti => $composableBuilder(
    column: $table.punti,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentiTableOrderingComposer get documentoId {
    final $$DocumentiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableOrderingComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrattiTableAnnotationComposer extends Composer<_$AuriDb, $TrattiTable> {
  $$TrattiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pagina =>
      $composableBuilder(column: $table.pagina, builder: (column) => column);

  GeneratedColumn<int> get colore =>
      $composableBuilder(column: $table.colore, builder: (column) => column);

  GeneratedColumn<double> get spessore =>
      $composableBuilder(column: $table.spessore, builder: (column) => column);

  GeneratedColumn<bool> get evidenziatore => $composableBuilder(
    column: $table.evidenziatore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get punti =>
      $composableBuilder(column: $table.punti, builder: (column) => column);

  $$DocumentiTableAnnotationComposer get documentoId {
    final $$DocumentiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableAnnotationComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrattiTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $TrattiTable,
          Tratto,
          $$TrattiTableFilterComposer,
          $$TrattiTableOrderingComposer,
          $$TrattiTableAnnotationComposer,
          $$TrattiTableCreateCompanionBuilder,
          $$TrattiTableUpdateCompanionBuilder,
          (Tratto, $$TrattiTableReferences),
          Tratto,
          PrefetchHooks Function({bool documentoId})
        > {
  $$TrattiTableTableManager(_$AuriDb db, $TrattiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrattiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrattiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrattiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentoId = const Value.absent(),
                Value<int> pagina = const Value.absent(),
                Value<int> colore = const Value.absent(),
                Value<double> spessore = const Value.absent(),
                Value<bool> evidenziatore = const Value.absent(),
                Value<String> punti = const Value.absent(),
              }) => TrattiCompanion(
                id: id,
                documentoId: documentoId,
                pagina: pagina,
                colore: colore,
                spessore: spessore,
                evidenziatore: evidenziatore,
                punti: punti,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentoId,
                required int pagina,
                required int colore,
                required double spessore,
                Value<bool> evidenziatore = const Value.absent(),
                required String punti,
              }) => TrattiCompanion.insert(
                id: id,
                documentoId: documentoId,
                pagina: pagina,
                colore: colore,
                spessore: spessore,
                evidenziatore: evidenziatore,
                punti: punti,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrattiTable, Tratto>(table),
                  $$TrattiTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentoId,
                        referencedTable: $$TrattiTableReferences
                            ._documentoIdTable(db),
                        referencedColumn: $$TrattiTableReferences
                            ._documentoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrattiTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $TrattiTable,
      Tratto,
      $$TrattiTableFilterComposer,
      $$TrattiTableOrderingComposer,
      $$TrattiTableAnnotationComposer,
      $$TrattiTableCreateCompanionBuilder,
      $$TrattiTableUpdateCompanionBuilder,
      (Tratto, $$TrattiTableReferences),
      Tratto,
      PrefetchHooks Function({bool documentoId})
    >;
typedef $$DomandeEscluseTableCreateCompanionBuilder =
    DomandeEscluseCompanion Function({
      required int documentoId,
      required String frase,
      Value<int> rowid,
    });
typedef $$DomandeEscluseTableUpdateCompanionBuilder =
    DomandeEscluseCompanion Function({
      Value<int> documentoId,
      Value<String> frase,
      Value<int> rowid,
    });

final class $$DomandeEscluseTableReferences
    extends BaseReferences<_$AuriDb, $DomandeEscluseTable, DomandaEsclusa> {
  $$DomandeEscluseTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentiTable _documentoIdTable(_$AuriDb db) =>
      db.documenti.createAlias('domande_escluse__documento_id__documenti__id');

  $$DocumentiTableProcessedTableManager get documentoId {
    final $_column = $_itemColumn<int>('documento_id')!;

    final manager = $$DocumentiTableTableManager(
      $_db,
      $_db.documenti,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DomandeEscluseTableFilterComposer
    extends Composer<_$AuriDb, $DomandeEscluseTable> {
  $$DomandeEscluseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get frase => $composableBuilder(
    column: $table.frase,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentiTableFilterComposer get documentoId {
    final $$DocumentiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableFilterComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DomandeEscluseTableOrderingComposer
    extends Composer<_$AuriDb, $DomandeEscluseTable> {
  $$DomandeEscluseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get frase => $composableBuilder(
    column: $table.frase,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentiTableOrderingComposer get documentoId {
    final $$DocumentiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableOrderingComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DomandeEscluseTableAnnotationComposer
    extends Composer<_$AuriDb, $DomandeEscluseTable> {
  $$DomandeEscluseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get frase =>
      $composableBuilder(column: $table.frase, builder: (column) => column);

  $$DocumentiTableAnnotationComposer get documentoId {
    final $$DocumentiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentoId,
      referencedTable: $db.documenti,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentiTableAnnotationComposer(
            $db: $db,
            $table: $db.documenti,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DomandeEscluseTableTableManager
    extends
        RootTableManager<
          _$AuriDb,
          $DomandeEscluseTable,
          DomandaEsclusa,
          $$DomandeEscluseTableFilterComposer,
          $$DomandeEscluseTableOrderingComposer,
          $$DomandeEscluseTableAnnotationComposer,
          $$DomandeEscluseTableCreateCompanionBuilder,
          $$DomandeEscluseTableUpdateCompanionBuilder,
          (DomandaEsclusa, $$DomandeEscluseTableReferences),
          DomandaEsclusa,
          PrefetchHooks Function({bool documentoId})
        > {
  $$DomandeEscluseTableTableManager(_$AuriDb db, $DomandeEscluseTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DomandeEscluseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DomandeEscluseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DomandeEscluseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> documentoId = const Value.absent(),
                Value<String> frase = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DomandeEscluseCompanion(
                documentoId: documentoId,
                frase: frase,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int documentoId,
                required String frase,
                Value<int> rowid = const Value.absent(),
              }) => DomandeEscluseCompanion.insert(
                documentoId: documentoId,
                frase: frase,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DomandeEscluseTable, DomandaEsclusa>(table),
                  $$DomandeEscluseTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.documentoId,
                        referencedTable: $$DomandeEscluseTableReferences
                            ._documentoIdTable(db),
                        referencedColumn: $$DomandeEscluseTableReferences
                            ._documentoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DomandeEscluseTableProcessedTableManager =
    ProcessedTableManager<
      _$AuriDb,
      $DomandeEscluseTable,
      DomandaEsclusa,
      $$DomandeEscluseTableFilterComposer,
      $$DomandeEscluseTableOrderingComposer,
      $$DomandeEscluseTableAnnotationComposer,
      $$DomandeEscluseTableCreateCompanionBuilder,
      $$DomandeEscluseTableUpdateCompanionBuilder,
      (DomandaEsclusa, $$DomandeEscluseTableReferences),
      DomandaEsclusa,
      PrefetchHooks Function({bool documentoId})
    >;

class $AuriDbManager {
  final _$AuriDb _db;
  $AuriDbManager(this._db);
  $$CorsiTableTableManager get corsi =>
      $$CorsiTableTableManager(_db, _db.corsi);
  $$EsitiTableTableManager get esiti =>
      $$EsitiTableTableManager(_db, _db.esiti);
  $$AppelliTableTableManager get appelli =>
      $$AppelliTableTableManager(_db, _db.appelli);
  $$ImpostazioniTableTableManager get impostazioni =>
      $$ImpostazioniTableTableManager(_db, _db.impostazioni);
  $$DocumentiTableTableManager get documenti =>
      $$DocumentiTableTableManager(_db, _db.documenti);
  $$PagineTableTableManager get pagine =>
      $$PagineTableTableManager(_db, _db.pagine);
  $$CarteTableTableManager get carte =>
      $$CarteTableTableManager(_db, _db.carte);
  $$RevisioniTableTableManager get revisioni =>
      $$RevisioniTableTableManager(_db, _db.revisioni);
  $$SimulazioniTableTableManager get simulazioni =>
      $$SimulazioniTableTableManager(_db, _db.simulazioni);
  $$SessioniTableTableManager get sessioni =>
      $$SessioniTableTableManager(_db, _db.sessioni);
  $$PagineStudiateTableTableManager get pagineStudiate =>
      $$PagineStudiateTableTableManager(_db, _db.pagineStudiate);
  $$TrattiTableTableManager get tratti =>
      $$TrattiTableTableManager(_db, _db.tratti);
  $$DomandeEscluseTableTableManager get domandeEscluse =>
      $$DomandeEscluseTableTableManager(_db, _db.domandeEscluse);
}
