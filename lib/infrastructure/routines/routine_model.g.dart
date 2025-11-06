// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoutineModelCollection on Isar {
  IsarCollection<RoutineModel> get routineModels => this.collection();
}

const RoutineModelSchema = CollectionSchema(
  name: r'RoutineModel',
  id: -1626869750065799181,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'daysOfWeek': PropertySchema(
      id: 1,
      name: r'daysOfWeek',
      type: IsarType.longList,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'exercises': PropertySchema(
      id: 3,
      name: r'exercises',
      type: IsarType.objectList,
      target: r'RoutineExerciseModel',
    ),
    r'focus': PropertySchema(
      id: 4,
      name: r'focus',
      type: IsarType.byte,
      enumMap: _RoutineModelfocusEnumValueMap,
    ),
    r'isArchived': PropertySchema(
      id: 5,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(id: 6, name: r'name', type: IsarType.string),
    r'notes': PropertySchema(id: 7, name: r'notes', type: IsarType.string),
    r'routineId': PropertySchema(
      id: 8,
      name: r'routineId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _routineModelEstimateSize,
  serialize: _routineModelSerialize,
  deserialize: _routineModelDeserialize,
  deserializeProp: _routineModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'routineId': IndexSchema(
      id: -7971259615846791236,
      name: r'routineId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'routineId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'RoutineExerciseModel': RoutineExerciseModelSchema,
    r'RoutineSetModel': RoutineSetModelSchema,
  },
  getId: _routineModelGetId,
  getLinks: _routineModelGetLinks,
  attach: _routineModelAttach,
  version: '3.1.0+1',
);

int _routineModelEstimateSize(
  RoutineModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.daysOfWeek.length * 8;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.exercises.length * 3;
  {
    final offsets = allOffsets[RoutineExerciseModel]!;
    for (var i = 0; i < object.exercises.length; i++) {
      final value = object.exercises[i];
      bytesCount += RoutineExerciseModelSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.routineId.length * 3;
  return bytesCount;
}

void _routineModelSerialize(
  RoutineModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLongList(offsets[1], object.daysOfWeek);
  writer.writeString(offsets[2], object.description);
  writer.writeObjectList<RoutineExerciseModel>(
    offsets[3],
    allOffsets,
    RoutineExerciseModelSchema.serialize,
    object.exercises,
  );
  writer.writeByte(offsets[4], object.focus.index);
  writer.writeBool(offsets[5], object.isArchived);
  writer.writeString(offsets[6], object.name);
  writer.writeString(offsets[7], object.notes);
  writer.writeString(offsets[8], object.routineId);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

RoutineModel _routineModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutineModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.daysOfWeek = reader.readLongList(offsets[1]) ?? [];
  object.description = reader.readString(offsets[2]);
  object.exercises =
      reader.readObjectList<RoutineExerciseModel>(
        offsets[3],
        RoutineExerciseModelSchema.deserialize,
        allOffsets,
        RoutineExerciseModel(),
      ) ??
      [];
  object.focus =
      _RoutineModelfocusValueEnumMap[reader.readByteOrNull(offsets[4])] ??
      RoutineFocus.fullBody;
  object.id = id;
  object.isArchived = reader.readBool(offsets[5]);
  object.name = reader.readString(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.routineId = reader.readString(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _routineModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLongList(offset) ?? []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readObjectList<RoutineExerciseModel>(
                offset,
                RoutineExerciseModelSchema.deserialize,
                allOffsets,
                RoutineExerciseModel(),
              ) ??
              [])
          as P;
    case 4:
      return (_RoutineModelfocusValueEnumMap[reader.readByteOrNull(offset)] ??
              RoutineFocus.fullBody)
          as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RoutineModelfocusEnumValueMap = {
  'fullBody': 0,
  'upperBody': 1,
  'lowerBody': 2,
  'push': 3,
  'pull': 4,
  'core': 5,
  'mobility': 6,
  'custom': 7,
};
const _RoutineModelfocusValueEnumMap = {
  0: RoutineFocus.fullBody,
  1: RoutineFocus.upperBody,
  2: RoutineFocus.lowerBody,
  3: RoutineFocus.push,
  4: RoutineFocus.pull,
  5: RoutineFocus.core,
  6: RoutineFocus.mobility,
  7: RoutineFocus.custom,
};

Id _routineModelGetId(RoutineModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _routineModelGetLinks(RoutineModel object) {
  return [];
}

void _routineModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  RoutineModel object,
) {
  object.id = id;
}

extension RoutineModelByIndex on IsarCollection<RoutineModel> {
  Future<RoutineModel?> getByRoutineId(String routineId) {
    return getByIndex(r'routineId', [routineId]);
  }

  RoutineModel? getByRoutineIdSync(String routineId) {
    return getByIndexSync(r'routineId', [routineId]);
  }

  Future<bool> deleteByRoutineId(String routineId) {
    return deleteByIndex(r'routineId', [routineId]);
  }

  bool deleteByRoutineIdSync(String routineId) {
    return deleteByIndexSync(r'routineId', [routineId]);
  }

  Future<List<RoutineModel?>> getAllByRoutineId(List<String> routineIdValues) {
    final values = routineIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'routineId', values);
  }

  List<RoutineModel?> getAllByRoutineIdSync(List<String> routineIdValues) {
    final values = routineIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'routineId', values);
  }

  Future<int> deleteAllByRoutineId(List<String> routineIdValues) {
    final values = routineIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'routineId', values);
  }

  int deleteAllByRoutineIdSync(List<String> routineIdValues) {
    final values = routineIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'routineId', values);
  }

  Future<Id> putByRoutineId(RoutineModel object) {
    return putByIndex(r'routineId', object);
  }

  Id putByRoutineIdSync(RoutineModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'routineId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRoutineId(List<RoutineModel> objects) {
    return putAllByIndex(r'routineId', objects);
  }

  List<Id> putAllByRoutineIdSync(
    List<RoutineModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'routineId', objects, saveLinks: saveLinks);
  }
}

extension RoutineModelQueryWhereSort
    on QueryBuilder<RoutineModel, RoutineModel, QWhere> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RoutineModelQueryWhere
    on QueryBuilder<RoutineModel, RoutineModel, QWhereClause> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause> routineIdEqualTo(
    String routineId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'routineId', value: [routineId]),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterWhereClause>
  routineIdNotEqualTo(String routineId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'routineId',
                lower: [],
                upper: [routineId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'routineId',
                lower: [routineId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'routineId',
                lower: [routineId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'routineId',
                lower: [],
                upper: [routineId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension RoutineModelQueryFilter
    on QueryBuilder<RoutineModel, RoutineModel, QFilterCondition> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'daysOfWeek', value: value),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'daysOfWeek',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'daysOfWeek',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'daysOfWeek',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'daysOfWeek', length, true, length, true);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'daysOfWeek', 0, true, 0, true);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'daysOfWeek', 0, false, 999999, true);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'daysOfWeek', 0, true, length, include);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'daysOfWeek', length, include, 999999, true);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  daysOfWeekLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'daysOfWeek',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  exercisesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exercises', length, true, length, true);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  exercisesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exercises', 0, true, 0, true);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  exercisesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exercises', 0, false, 999999, true);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  exercisesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exercises', 0, true, length, include);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  exercisesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exercises', length, include, 999999, true);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  exercisesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exercises',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> focusEqualTo(
    RoutineFocus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'focus', value: value),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  focusGreaterThan(RoutineFocus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'focus',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> focusLessThan(
    RoutineFocus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'focus',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> focusBetween(
    RoutineFocus lower,
    RoutineFocus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'focus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isArchived', value: value),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> notesContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition> notesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'routineId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'routineId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'routineId', value: ''),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  routineIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'routineId', value: ''),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RoutineModelQueryObject
    on QueryBuilder<RoutineModel, RoutineModel, QFilterCondition> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterFilterCondition>
  exercisesElement(FilterQuery<RoutineExerciseModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'exercises');
    });
  }
}

extension RoutineModelQueryLinks
    on QueryBuilder<RoutineModel, RoutineModel, QFilterCondition> {}

extension RoutineModelQuerySortBy
    on QueryBuilder<RoutineModel, RoutineModel, QSortBy> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focus', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focus', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy>
  sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByRoutineId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByRoutineIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RoutineModelQuerySortThenBy
    on QueryBuilder<RoutineModel, RoutineModel, QSortThenBy> {
  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focus', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focus', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy>
  thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByRoutineId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByRoutineIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.desc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RoutineModelQueryWhereDistinct
    on QueryBuilder<RoutineModel, RoutineModel, QDistinct> {
  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByDaysOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysOfWeek');
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focus');
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByRoutineId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routineId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineModel, RoutineModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension RoutineModelQueryProperty
    on QueryBuilder<RoutineModel, RoutineModel, QQueryProperty> {
  QueryBuilder<RoutineModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RoutineModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RoutineModel, List<int>, QQueryOperations> daysOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysOfWeek');
    });
  }

  QueryBuilder<RoutineModel, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<RoutineModel, List<RoutineExerciseModel>, QQueryOperations>
  exercisesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exercises');
    });
  }

  QueryBuilder<RoutineModel, RoutineFocus, QQueryOperations> focusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focus');
    });
  }

  QueryBuilder<RoutineModel, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<RoutineModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<RoutineModel, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<RoutineModel, String, QQueryOperations> routineIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routineId');
    });
  }

  QueryBuilder<RoutineModel, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoutineSessionModelCollection on Isar {
  IsarCollection<RoutineSessionModel> get routineSessionModels =>
      this.collection();
}

const RoutineSessionModelSchema = CollectionSchema(
  name: r'RoutineSessionModel',
  id: 5220665546299805429,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'exerciseLogs': PropertySchema(
      id: 1,
      name: r'exerciseLogs',
      type: IsarType.objectList,
      target: r'RoutineExerciseLogModel',
    ),
    r'notes': PropertySchema(id: 2, name: r'notes', type: IsarType.string),
    r'routineId': PropertySchema(
      id: 3,
      name: r'routineId',
      type: IsarType.string,
    ),
    r'sessionId': PropertySchema(
      id: 4,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'startedAt': PropertySchema(
      id: 5,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _routineSessionModelEstimateSize,
  serialize: _routineSessionModelSerialize,
  deserialize: _routineSessionModelDeserialize,
  deserializeProp: _routineSessionModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'RoutineExerciseLogModel': RoutineExerciseLogModelSchema,
    r'SetLogModel': SetLogModelSchema,
  },
  getId: _routineSessionModelGetId,
  getLinks: _routineSessionModelGetLinks,
  attach: _routineSessionModelAttach,
  version: '3.1.0+1',
);

int _routineSessionModelEstimateSize(
  RoutineSessionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exerciseLogs.length * 3;
  {
    final offsets = allOffsets[RoutineExerciseLogModel]!;
    for (var i = 0; i < object.exerciseLogs.length; i++) {
      final value = object.exerciseLogs[i];
      bytesCount += RoutineExerciseLogModelSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.routineId.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  return bytesCount;
}

void _routineSessionModelSerialize(
  RoutineSessionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeObjectList<RoutineExerciseLogModel>(
    offsets[1],
    allOffsets,
    RoutineExerciseLogModelSchema.serialize,
    object.exerciseLogs,
  );
  writer.writeString(offsets[2], object.notes);
  writer.writeString(offsets[3], object.routineId);
  writer.writeString(offsets[4], object.sessionId);
  writer.writeDateTime(offsets[5], object.startedAt);
}

RoutineSessionModel _routineSessionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutineSessionModel();
  object.completedAt = reader.readDateTime(offsets[0]);
  object.exerciseLogs =
      reader.readObjectList<RoutineExerciseLogModel>(
        offsets[1],
        RoutineExerciseLogModelSchema.deserialize,
        allOffsets,
        RoutineExerciseLogModel(),
      ) ??
      [];
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[2]);
  object.routineId = reader.readString(offsets[3]);
  object.sessionId = reader.readString(offsets[4]);
  object.startedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _routineSessionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readObjectList<RoutineExerciseLogModel>(
                offset,
                RoutineExerciseLogModelSchema.deserialize,
                allOffsets,
                RoutineExerciseLogModel(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _routineSessionModelGetId(RoutineSessionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _routineSessionModelGetLinks(
  RoutineSessionModel object,
) {
  return [];
}

void _routineSessionModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  RoutineSessionModel object,
) {
  object.id = id;
}

extension RoutineSessionModelByIndex on IsarCollection<RoutineSessionModel> {
  Future<RoutineSessionModel?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  RoutineSessionModel? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<RoutineSessionModel?>> getAllBySessionId(
    List<String> sessionIdValues,
  ) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<RoutineSessionModel?> getAllBySessionIdSync(
    List<String> sessionIdValues,
  ) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(RoutineSessionModel object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(RoutineSessionModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<RoutineSessionModel> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(
    List<RoutineSessionModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension RoutineSessionModelQueryWhereSort
    on QueryBuilder<RoutineSessionModel, RoutineSessionModel, QWhere> {
  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RoutineSessionModelQueryWhere
    on QueryBuilder<RoutineSessionModel, RoutineSessionModel, QWhereClause> {
  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterWhereClause>
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

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterWhereClause>
  sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sessionId', value: [sessionId]),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterWhereClause>
  sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension RoutineSessionModelQueryFilter
    on
        QueryBuilder<
          RoutineSessionModel,
          RoutineSessionModel,
          QFilterCondition
        > {
  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  completedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  completedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  completedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  completedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  exerciseLogsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exerciseLogs', length, true, length, true);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  exerciseLogsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exerciseLogs', 0, true, 0, true);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  exerciseLogsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exerciseLogs', 0, false, 999999, true);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  exerciseLogsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exerciseLogs', 0, true, length, include);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  exerciseLogsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'exerciseLogs', length, include, 999999, true);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  exerciseLogsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exerciseLogs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'routineId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'routineId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'routineId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'routineId', value: ''),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  routineIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'routineId', value: ''),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sessionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  startedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RoutineSessionModelQueryObject
    on
        QueryBuilder<
          RoutineSessionModel,
          RoutineSessionModel,
          QFilterCondition
        > {
  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterFilterCondition>
  exerciseLogsElement(FilterQuery<RoutineExerciseLogModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'exerciseLogs');
    });
  }
}

extension RoutineSessionModelQueryLinks
    on
        QueryBuilder<
          RoutineSessionModel,
          RoutineSessionModel,
          QFilterCondition
        > {}

extension RoutineSessionModelQuerySortBy
    on QueryBuilder<RoutineSessionModel, RoutineSessionModel, QSortBy> {
  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortByRoutineId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortByRoutineIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }
}

extension RoutineSessionModelQuerySortThenBy
    on QueryBuilder<RoutineSessionModel, RoutineSessionModel, QSortThenBy> {
  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByRoutineId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByRoutineIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QAfterSortBy>
  thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }
}

extension RoutineSessionModelQueryWhereDistinct
    on QueryBuilder<RoutineSessionModel, RoutineSessionModel, QDistinct> {
  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QDistinct>
  distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QDistinct>
  distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QDistinct>
  distinctByRoutineId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routineId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QDistinct>
  distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineSessionModel, RoutineSessionModel, QDistinct>
  distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }
}

extension RoutineSessionModelQueryProperty
    on QueryBuilder<RoutineSessionModel, RoutineSessionModel, QQueryProperty> {
  QueryBuilder<RoutineSessionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RoutineSessionModel, DateTime, QQueryOperations>
  completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<
    RoutineSessionModel,
    List<RoutineExerciseLogModel>,
    QQueryOperations
  >
  exerciseLogsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseLogs');
    });
  }

  QueryBuilder<RoutineSessionModel, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<RoutineSessionModel, String, QQueryOperations>
  routineIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routineId');
    });
  }

  QueryBuilder<RoutineSessionModel, String, QQueryOperations>
  sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<RoutineSessionModel, DateTime, QQueryOperations>
  startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RoutineExerciseModelSchema = Schema(
  name: r'RoutineExerciseModel',
  id: 4788570465962103432,
  properties: {
    r'equipment': PropertySchema(
      id: 0,
      name: r'equipment',
      type: IsarType.string,
    ),
    r'exerciseId': PropertySchema(
      id: 1,
      name: r'exerciseId',
      type: IsarType.string,
    ),
    r'gifUrl': PropertySchema(id: 2, name: r'gifUrl', type: IsarType.string),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
    r'notes': PropertySchema(id: 4, name: r'notes', type: IsarType.string),
    r'order': PropertySchema(id: 5, name: r'order', type: IsarType.long),
    r'sets': PropertySchema(
      id: 6,
      name: r'sets',
      type: IsarType.objectList,
      target: r'RoutineSetModel',
    ),
    r'targetMuscles': PropertySchema(
      id: 7,
      name: r'targetMuscles',
      type: IsarType.stringList,
    ),
  },
  estimateSize: _routineExerciseModelEstimateSize,
  serialize: _routineExerciseModelSerialize,
  deserialize: _routineExerciseModelDeserialize,
  deserializeProp: _routineExerciseModelDeserializeProp,
);

int _routineExerciseModelEstimateSize(
  RoutineExerciseModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.equipment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.exerciseId.length * 3;
  {
    final value = object.gifUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sets.length * 3;
  {
    final offsets = allOffsets[RoutineSetModel]!;
    for (var i = 0; i < object.sets.length; i++) {
      final value = object.sets[i];
      bytesCount += RoutineSetModelSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.targetMuscles.length * 3;
  {
    for (var i = 0; i < object.targetMuscles.length; i++) {
      final value = object.targetMuscles[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _routineExerciseModelSerialize(
  RoutineExerciseModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.equipment);
  writer.writeString(offsets[1], object.exerciseId);
  writer.writeString(offsets[2], object.gifUrl);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.notes);
  writer.writeLong(offsets[5], object.order);
  writer.writeObjectList<RoutineSetModel>(
    offsets[6],
    allOffsets,
    RoutineSetModelSchema.serialize,
    object.sets,
  );
  writer.writeStringList(offsets[7], object.targetMuscles);
}

RoutineExerciseModel _routineExerciseModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutineExerciseModel();
  object.equipment = reader.readStringOrNull(offsets[0]);
  object.exerciseId = reader.readString(offsets[1]);
  object.gifUrl = reader.readStringOrNull(offsets[2]);
  object.name = reader.readString(offsets[3]);
  object.notes = reader.readStringOrNull(offsets[4]);
  object.order = reader.readLong(offsets[5]);
  object.sets =
      reader.readObjectList<RoutineSetModel>(
        offsets[6],
        RoutineSetModelSchema.deserialize,
        allOffsets,
        RoutineSetModel(),
      ) ??
      [];
  object.targetMuscles = reader.readStringList(offsets[7]) ?? [];
  return object;
}

P _routineExerciseModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readObjectList<RoutineSetModel>(
                offset,
                RoutineSetModelSchema.deserialize,
                allOffsets,
                RoutineSetModel(),
              ) ??
              [])
          as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RoutineExerciseModelQueryFilter
    on
        QueryBuilder<
          RoutineExerciseModel,
          RoutineExerciseModel,
          QFilterCondition
        > {
  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'equipment'),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'equipment'),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'equipment',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'equipment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'equipment',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'equipment', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  equipmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'equipment', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'exerciseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'exerciseId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'exerciseId', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  exerciseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'exerciseId', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'gifUrl'),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'gifUrl'),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'gifUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gifUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gifUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gifUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'gifUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'gifUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'gifUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'gifUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gifUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  gifUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'gifUrl', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  orderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  orderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  setsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sets', length, true, length, true);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  setsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sets', 0, true, 0, true);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  setsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sets', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  setsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sets', 0, true, length, include);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  setsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sets', length, include, 999999, true);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  setsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'targetMuscles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetMuscles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetMuscles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetMuscles',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'targetMuscles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'targetMuscles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'targetMuscles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'targetMuscles',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'targetMuscles', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'targetMuscles', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'targetMuscles', length, true, length, true);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'targetMuscles', 0, true, 0, true);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'targetMuscles', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'targetMuscles', 0, true, length, include);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'targetMuscles', length, include, 999999, true);
    });
  }

  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  targetMusclesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targetMuscles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension RoutineExerciseModelQueryObject
    on
        QueryBuilder<
          RoutineExerciseModel,
          RoutineExerciseModel,
          QFilterCondition
        > {
  QueryBuilder<
    RoutineExerciseModel,
    RoutineExerciseModel,
    QAfterFilterCondition
  >
  setsElement(FilterQuery<RoutineSetModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'sets');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RoutineSetModelSchema = Schema(
  name: r'RoutineSetModel',
  id: 8571139598866977170,
  properties: {
    r'repetitions': PropertySchema(
      id: 0,
      name: r'repetitions',
      type: IsarType.long,
    ),
    r'restIntervalSeconds': PropertySchema(
      id: 1,
      name: r'restIntervalSeconds',
      type: IsarType.long,
    ),
    r'setNumber': PropertySchema(
      id: 2,
      name: r'setNumber',
      type: IsarType.long,
    ),
    r'targetWeight': PropertySchema(
      id: 3,
      name: r'targetWeight',
      type: IsarType.double,
    ),
  },
  estimateSize: _routineSetModelEstimateSize,
  serialize: _routineSetModelSerialize,
  deserialize: _routineSetModelDeserialize,
  deserializeProp: _routineSetModelDeserializeProp,
);

int _routineSetModelEstimateSize(
  RoutineSetModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _routineSetModelSerialize(
  RoutineSetModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.repetitions);
  writer.writeLong(offsets[1], object.restIntervalSeconds);
  writer.writeLong(offsets[2], object.setNumber);
  writer.writeDouble(offsets[3], object.targetWeight);
}

RoutineSetModel _routineSetModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutineSetModel();
  object.repetitions = reader.readLong(offsets[0]);
  object.restIntervalSeconds = reader.readLongOrNull(offsets[1]);
  object.setNumber = reader.readLong(offsets[2]);
  object.targetWeight = reader.readDoubleOrNull(offsets[3]);
  return object;
}

P _routineSetModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RoutineSetModelQueryFilter
    on QueryBuilder<RoutineSetModel, RoutineSetModel, QFilterCondition> {
  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  repetitionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'repetitions', value: value),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  repetitionsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'repetitions',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  repetitionsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'repetitions',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  repetitionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'repetitions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  restIntervalSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'restIntervalSeconds'),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  restIntervalSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'restIntervalSeconds'),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  restIntervalSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'restIntervalSeconds', value: value),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  restIntervalSecondsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'restIntervalSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  restIntervalSecondsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'restIntervalSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  restIntervalSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'restIntervalSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  setNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'setNumber', value: value),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  setNumberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'setNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  setNumberLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'setNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  setNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'setNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  targetWeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'targetWeight'),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  targetWeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'targetWeight'),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  targetWeightEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'targetWeight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  targetWeightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetWeight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  targetWeightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetWeight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RoutineSetModel, RoutineSetModel, QAfterFilterCondition>
  targetWeightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetWeight',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension RoutineSetModelQueryObject
    on QueryBuilder<RoutineSetModel, RoutineSetModel, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RoutineExerciseLogModelSchema = Schema(
  name: r'RoutineExerciseLogModel',
  id: -5201477238123078403,
  properties: {
    r'exerciseId': PropertySchema(
      id: 0,
      name: r'exerciseId',
      type: IsarType.string,
    ),
    r'setLogs': PropertySchema(
      id: 1,
      name: r'setLogs',
      type: IsarType.objectList,
      target: r'SetLogModel',
    ),
  },
  estimateSize: _routineExerciseLogModelEstimateSize,
  serialize: _routineExerciseLogModelSerialize,
  deserialize: _routineExerciseLogModelDeserialize,
  deserializeProp: _routineExerciseLogModelDeserializeProp,
);

int _routineExerciseLogModelEstimateSize(
  RoutineExerciseLogModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exerciseId.length * 3;
  bytesCount += 3 + object.setLogs.length * 3;
  {
    final offsets = allOffsets[SetLogModel]!;
    for (var i = 0; i < object.setLogs.length; i++) {
      final value = object.setLogs[i];
      bytesCount += SetLogModelSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _routineExerciseLogModelSerialize(
  RoutineExerciseLogModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.exerciseId);
  writer.writeObjectList<SetLogModel>(
    offsets[1],
    allOffsets,
    SetLogModelSchema.serialize,
    object.setLogs,
  );
}

RoutineExerciseLogModel _routineExerciseLogModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutineExerciseLogModel();
  object.exerciseId = reader.readString(offsets[0]);
  object.setLogs =
      reader.readObjectList<SetLogModel>(
        offsets[1],
        SetLogModelSchema.deserialize,
        allOffsets,
        SetLogModel(),
      ) ??
      [];
  return object;
}

P _routineExerciseLogModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readObjectList<SetLogModel>(
                offset,
                SetLogModelSchema.deserialize,
                allOffsets,
                SetLogModel(),
              ) ??
              [])
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RoutineExerciseLogModelQueryFilter
    on
        QueryBuilder<
          RoutineExerciseLogModel,
          RoutineExerciseLogModel,
          QFilterCondition
        > {
  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'exerciseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'exerciseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'exerciseId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'exerciseId', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  exerciseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'exerciseId', value: ''),
      );
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  setLogsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'setLogs', length, true, length, true);
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  setLogsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'setLogs', 0, true, 0, true);
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  setLogsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'setLogs', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  setLogsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'setLogs', 0, true, length, include);
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  setLogsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'setLogs', length, include, 999999, true);
    });
  }

  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  setLogsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'setLogs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension RoutineExerciseLogModelQueryObject
    on
        QueryBuilder<
          RoutineExerciseLogModel,
          RoutineExerciseLogModel,
          QFilterCondition
        > {
  QueryBuilder<
    RoutineExerciseLogModel,
    RoutineExerciseLogModel,
    QAfterFilterCondition
  >
  setLogsElement(FilterQuery<SetLogModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'setLogs');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const SetLogModelSchema = Schema(
  name: r'SetLogModel',
  id: 1765317531532529120,
  properties: {
    r'repetitions': PropertySchema(
      id: 0,
      name: r'repetitions',
      type: IsarType.long,
    ),
    r'restTakenSeconds': PropertySchema(
      id: 1,
      name: r'restTakenSeconds',
      type: IsarType.long,
    ),
    r'setNumber': PropertySchema(
      id: 2,
      name: r'setNumber',
      type: IsarType.long,
    ),
    r'weight': PropertySchema(id: 3, name: r'weight', type: IsarType.double),
  },
  estimateSize: _setLogModelEstimateSize,
  serialize: _setLogModelSerialize,
  deserialize: _setLogModelDeserialize,
  deserializeProp: _setLogModelDeserializeProp,
);

int _setLogModelEstimateSize(
  SetLogModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _setLogModelSerialize(
  SetLogModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.repetitions);
  writer.writeLong(offsets[1], object.restTakenSeconds);
  writer.writeLong(offsets[2], object.setNumber);
  writer.writeDouble(offsets[3], object.weight);
}

SetLogModel _setLogModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SetLogModel();
  object.repetitions = reader.readLong(offsets[0]);
  object.restTakenSeconds = reader.readLong(offsets[1]);
  object.setNumber = reader.readLong(offsets[2]);
  object.weight = reader.readDouble(offsets[3]);
  return object;
}

P _setLogModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension SetLogModelQueryFilter
    on QueryBuilder<SetLogModel, SetLogModel, QFilterCondition> {
  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  repetitionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'repetitions', value: value),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  repetitionsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'repetitions',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  repetitionsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'repetitions',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  repetitionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'repetitions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  restTakenSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'restTakenSeconds', value: value),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  restTakenSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'restTakenSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  restTakenSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'restTakenSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  restTakenSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'restTakenSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  setNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'setNumber', value: value),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  setNumberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'setNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  setNumberLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'setNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  setNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'setNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition> weightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition>
  weightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition> weightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SetLogModel, SetLogModel, QAfterFilterCondition> weightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weight',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension SetLogModelQueryObject
    on QueryBuilder<SetLogModel, SetLogModel, QFilterCondition> {}
