// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBodyMetricModelCollection on Isar {
  IsarCollection<BodyMetricModel> get bodyMetricModels => this.collection();
}

const BodyMetricModelSchema = CollectionSchema(
  name: r'BodyMetricModel',
  id: -4944497039782937235,
  properties: {
    r'bodyFatPercentage': PropertySchema(
      id: 0,
      name: r'bodyFatPercentage',
      type: IsarType.double,
    ),
    r'measurementKeys': PropertySchema(
      id: 1,
      name: r'measurementKeys',
      type: IsarType.stringList,
    ),
    r'measurementValues': PropertySchema(
      id: 2,
      name: r'measurementValues',
      type: IsarType.doubleList,
    ),
    r'metricId': PropertySchema(
      id: 3,
      name: r'metricId',
      type: IsarType.string,
    ),
    r'muscleMassKg': PropertySchema(
      id: 4,
      name: r'muscleMassKg',
      type: IsarType.double,
    ),
    r'notes': PropertySchema(
      id: 5,
      name: r'notes',
      type: IsarType.string,
    ),
    r'recordedAt': PropertySchema(
      id: 6,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'weightKg': PropertySchema(
      id: 7,
      name: r'weightKg',
      type: IsarType.double,
    )
  },
  estimateSize: _bodyMetricModelEstimateSize,
  serialize: _bodyMetricModelSerialize,
  deserialize: _bodyMetricModelDeserialize,
  deserializeProp: _bodyMetricModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'metricId': IndexSchema(
      id: -1685298009092058112,
      name: r'metricId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'metricId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'recordedAt': IndexSchema(
      id: -5046025352082009396,
      name: r'recordedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recordedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bodyMetricModelGetId,
  getLinks: _bodyMetricModelGetLinks,
  attach: _bodyMetricModelAttach,
  version: '3.1.0+1',
);

int _bodyMetricModelEstimateSize(
  BodyMetricModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.measurementKeys.length * 3;
  {
    for (var i = 0; i < object.measurementKeys.length; i++) {
      final value = object.measurementKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.measurementValues.length * 8;
  bytesCount += 3 + object.metricId.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _bodyMetricModelSerialize(
  BodyMetricModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bodyFatPercentage);
  writer.writeStringList(offsets[1], object.measurementKeys);
  writer.writeDoubleList(offsets[2], object.measurementValues);
  writer.writeString(offsets[3], object.metricId);
  writer.writeDouble(offsets[4], object.muscleMassKg);
  writer.writeString(offsets[5], object.notes);
  writer.writeDateTime(offsets[6], object.recordedAt);
  writer.writeDouble(offsets[7], object.weightKg);
}

BodyMetricModel _bodyMetricModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BodyMetricModel();
  object.bodyFatPercentage = reader.readDoubleOrNull(offsets[0]);
  object.id = id;
  object.measurementKeys = reader.readStringList(offsets[1]) ?? [];
  object.measurementValues = reader.readDoubleList(offsets[2]) ?? [];
  object.metricId = reader.readString(offsets[3]);
  object.muscleMassKg = reader.readDoubleOrNull(offsets[4]);
  object.notes = reader.readStringOrNull(offsets[5]);
  object.recordedAt = reader.readDateTime(offsets[6]);
  object.weightKg = reader.readDouble(offsets[7]);
  return object;
}

P _bodyMetricModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bodyMetricModelGetId(BodyMetricModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bodyMetricModelGetLinks(BodyMetricModel object) {
  return [];
}

void _bodyMetricModelAttach(
    IsarCollection<dynamic> col, Id id, BodyMetricModel object) {
  object.id = id;
}

extension BodyMetricModelByIndex on IsarCollection<BodyMetricModel> {
  Future<BodyMetricModel?> getByMetricId(String metricId) {
    return getByIndex(r'metricId', [metricId]);
  }

  BodyMetricModel? getByMetricIdSync(String metricId) {
    return getByIndexSync(r'metricId', [metricId]);
  }

  Future<bool> deleteByMetricId(String metricId) {
    return deleteByIndex(r'metricId', [metricId]);
  }

  bool deleteByMetricIdSync(String metricId) {
    return deleteByIndexSync(r'metricId', [metricId]);
  }

  Future<List<BodyMetricModel?>> getAllByMetricId(List<String> metricIdValues) {
    final values = metricIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'metricId', values);
  }

  List<BodyMetricModel?> getAllByMetricIdSync(List<String> metricIdValues) {
    final values = metricIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'metricId', values);
  }

  Future<int> deleteAllByMetricId(List<String> metricIdValues) {
    final values = metricIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'metricId', values);
  }

  int deleteAllByMetricIdSync(List<String> metricIdValues) {
    final values = metricIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'metricId', values);
  }

  Future<Id> putByMetricId(BodyMetricModel object) {
    return putByIndex(r'metricId', object);
  }

  Id putByMetricIdSync(BodyMetricModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'metricId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMetricId(List<BodyMetricModel> objects) {
    return putAllByIndex(r'metricId', objects);
  }

  List<Id> putAllByMetricIdSync(List<BodyMetricModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'metricId', objects, saveLinks: saveLinks);
  }
}

extension BodyMetricModelQueryWhereSort
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QWhere> {
  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhere> anyRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'recordedAt'),
      );
    });
  }
}

extension BodyMetricModelQueryWhere
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QWhereClause> {
  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      metricIdEqualTo(String metricId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'metricId',
        value: [metricId],
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      metricIdNotEqualTo(String metricId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'metricId',
              lower: [],
              upper: [metricId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'metricId',
              lower: [metricId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'metricId',
              lower: [metricId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'metricId',
              lower: [],
              upper: [metricId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      recordedAtEqualTo(DateTime recordedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordedAt',
        value: [recordedAt],
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      recordedAtNotEqualTo(DateTime recordedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [],
              upper: [recordedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [recordedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [recordedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [],
              upper: [recordedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      recordedAtGreaterThan(
    DateTime recordedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [recordedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      recordedAtLessThan(
    DateTime recordedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [],
        upper: [recordedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterWhereClause>
      recordedAtBetween(
    DateTime lowerRecordedAt,
    DateTime upperRecordedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [lowerRecordedAt],
        includeLower: includeLower,
        upper: [upperRecordedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BodyMetricModelQueryFilter
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QFilterCondition> {
  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      bodyFatPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bodyFatPercentage',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      bodyFatPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bodyFatPercentage',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      bodyFatPercentageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyFatPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      bodyFatPercentageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodyFatPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      bodyFatPercentageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodyFatPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      bodyFatPercentageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodyFatPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'measurementKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'measurementKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'measurementKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'measurementKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'measurementKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'measurementKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'measurementKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'measurementKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'measurementKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'measurementKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'measurementValues',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'measurementValues',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'measurementValues',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'measurementValues',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementValues',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementValues',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementValues',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementValues',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementValues',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      measurementValuesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'measurementValues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metricId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metricId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metricId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metricId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metricId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metricId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metricId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metricId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metricId',
        value: '',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      metricIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metricId',
        value: '',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      muscleMassKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'muscleMassKg',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      muscleMassKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'muscleMassKg',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      muscleMassKgEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'muscleMassKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      muscleMassKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'muscleMassKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      muscleMassKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'muscleMassKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      muscleMassKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'muscleMassKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      recordedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      recordedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      recordedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      weightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      weightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      weightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterFilterCondition>
      weightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension BodyMetricModelQueryObject
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QFilterCondition> {}

extension BodyMetricModelQueryLinks
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QFilterCondition> {}

extension BodyMetricModelQuerySortBy
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QSortBy> {
  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByBodyFatPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPercentage', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByBodyFatPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPercentage', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByMetricId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metricId', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByMetricIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metricId', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByMuscleMassKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'muscleMassKg', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByMuscleMassKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'muscleMassKg', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension BodyMetricModelQuerySortThenBy
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QSortThenBy> {
  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByBodyFatPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPercentage', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByBodyFatPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPercentage', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByMetricId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metricId', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByMetricIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metricId', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByMuscleMassKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'muscleMassKg', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByMuscleMassKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'muscleMassKg', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QAfterSortBy>
      thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension BodyMetricModelQueryWhereDistinct
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct> {
  QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct>
      distinctByBodyFatPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyFatPercentage');
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct>
      distinctByMeasurementKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'measurementKeys');
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct>
      distinctByMeasurementValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'measurementValues');
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct> distinctByMetricId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metricId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct>
      distinctByMuscleMassKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'muscleMassKg');
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct>
      distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<BodyMetricModel, BodyMetricModel, QDistinct>
      distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension BodyMetricModelQueryProperty
    on QueryBuilder<BodyMetricModel, BodyMetricModel, QQueryProperty> {
  QueryBuilder<BodyMetricModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BodyMetricModel, double?, QQueryOperations>
      bodyFatPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyFatPercentage');
    });
  }

  QueryBuilder<BodyMetricModel, List<String>, QQueryOperations>
      measurementKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'measurementKeys');
    });
  }

  QueryBuilder<BodyMetricModel, List<double>, QQueryOperations>
      measurementValuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'measurementValues');
    });
  }

  QueryBuilder<BodyMetricModel, String, QQueryOperations> metricIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metricId');
    });
  }

  QueryBuilder<BodyMetricModel, double?, QQueryOperations>
      muscleMassKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'muscleMassKg');
    });
  }

  QueryBuilder<BodyMetricModel, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<BodyMetricModel, DateTime, QQueryOperations>
      recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<BodyMetricModel, double, QQueryOperations> weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMetabolicProfileModelCollection on Isar {
  IsarCollection<MetabolicProfileModel> get metabolicProfileModels =>
      this.collection();
}

const MetabolicProfileModelSchema = CollectionSchema(
  name: r'MetabolicProfileModel',
  id: 3543348471053641572,
  properties: {
    r'activityMultiplier': PropertySchema(
      id: 0,
      name: r'activityMultiplier',
      type: IsarType.double,
    ),
    r'age': PropertySchema(
      id: 1,
      name: r'age',
      type: IsarType.long,
    ),
    r'heightCm': PropertySchema(
      id: 2,
      name: r'heightCm',
      type: IsarType.double,
    ),
    r'profileId': PropertySchema(
      id: 3,
      name: r'profileId',
      type: IsarType.string,
    ),
    r'sex': PropertySchema(
      id: 4,
      name: r'sex',
      type: IsarType.byte,
      enumMap: _MetabolicProfileModelsexEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weightKg': PropertySchema(
      id: 6,
      name: r'weightKg',
      type: IsarType.double,
    )
  },
  estimateSize: _metabolicProfileModelEstimateSize,
  serialize: _metabolicProfileModelSerialize,
  deserialize: _metabolicProfileModelDeserialize,
  deserializeProp: _metabolicProfileModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'profileId': IndexSchema(
      id: 6052971939042612300,
      name: r'profileId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'profileId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _metabolicProfileModelGetId,
  getLinks: _metabolicProfileModelGetLinks,
  attach: _metabolicProfileModelAttach,
  version: '3.1.0+1',
);

int _metabolicProfileModelEstimateSize(
  MetabolicProfileModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.profileId.length * 3;
  return bytesCount;
}

void _metabolicProfileModelSerialize(
  MetabolicProfileModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.activityMultiplier);
  writer.writeLong(offsets[1], object.age);
  writer.writeDouble(offsets[2], object.heightCm);
  writer.writeString(offsets[3], object.profileId);
  writer.writeByte(offsets[4], object.sex.index);
  writer.writeDateTime(offsets[5], object.updatedAt);
  writer.writeDouble(offsets[6], object.weightKg);
}

MetabolicProfileModel _metabolicProfileModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MetabolicProfileModel();
  object.activityMultiplier = reader.readDouble(offsets[0]);
  object.age = reader.readLong(offsets[1]);
  object.heightCm = reader.readDouble(offsets[2]);
  object.id = id;
  object.profileId = reader.readString(offsets[3]);
  object.sex = _MetabolicProfileModelsexValueEnumMap[
          reader.readByteOrNull(offsets[4])] ??
      BiologicalSex.male;
  object.updatedAt = reader.readDateTime(offsets[5]);
  object.weightKg = reader.readDouble(offsets[6]);
  return object;
}

P _metabolicProfileModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_MetabolicProfileModelsexValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BiologicalSex.male) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MetabolicProfileModelsexEnumValueMap = {
  'male': 0,
  'female': 1,
  'other': 2,
};
const _MetabolicProfileModelsexValueEnumMap = {
  0: BiologicalSex.male,
  1: BiologicalSex.female,
  2: BiologicalSex.other,
};

Id _metabolicProfileModelGetId(MetabolicProfileModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _metabolicProfileModelGetLinks(
    MetabolicProfileModel object) {
  return [];
}

void _metabolicProfileModelAttach(
    IsarCollection<dynamic> col, Id id, MetabolicProfileModel object) {
  object.id = id;
}

extension MetabolicProfileModelByIndex
    on IsarCollection<MetabolicProfileModel> {
  Future<MetabolicProfileModel?> getByProfileId(String profileId) {
    return getByIndex(r'profileId', [profileId]);
  }

  MetabolicProfileModel? getByProfileIdSync(String profileId) {
    return getByIndexSync(r'profileId', [profileId]);
  }

  Future<bool> deleteByProfileId(String profileId) {
    return deleteByIndex(r'profileId', [profileId]);
  }

  bool deleteByProfileIdSync(String profileId) {
    return deleteByIndexSync(r'profileId', [profileId]);
  }

  Future<List<MetabolicProfileModel?>> getAllByProfileId(
      List<String> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'profileId', values);
  }

  List<MetabolicProfileModel?> getAllByProfileIdSync(
      List<String> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'profileId', values);
  }

  Future<int> deleteAllByProfileId(List<String> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'profileId', values);
  }

  int deleteAllByProfileIdSync(List<String> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'profileId', values);
  }

  Future<Id> putByProfileId(MetabolicProfileModel object) {
    return putByIndex(r'profileId', object);
  }

  Id putByProfileIdSync(MetabolicProfileModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'profileId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProfileId(List<MetabolicProfileModel> objects) {
    return putAllByIndex(r'profileId', objects);
  }

  List<Id> putAllByProfileIdSync(List<MetabolicProfileModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'profileId', objects, saveLinks: saveLinks);
  }
}

extension MetabolicProfileModelQueryWhereSort
    on QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QWhere> {
  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MetabolicProfileModelQueryWhere on QueryBuilder<MetabolicProfileModel,
    MetabolicProfileModel, QWhereClause> {
  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterWhereClause>
      profileIdEqualTo(String profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterWhereClause>
      profileIdNotEqualTo(String profileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MetabolicProfileModelQueryFilter on QueryBuilder<
    MetabolicProfileModel, MetabolicProfileModel, QFilterCondition> {
  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> activityMultiplierEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> activityMultiplierGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> activityMultiplierLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> activityMultiplierBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityMultiplier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> ageEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> ageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> ageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> ageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'age',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> heightCmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> heightCmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> heightCmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> heightCmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heightCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> profileIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> profileIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> profileIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> profileIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'profileId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> profileIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> profileIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
          QAfterFilterCondition>
      profileIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'profileId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
          QAfterFilterCondition>
      profileIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'profileId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> profileIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: '',
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> profileIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'profileId',
        value: '',
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> sexEqualTo(BiologicalSex value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sex',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> sexGreaterThan(
    BiologicalSex value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sex',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> sexLessThan(
    BiologicalSex value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sex',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> sexBetween(
    BiologicalSex lower,
    BiologicalSex upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> weightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> weightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> weightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel,
      QAfterFilterCondition> weightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension MetabolicProfileModelQueryObject on QueryBuilder<
    MetabolicProfileModel, MetabolicProfileModel, QFilterCondition> {}

extension MetabolicProfileModelQueryLinks on QueryBuilder<MetabolicProfileModel,
    MetabolicProfileModel, QFilterCondition> {}

extension MetabolicProfileModelQuerySortBy
    on QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QSortBy> {
  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByActivityMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityMultiplier', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByActivityMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityMultiplier', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortBySexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension MetabolicProfileModelQuerySortThenBy
    on QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QSortThenBy> {
  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByActivityMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityMultiplier', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByActivityMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityMultiplier', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenBySexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QAfterSortBy>
      thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension MetabolicProfileModelQueryWhereDistinct
    on QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QDistinct> {
  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QDistinct>
      distinctByActivityMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityMultiplier');
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QDistinct>
      distinctByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'age');
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QDistinct>
      distinctByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heightCm');
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QDistinct>
      distinctByProfileId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QDistinct>
      distinctBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sex');
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MetabolicProfileModel, MetabolicProfileModel, QDistinct>
      distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension MetabolicProfileModelQueryProperty on QueryBuilder<
    MetabolicProfileModel, MetabolicProfileModel, QQueryProperty> {
  QueryBuilder<MetabolicProfileModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MetabolicProfileModel, double, QQueryOperations>
      activityMultiplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityMultiplier');
    });
  }

  QueryBuilder<MetabolicProfileModel, int, QQueryOperations> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'age');
    });
  }

  QueryBuilder<MetabolicProfileModel, double, QQueryOperations>
      heightCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heightCm');
    });
  }

  QueryBuilder<MetabolicProfileModel, String, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MetabolicProfileModel, BiologicalSex, QQueryOperations>
      sexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sex');
    });
  }

  QueryBuilder<MetabolicProfileModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MetabolicProfileModel, double, QQueryOperations>
      weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}
