// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_file_entity.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetSavedFileEntityCollection on Isar {
  IsarCollection<int, SavedFileEntity> get savedFiles => this.collection();
}

final SavedFileEntitySchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SavedFileEntity',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'fileId', type: IsarType.string),
      IsarPropertySchema(name: 'name', type: IsarType.string),
      IsarPropertySchema(name: 'dateTime', type: IsarType.string),
      IsarPropertySchema(name: 'path', type: IsarType.string),
      IsarPropertySchema(name: 'pathImage', type: IsarType.string),
      IsarPropertySchema(name: 'fileType', type: IsarType.string),
      IsarPropertySchema(name: 'folderId', type: IsarType.string),
      IsarPropertySchema(name: 'isTextFile', type: IsarType.bool),
      IsarPropertySchema(name: 'contactJson', type: IsarType.string),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'fileId',
        properties: ["fileId"],
        unique: true,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'folderId',
        properties: ["folderId"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, SavedFileEntity>(
    serialize: serializeSavedFileEntity,
    deserialize: deserializeSavedFileEntity,
    deserializeProperty: deserializeSavedFileEntityProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeSavedFileEntity(IsarWriter writer, SavedFileEntity object) {
  IsarCore.writeString(writer, 1, object.fileId);
  IsarCore.writeString(writer, 2, object.name);
  IsarCore.writeString(writer, 3, object.dateTime);
  IsarCore.writeString(writer, 4, object.path);
  IsarCore.writeString(writer, 5, object.pathImage);
  IsarCore.writeString(writer, 6, object.fileType);
  IsarCore.writeString(writer, 7, object.folderId);
  IsarCore.writeBool(writer, 8, value: object.isTextFile);
  IsarCore.writeString(writer, 9, object.contactJson);
  return object.id;
}

@isarProtected
SavedFileEntity deserializeSavedFileEntity(IsarReader reader) {
  final object = SavedFileEntity();
  object.id = IsarCore.readId(reader);
  object.fileId = IsarCore.readString(reader, 1) ?? '';
  object.name = IsarCore.readString(reader, 2) ?? '';
  object.dateTime = IsarCore.readString(reader, 3) ?? '';
  object.path = IsarCore.readString(reader, 4) ?? '';
  object.pathImage = IsarCore.readString(reader, 5) ?? '';
  object.fileType = IsarCore.readString(reader, 6) ?? '';
  object.folderId = IsarCore.readString(reader, 7) ?? '';
  object.isTextFile = IsarCore.readBool(reader, 8);
  object.contactJson = IsarCore.readString(reader, 9) ?? '';
  return object;
}

@isarProtected
dynamic deserializeSavedFileEntityProp(IsarReader reader, int property) {
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
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    case 6:
      return IsarCore.readString(reader, 6) ?? '';
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
    case 8:
      return IsarCore.readBool(reader, 8);
    case 9:
      return IsarCore.readString(reader, 9) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _SavedFileEntityUpdate {
  bool call({
    required int id,
    String? fileId,
    String? name,
    String? dateTime,
    String? path,
    String? pathImage,
    String? fileType,
    String? folderId,
    bool? isTextFile,
    String? contactJson,
  });
}

class _SavedFileEntityUpdateImpl implements _SavedFileEntityUpdate {
  const _SavedFileEntityUpdateImpl(this.collection);

  final IsarCollection<int, SavedFileEntity> collection;

  @override
  bool call({
    required int id,
    Object? fileId = ignore,
    Object? name = ignore,
    Object? dateTime = ignore,
    Object? path = ignore,
    Object? pathImage = ignore,
    Object? fileType = ignore,
    Object? folderId = ignore,
    Object? isTextFile = ignore,
    Object? contactJson = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (fileId != ignore) 1: fileId as String?,
            if (name != ignore) 2: name as String?,
            if (dateTime != ignore) 3: dateTime as String?,
            if (path != ignore) 4: path as String?,
            if (pathImage != ignore) 5: pathImage as String?,
            if (fileType != ignore) 6: fileType as String?,
            if (folderId != ignore) 7: folderId as String?,
            if (isTextFile != ignore) 8: isTextFile as bool?,
            if (contactJson != ignore) 9: contactJson as String?,
          },
        ) >
        0;
  }
}

sealed class _SavedFileEntityUpdateAll {
  int call({
    required List<int> id,
    String? fileId,
    String? name,
    String? dateTime,
    String? path,
    String? pathImage,
    String? fileType,
    String? folderId,
    bool? isTextFile,
    String? contactJson,
  });
}

class _SavedFileEntityUpdateAllImpl implements _SavedFileEntityUpdateAll {
  const _SavedFileEntityUpdateAllImpl(this.collection);

  final IsarCollection<int, SavedFileEntity> collection;

  @override
  int call({
    required List<int> id,
    Object? fileId = ignore,
    Object? name = ignore,
    Object? dateTime = ignore,
    Object? path = ignore,
    Object? pathImage = ignore,
    Object? fileType = ignore,
    Object? folderId = ignore,
    Object? isTextFile = ignore,
    Object? contactJson = ignore,
  }) {
    return collection.updateProperties(id, {
      if (fileId != ignore) 1: fileId as String?,
      if (name != ignore) 2: name as String?,
      if (dateTime != ignore) 3: dateTime as String?,
      if (path != ignore) 4: path as String?,
      if (pathImage != ignore) 5: pathImage as String?,
      if (fileType != ignore) 6: fileType as String?,
      if (folderId != ignore) 7: folderId as String?,
      if (isTextFile != ignore) 8: isTextFile as bool?,
      if (contactJson != ignore) 9: contactJson as String?,
    });
  }
}

extension SavedFileEntityUpdate on IsarCollection<int, SavedFileEntity> {
  _SavedFileEntityUpdate get update => _SavedFileEntityUpdateImpl(this);

  _SavedFileEntityUpdateAll get updateAll =>
      _SavedFileEntityUpdateAllImpl(this);
}

sealed class _SavedFileEntityQueryUpdate {
  int call({
    String? fileId,
    String? name,
    String? dateTime,
    String? path,
    String? pathImage,
    String? fileType,
    String? folderId,
    bool? isTextFile,
    String? contactJson,
  });
}

class _SavedFileEntityQueryUpdateImpl implements _SavedFileEntityQueryUpdate {
  const _SavedFileEntityQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<SavedFileEntity> query;
  final int? limit;

  @override
  int call({
    Object? fileId = ignore,
    Object? name = ignore,
    Object? dateTime = ignore,
    Object? path = ignore,
    Object? pathImage = ignore,
    Object? fileType = ignore,
    Object? folderId = ignore,
    Object? isTextFile = ignore,
    Object? contactJson = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (fileId != ignore) 1: fileId as String?,
      if (name != ignore) 2: name as String?,
      if (dateTime != ignore) 3: dateTime as String?,
      if (path != ignore) 4: path as String?,
      if (pathImage != ignore) 5: pathImage as String?,
      if (fileType != ignore) 6: fileType as String?,
      if (folderId != ignore) 7: folderId as String?,
      if (isTextFile != ignore) 8: isTextFile as bool?,
      if (contactJson != ignore) 9: contactJson as String?,
    });
  }
}

extension SavedFileEntityQueryUpdate on IsarQuery<SavedFileEntity> {
  _SavedFileEntityQueryUpdate get updateFirst =>
      _SavedFileEntityQueryUpdateImpl(this, limit: 1);

  _SavedFileEntityQueryUpdate get updateAll =>
      _SavedFileEntityQueryUpdateImpl(this);
}

class _SavedFileEntityQueryBuilderUpdateImpl
    implements _SavedFileEntityQueryUpdate {
  const _SavedFileEntityQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<SavedFileEntity, SavedFileEntity, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? fileId = ignore,
    Object? name = ignore,
    Object? dateTime = ignore,
    Object? path = ignore,
    Object? pathImage = ignore,
    Object? fileType = ignore,
    Object? folderId = ignore,
    Object? isTextFile = ignore,
    Object? contactJson = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (fileId != ignore) 1: fileId as String?,
        if (name != ignore) 2: name as String?,
        if (dateTime != ignore) 3: dateTime as String?,
        if (path != ignore) 4: path as String?,
        if (pathImage != ignore) 5: pathImage as String?,
        if (fileType != ignore) 6: fileType as String?,
        if (folderId != ignore) 7: folderId as String?,
        if (isTextFile != ignore) 8: isTextFile as bool?,
        if (contactJson != ignore) 9: contactJson as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension SavedFileEntityQueryBuilderUpdate
    on QueryBuilder<SavedFileEntity, SavedFileEntity, QOperations> {
  _SavedFileEntityQueryUpdate get updateFirst =>
      _SavedFileEntityQueryBuilderUpdateImpl(this, limit: 1);

  _SavedFileEntityQueryUpdate get updateAll =>
      _SavedFileEntityQueryBuilderUpdateImpl(this);
}

extension SavedFileEntityQueryFilter
    on QueryBuilder<SavedFileEntity, SavedFileEntity, QFilterCondition> {
  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  idGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  idLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  idBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdBetween(String lower, String upper, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  nameLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  nameBetween(String lower, String upper, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  dateTimeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  dateTimeLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  dateTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  dateTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathBetween(String lower, String upper, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  pathImageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  fileTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  folderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  isTextFileEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 9,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 9, value: ''),
      );
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterFilterCondition>
  contactJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 9, value: ''),
      );
    });
  }
}

extension SavedFileEntityQueryObject
    on QueryBuilder<SavedFileEntity, SavedFileEntity, QFilterCondition> {}

extension SavedFileEntityQuerySortBy
    on QueryBuilder<SavedFileEntity, SavedFileEntity, QSortBy> {
  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByFileId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByFileIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByDateTime({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByDateTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByPathDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByPathImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByPathImageDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByFileType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByFileTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> sortByFolderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByFolderIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByIsTextFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByIsTextFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByContactJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  sortByContactJsonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension SavedFileEntityQuerySortThenBy
    on QueryBuilder<SavedFileEntity, SavedFileEntity, QSortThenBy> {
  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByFileId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByFileIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByDateTime({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByDateTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByPathDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByPathImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByPathImageDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByFileType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByFileTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy> thenByFolderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByFolderIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByIsTextFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByIsTextFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByContactJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterSortBy>
  thenByContactJsonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension SavedFileEntityQueryWhereDistinct
    on QueryBuilder<SavedFileEntity, SavedFileEntity, QDistinct> {
  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByFileId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByDateTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByPathImage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByFileType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByFolderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByIsTextFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<SavedFileEntity, SavedFileEntity, QAfterDistinct>
  distinctByContactJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9, caseSensitive: caseSensitive);
    });
  }
}

extension SavedFileEntityQueryProperty1
    on QueryBuilder<SavedFileEntity, SavedFileEntity, QProperty> {
  QueryBuilder<SavedFileEntity, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SavedFileEntity, String, QAfterProperty> fileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SavedFileEntity, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SavedFileEntity, String, QAfterProperty> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SavedFileEntity, String, QAfterProperty> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SavedFileEntity, String, QAfterProperty> pathImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SavedFileEntity, String, QAfterProperty> fileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SavedFileEntity, String, QAfterProperty> folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SavedFileEntity, bool, QAfterProperty> isTextFileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<SavedFileEntity, String, QAfterProperty> contactJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}

extension SavedFileEntityQueryProperty2<R>
    on QueryBuilder<SavedFileEntity, R, QAfterProperty> {
  QueryBuilder<SavedFileEntity, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SavedFileEntity, (R, String), QAfterProperty> fileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SavedFileEntity, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SavedFileEntity, (R, String), QAfterProperty>
  dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SavedFileEntity, (R, String), QAfterProperty> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SavedFileEntity, (R, String), QAfterProperty>
  pathImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SavedFileEntity, (R, String), QAfterProperty>
  fileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SavedFileEntity, (R, String), QAfterProperty>
  folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SavedFileEntity, (R, bool), QAfterProperty>
  isTextFileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<SavedFileEntity, (R, String), QAfterProperty>
  contactJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}

extension SavedFileEntityQueryProperty3<R1, R2>
    on QueryBuilder<SavedFileEntity, (R1, R2), QAfterProperty> {
  QueryBuilder<SavedFileEntity, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, String), QOperations>
  fileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, String), QOperations>
  dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, String), QOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, String), QOperations>
  pathImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, String), QOperations>
  fileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, String), QOperations>
  folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, bool), QOperations>
  isTextFileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<SavedFileEntity, (R1, R2, String), QOperations>
  contactJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}
