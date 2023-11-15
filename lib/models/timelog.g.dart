// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timelog.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTimelogCollection on Isar {
  IsarCollection<Timelog> get timelogs => this.collection();
}

const TimelogSchema = CollectionSchema(
  name: r'Timelog',
  id: 499324359271123616,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'endTime': PropertySchema(
      id: 1,
      name: r'endTime',
      type: IsarType.long,
    ),
    r'paused': PropertySchema(
      id: 2,
      name: r'paused',
      type: IsarType.bool,
    ),
    r'running': PropertySchema(
      id: 3,
      name: r'running',
      type: IsarType.bool,
    ),
    r'startTime': PropertySchema(
      id: 4,
      name: r'startTime',
      type: IsarType.long,
    )
  },
  estimateSize: _timelogEstimateSize,
  serialize: _timelogSerialize,
  deserialize: _timelogDeserialize,
  deserializeProp: _timelogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'task': LinkSchema(
      id: -4841469714701867369,
      name: r'task',
      target: r'Task',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _timelogGetId,
  getLinks: _timelogGetLinks,
  attach: _timelogAttach,
  version: '3.1.0+1',
);

int _timelogEstimateSize(
  Timelog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  return bytesCount;
}

void _timelogSerialize(
  Timelog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeLong(offsets[1], object.endTime);
  writer.writeBool(offsets[2], object.paused);
  writer.writeBool(offsets[3], object.running);
  writer.writeLong(offsets[4], object.startTime);
}

Timelog _timelogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Timelog();
  object.description = reader.readString(offsets[0]);
  object.endTime = reader.readLong(offsets[1]);
  object.id = id;
  object.paused = reader.readBool(offsets[2]);
  object.running = reader.readBool(offsets[3]);
  object.startTime = reader.readLong(offsets[4]);
  return object;
}

P _timelogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _timelogGetId(Timelog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _timelogGetLinks(Timelog object) {
  return [object.task];
}

void _timelogAttach(IsarCollection<dynamic> col, Id id, Timelog object) {
  object.id = id;
  object.task.attach(col, col.isar.collection<Task>(), r'task', id);
}

extension TimelogQueryWhereSort on QueryBuilder<Timelog, Timelog, QWhere> {
  QueryBuilder<Timelog, Timelog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TimelogQueryWhere on QueryBuilder<Timelog, Timelog, QWhereClause> {
  QueryBuilder<Timelog, Timelog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Timelog, Timelog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterWhereClause> idBetween(
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
}

extension TimelogQueryFilter
    on QueryBuilder<Timelog, Timelog, QFilterCondition> {
  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> endTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> endTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> endTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> endTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> pausedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paused',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> runningEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'running',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> startTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> startTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> startTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> startTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimelogQueryObject
    on QueryBuilder<Timelog, Timelog, QFilterCondition> {}

extension TimelogQueryLinks
    on QueryBuilder<Timelog, Timelog, QFilterCondition> {
  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> task(
      FilterQuery<Task> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'task');
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterFilterCondition> taskIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'task', 0, true, 0, true);
    });
  }
}

extension TimelogQuerySortBy on QueryBuilder<Timelog, Timelog, QSortBy> {
  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paused', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paused', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'running', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'running', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension TimelogQuerySortThenBy
    on QueryBuilder<Timelog, Timelog, QSortThenBy> {
  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paused', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paused', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'running', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'running', Sort.desc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<Timelog, Timelog, QAfterSortBy> thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension TimelogQueryWhereDistinct
    on QueryBuilder<Timelog, Timelog, QDistinct> {
  QueryBuilder<Timelog, Timelog, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Timelog, Timelog, QDistinct> distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<Timelog, Timelog, QDistinct> distinctByPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paused');
    });
  }

  QueryBuilder<Timelog, Timelog, QDistinct> distinctByRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'running');
    });
  }

  QueryBuilder<Timelog, Timelog, QDistinct> distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension TimelogQueryProperty
    on QueryBuilder<Timelog, Timelog, QQueryProperty> {
  QueryBuilder<Timelog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Timelog, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Timelog, int, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<Timelog, bool, QQueryOperations> pausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paused');
    });
  }

  QueryBuilder<Timelog, bool, QQueryOperations> runningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'running');
    });
  }

  QueryBuilder<Timelog, int, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}
