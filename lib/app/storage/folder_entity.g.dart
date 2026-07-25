// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_entity.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetFolderEntityCollection on Isar {
  IsarCollection<int, FolderEntity> get folders => this.collection();
}

final FolderEntitySchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'FolderEntity',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'folderId', type: IsarType.string),
      IsarPropertySchema(name: 'name', type: IsarType.string),
      IsarPropertySchema(name: 'dateTime', type: IsarType.string),
      IsarPropertySchema(name: 'parentFolderId', type: IsarType.string),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'folderId',
        properties: ["folderId"],
        unique: true,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'parentFolderId',
        properties: ["parentFolderId"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, FolderEntity>(
    serialize: serializeFolderEntity,
    deserialize: deserializeFolderEntity,
    deserializeProperty: deserializeFolderEntityProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeFolderEntity(IsarWriter writer, FolderEntity object) {
  IsarCore.writeString(writer, 1, object.folderId);
  IsarCore.writeString(writer, 2, object.name);
  IsarCore.writeString(writer, 3, object.dateTime);
  IsarCore.writeString(writer, 4, object.parentFolderId);
  return object.id;
}

@isarProtected
FolderEntity deserializeFolderEntity(IsarReader reader) {
  final object = FolderEntity();
  object.id = IsarCore.readId(reader);
  object.folderId = IsarCore.readString(reader, 1) ?? '';
  object.name = IsarCore.readString(reader, 2) ?? '';
  object.dateTime = IsarCore.readString(reader, 3) ?? '';
  object.parentFolderId = IsarCore.readString(reader, 4) ?? '';
  return object;
}

@isarProtected
dynamic deserializeFolderEntityProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _FolderEntityUpdate {
  bool call({
    required int id,
    String? folderId,
    String? name,
    String? dateTime,
    String? parentFolderId,
  });
}

class _FolderEntityUpdateImpl implements _FolderEntityUpdate {
  const _FolderEntityUpdateImpl(this.collection);

  final IsarCollection<int, FolderEntity> collection;

  @override
  bool call({
    required int id,
    Object? folderId = ignore,
    Object? name = ignore,
    Object? dateTime = ignore,
    Object? parentFolderId = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (folderId != ignore) 1: folderId as String?,
            if (name != ignore) 2: name as String?,
            if (dateTime != ignore) 3: dateTime as String?,
            if (parentFolderId != ignore) 4: parentFolderId as String?,
          },
        ) >
        0;
  }
}

sealed class _FolderEntityUpdateAll {
  int call({
    required List<int> id,
    String? folderId,
    String? name,
    String? dateTime,
    String? parentFolderId,
  });
}

class _FolderEntityUpdateAllImpl implements _FolderEntityUpdateAll {
  const _FolderEntityUpdateAllImpl(this.collection);

  final IsarCollection<int, FolderEntity> collection;

  @override
  int call({
    required List<int> id,
    Object? folderId = ignore,
    Object? name = ignore,
    Object? dateTime = ignore,
    Object? parentFolderId = ignore,
  }) {
    return collection.updateProperties(id, {
      if (folderId != ignore) 1: folderId as String?,
      if (name != ignore) 2: name as String?,
      if (dateTime != ignore) 3: dateTime as String?,
      if (parentFolderId != ignore) 4: parentFolderId as String?,
    });
  }
}

extension FolderEntityUpdate on IsarCollection<int, FolderEntity> {
  _FolderEntityUpdate get update => _FolderEntityUpdateImpl(this);

  _FolderEntityUpdateAll get updateAll => _FolderEntityUpdateAllImpl(this);
}

sealed class _FolderEntityQueryUpdate {
  int call({
    String? folderId,
    String? name,
    String? dateTime,
    String? parentFolderId,
  });
}

class _FolderEntityQueryUpdateImpl implements _FolderEntityQueryUpdate {
  const _FolderEntityQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<FolderEntity> query;
  final int? limit;

  @override
  int call({
    Object? folderId = ignore,
    Object? name = ignore,
    Object? dateTime = ignore,
    Object? parentFolderId = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (folderId != ignore) 1: folderId as String?,
      if (name != ignore) 2: name as String?,
      if (dateTime != ignore) 3: dateTime as String?,
      if (parentFolderId != ignore) 4: parentFolderId as String?,
    });
  }
}

extension FolderEntityQueryUpdate on IsarQuery<FolderEntity> {
  _FolderEntityQueryUpdate get updateFirst =>
      _FolderEntityQueryUpdateImpl(this, limit: 1);

  _FolderEntityQueryUpdate get updateAll => _FolderEntityQueryUpdateImpl(this);
}

class _FolderEntityQueryBuilderUpdateImpl implements _FolderEntityQueryUpdate {
  const _FolderEntityQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<FolderEntity, FolderEntity, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? folderId = ignore,
    Object? name = ignore,
    Object? dateTime = ignore,
    Object? parentFolderId = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (folderId != ignore) 1: folderId as String?,
        if (name != ignore) 2: name as String?,
        if (dateTime != ignore) 3: dateTime as String?,
        if (parentFolderId != ignore) 4: parentFolderId as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension FolderEntityQueryBuilderUpdate
    on QueryBuilder<FolderEntity, FolderEntity, QOperations> {
  _FolderEntityQueryUpdate get updateFirst =>
      _FolderEntityQueryBuilderUpdateImpl(this, limit: 1);

  _FolderEntityQueryUpdate get updateAll =>
      _FolderEntityQueryBuilderUpdateImpl(this);
}

extension FolderEntityQueryFilter
    on QueryBuilder<FolderEntity, FolderEntity, QFilterCondition> {
  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  folderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  nameGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  nameGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> nameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  nameLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  dateTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterFilterCondition>
  parentFolderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 4, value: ''),
      );
    });
  }
}

extension FolderEntityQueryObject
    on QueryBuilder<FolderEntity, FolderEntity, QFilterCondition> {}

extension FolderEntityQuerySortBy
    on QueryBuilder<FolderEntity, FolderEntity, QSortBy> {
  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortByFolderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortByFolderIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortByDateTime({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortByDateTimeDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> sortByParentFolderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy>
  sortByParentFolderIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension FolderEntityQuerySortThenBy
    on QueryBuilder<FolderEntity, FolderEntity, QSortThenBy> {
  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenByFolderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenByFolderIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenByDateTime({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenByDateTimeDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy> thenByParentFolderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterSortBy>
  thenByParentFolderIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension FolderEntityQueryWhereDistinct
    on QueryBuilder<FolderEntity, FolderEntity, QDistinct> {
  QueryBuilder<FolderEntity, FolderEntity, QAfterDistinct> distinctByFolderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterDistinct> distinctByDateTime({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FolderEntity, FolderEntity, QAfterDistinct>
  distinctByParentFolderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }
}

extension FolderEntityQueryProperty1
    on QueryBuilder<FolderEntity, FolderEntity, QProperty> {
  QueryBuilder<FolderEntity, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FolderEntity, String, QAfterProperty> folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FolderEntity, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FolderEntity, String, QAfterProperty> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FolderEntity, String, QAfterProperty> parentFolderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension FolderEntityQueryProperty2<R>
    on QueryBuilder<FolderEntity, R, QAfterProperty> {
  QueryBuilder<FolderEntity, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FolderEntity, (R, String), QAfterProperty> folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FolderEntity, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FolderEntity, (R, String), QAfterProperty> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FolderEntity, (R, String), QAfterProperty>
  parentFolderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension FolderEntityQueryProperty3<R1, R2>
    on QueryBuilder<FolderEntity, (R1, R2), QAfterProperty> {
  QueryBuilder<FolderEntity, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FolderEntity, (R1, R2, String), QOperations> folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FolderEntity, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FolderEntity, (R1, R2, String), QOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FolderEntity, (R1, R2, String), QOperations>
  parentFolderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}
