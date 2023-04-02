// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GuildsTable extends Guilds with TableInfo<$GuildsTable, DBGuild> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuildsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>('data', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>('icon', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>('owner', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _splashUrlMeta = const VerificationMeta('splashUrl');
  @override
  late final GeneratedColumn<String> splashUrl =
      GeneratedColumn<String>('splash_url', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _memberCountMeta = const VerificationMeta('memberCount');
  @override
  late final GeneratedColumn<String> memberCount =
      GeneratedColumn<String>('member_count', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description =
      GeneratedColumn<String>('description', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _featuresMeta = const VerificationMeta('features');
  @override
  late final GeneratedColumn<String> features = GeneratedColumn<String>('features', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _premiumTierMeta = const VerificationMeta('premiumTier');
  @override
  late final GeneratedColumn<int> premiumTier = GeneratedColumn<int>('premium_tier', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _boostsMeta = const VerificationMeta('boosts');
  @override
  late final GeneratedColumn<int> boosts = GeneratedColumn<int>('boosts', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _firstSeenMeta = const VerificationMeta('firstSeen');
  @override
  late final GeneratedColumn<DateTime> firstSeen =
      GeneratedColumn<DateTime>('first_seen', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [data, id, name, icon, owner, splashUrl, memberCount, description, features, premiumTier, boosts, firstSeen];
  @override
  String get aliasedName => _alias ?? 'guilds';
  @override
  String get actualTableName => 'guilds';
  @override
  VerificationContext validateIntegrity(Insertable<DBGuild> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('data')) {
      context.handle(_dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(_iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('owner')) {
      context.handle(_ownerMeta, owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta));
    }
    if (data.containsKey('splash_url')) {
      context.handle(_splashUrlMeta, splashUrl.isAcceptableOrUnknown(data['splash_url']!, _splashUrlMeta));
    }
    if (data.containsKey('member_count')) {
      context.handle(_memberCountMeta, memberCount.isAcceptableOrUnknown(data['member_count']!, _memberCountMeta));
    } else if (isInserting) {
      context.missing(_memberCountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    }
    if (data.containsKey('features')) {
      context.handle(_featuresMeta, features.isAcceptableOrUnknown(data['features']!, _featuresMeta));
    }
    if (data.containsKey('premium_tier')) {
      context.handle(_premiumTierMeta, premiumTier.isAcceptableOrUnknown(data['premium_tier']!, _premiumTierMeta));
    } else if (isInserting) {
      context.missing(_premiumTierMeta);
    }
    if (data.containsKey('boosts')) {
      context.handle(_boostsMeta, boosts.isAcceptableOrUnknown(data['boosts']!, _boostsMeta));
    }
    if (data.containsKey('first_seen')) {
      context.handle(_firstSeenMeta, firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBGuild map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBGuild(
      data: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}icon']),
      owner: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}owner']),
      splashUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}splash_url']),
      memberCount: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}member_count'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description']),
      features: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}features']),
      premiumTier: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}premium_tier'])!,
      boosts: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}boosts']),
      firstSeen: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}first_seen']),
    );
  }

  @override
  $GuildsTable createAlias(String alias) {
    return $GuildsTable(attachedDatabase, alias);
  }
}

class DBGuild extends DataClass implements Insertable<DBGuild> {
  final String data;
  final String id;
  final String name;
  final String? icon;
  final String? owner;
  final String? splashUrl;
  final String memberCount;
  final String? description;
  final String? features;
  final int premiumTier;
  final int? boosts;
  final DateTime? firstSeen;
  const DBGuild(
      {required this.data,
      required this.id,
      required this.name,
      this.icon,
      this.owner,
      this.splashUrl,
      required this.memberCount,
      this.description,
      this.features,
      required this.premiumTier,
      this.boosts,
      this.firstSeen});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data'] = Variable<String>(data);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || owner != null) {
      map['owner'] = Variable<String>(owner);
    }
    if (!nullToAbsent || splashUrl != null) {
      map['splash_url'] = Variable<String>(splashUrl);
    }
    map['member_count'] = Variable<String>(memberCount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || features != null) {
      map['features'] = Variable<String>(features);
    }
    map['premium_tier'] = Variable<int>(premiumTier);
    if (!nullToAbsent || boosts != null) {
      map['boosts'] = Variable<int>(boosts);
    }
    if (!nullToAbsent || firstSeen != null) {
      map['first_seen'] = Variable<DateTime>(firstSeen);
    }
    return map;
  }

  GuildsCompanion toCompanion(bool nullToAbsent) {
    return GuildsCompanion(
      data: Value(data),
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      owner: owner == null && nullToAbsent ? const Value.absent() : Value(owner),
      splashUrl: splashUrl == null && nullToAbsent ? const Value.absent() : Value(splashUrl),
      memberCount: Value(memberCount),
      description: description == null && nullToAbsent ? const Value.absent() : Value(description),
      features: features == null && nullToAbsent ? const Value.absent() : Value(features),
      premiumTier: Value(premiumTier),
      boosts: boosts == null && nullToAbsent ? const Value.absent() : Value(boosts),
      firstSeen: firstSeen == null && nullToAbsent ? const Value.absent() : Value(firstSeen),
    );
  }

  factory DBGuild.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBGuild(
      data: serializer.fromJson<String>(json['data']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      owner: serializer.fromJson<String?>(json['owner']),
      splashUrl: serializer.fromJson<String?>(json['splashUrl']),
      memberCount: serializer.fromJson<String>(json['memberCount']),
      description: serializer.fromJson<String?>(json['description']),
      features: serializer.fromJson<String?>(json['features']),
      premiumTier: serializer.fromJson<int>(json['premiumTier']),
      boosts: serializer.fromJson<int?>(json['boosts']),
      firstSeen: serializer.fromJson<DateTime?>(json['firstSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'data': serializer.toJson<String>(data),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'owner': serializer.toJson<String?>(owner),
      'splashUrl': serializer.toJson<String?>(splashUrl),
      'memberCount': serializer.toJson<String>(memberCount),
      'description': serializer.toJson<String?>(description),
      'features': serializer.toJson<String?>(features),
      'premiumTier': serializer.toJson<int>(premiumTier),
      'boosts': serializer.toJson<int?>(boosts),
      'firstSeen': serializer.toJson<DateTime?>(firstSeen),
    };
  }

  DBGuild copyWith(
          {String? data,
          String? id,
          String? name,
          Value<String?> icon = const Value.absent(),
          Value<String?> owner = const Value.absent(),
          Value<String?> splashUrl = const Value.absent(),
          String? memberCount,
          Value<String?> description = const Value.absent(),
          Value<String?> features = const Value.absent(),
          int? premiumTier,
          Value<int?> boosts = const Value.absent(),
          Value<DateTime?> firstSeen = const Value.absent()}) =>
      DBGuild(
        data: data ?? this.data,
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon.present ? icon.value : this.icon,
        owner: owner.present ? owner.value : this.owner,
        splashUrl: splashUrl.present ? splashUrl.value : this.splashUrl,
        memberCount: memberCount ?? this.memberCount,
        description: description.present ? description.value : this.description,
        features: features.present ? features.value : this.features,
        premiumTier: premiumTier ?? this.premiumTier,
        boosts: boosts.present ? boosts.value : this.boosts,
        firstSeen: firstSeen.present ? firstSeen.value : this.firstSeen,
      );
  @override
  String toString() {
    return (StringBuffer('DBGuild(')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('owner: $owner, ')
          ..write('splashUrl: $splashUrl, ')
          ..write('memberCount: $memberCount, ')
          ..write('description: $description, ')
          ..write('features: $features, ')
          ..write('premiumTier: $premiumTier, ')
          ..write('boosts: $boosts, ')
          ..write('firstSeen: $firstSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(data, id, name, icon, owner, splashUrl, memberCount, description, features, premiumTier, boosts, firstSeen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBGuild &&
          other.data == this.data &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.owner == this.owner &&
          other.splashUrl == this.splashUrl &&
          other.memberCount == this.memberCount &&
          other.description == this.description &&
          other.features == this.features &&
          other.premiumTier == this.premiumTier &&
          other.boosts == this.boosts &&
          other.firstSeen == this.firstSeen);
}

class GuildsCompanion extends UpdateCompanion<DBGuild> {
  final Value<String> data;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> owner;
  final Value<String?> splashUrl;
  final Value<String> memberCount;
  final Value<String?> description;
  final Value<String?> features;
  final Value<int> premiumTier;
  final Value<int?> boosts;
  final Value<DateTime?> firstSeen;
  final Value<int> rowid;
  const GuildsCompanion({
    this.data = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.owner = const Value.absent(),
    this.splashUrl = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.description = const Value.absent(),
    this.features = const Value.absent(),
    this.premiumTier = const Value.absent(),
    this.boosts = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuildsCompanion.insert({
    required String data,
    required String id,
    required String name,
    this.icon = const Value.absent(),
    this.owner = const Value.absent(),
    this.splashUrl = const Value.absent(),
    required String memberCount,
    this.description = const Value.absent(),
    this.features = const Value.absent(),
    required int premiumTier,
    this.boosts = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : data = Value(data),
        id = Value(id),
        name = Value(name),
        memberCount = Value(memberCount),
        premiumTier = Value(premiumTier);
  static Insertable<DBGuild> custom({
    Expression<String>? data,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? owner,
    Expression<String>? splashUrl,
    Expression<String>? memberCount,
    Expression<String>? description,
    Expression<String>? features,
    Expression<int>? premiumTier,
    Expression<int>? boosts,
    Expression<DateTime>? firstSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (data != null) 'data': data,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (owner != null) 'owner': owner,
      if (splashUrl != null) 'splash_url': splashUrl,
      if (memberCount != null) 'member_count': memberCount,
      if (description != null) 'description': description,
      if (features != null) 'features': features,
      if (premiumTier != null) 'premium_tier': premiumTier,
      if (boosts != null) 'boosts': boosts,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuildsCompanion copyWith(
      {Value<String>? data,
      Value<String>? id,
      Value<String>? name,
      Value<String?>? icon,
      Value<String?>? owner,
      Value<String?>? splashUrl,
      Value<String>? memberCount,
      Value<String?>? description,
      Value<String?>? features,
      Value<int>? premiumTier,
      Value<int?>? boosts,
      Value<DateTime?>? firstSeen,
      Value<int>? rowid}) {
    return GuildsCompanion(
      data: data ?? this.data,
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      owner: owner ?? this.owner,
      splashUrl: splashUrl ?? this.splashUrl,
      memberCount: memberCount ?? this.memberCount,
      description: description ?? this.description,
      features: features ?? this.features,
      premiumTier: premiumTier ?? this.premiumTier,
      boosts: boosts ?? this.boosts,
      firstSeen: firstSeen ?? this.firstSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (splashUrl.present) {
      map['splash_url'] = Variable<String>(splashUrl.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<String>(memberCount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (features.present) {
      map['features'] = Variable<String>(features.value);
    }
    if (premiumTier.present) {
      map['premium_tier'] = Variable<int>(premiumTier.value);
    }
    if (boosts.present) {
      map['boosts'] = Variable<int>(boosts.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<DateTime>(firstSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuildsCompanion(')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('owner: $owner, ')
          ..write('splashUrl: $splashUrl, ')
          ..write('memberCount: $memberCount, ')
          ..write('description: $description, ')
          ..write('features: $features, ')
          ..write('premiumTier: $premiumTier, ')
          ..write('boosts: $boosts, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, DBUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>('data', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _discriminatorMeta = const VerificationMeta('discriminator');
  @override
  late final GeneratedColumn<String> discriminator =
      GeneratedColumn<String>('discriminator', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>('bio', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mutualGuildsMeta = const VerificationMeta('mutualGuilds');
  @override
  late final GeneratedColumn<String> mutualGuilds =
      GeneratedColumn<String>('mutual_guilds', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl =
      GeneratedColumn<String>('avatar_url', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publicFlagsMeta = const VerificationMeta('publicFlags');
  @override
  late final GeneratedColumn<String> publicFlags =
      GeneratedColumn<String>('public_flags', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt =
      GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _connectedAccountsMeta = const VerificationMeta('connectedAccounts');
  @override
  late final GeneratedColumn<String> connectedAccounts =
      GeneratedColumn<String>('connected_accounts', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activitiesMeta = const VerificationMeta('activities');
  @override
  late final GeneratedColumn<String> activities =
      GeneratedColumn<String>('activities', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>('status', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastScannedMeta = const VerificationMeta('lastScanned');
  @override
  late final GeneratedColumn<DateTime> lastScanned = GeneratedColumn<DateTime>('last_scanned', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: false, clientDefault: () => DateTime.now());
  static const VerificationMeta _firstSeenMeta = const VerificationMeta('firstSeen');
  @override
  late final GeneratedColumn<DateTime> firstSeen =
      GeneratedColumn<DateTime>('first_seen', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _premiumMeta = const VerificationMeta('premium');
  @override
  late final GeneratedColumn<int> premium = GeneratedColumn<int>('premium', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _premiumSinceMeta = const VerificationMeta('premiumSince');
  @override
  late final GeneratedColumn<DateTime> premiumSince =
      GeneratedColumn<DateTime>('premium_since', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _bannerMeta = const VerificationMeta('banner');
  @override
  late final GeneratedColumn<String> banner = GeneratedColumn<String>('banner', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        data,
        id,
        name,
        discriminator,
        bio,
        mutualGuilds,
        avatarUrl,
        publicFlags,
        createdAt,
        connectedAccounts,
        activities,
        status,
        lastScanned,
        firstSeen,
        premium,
        premiumSince,
        banner
      ];
  @override
  String get aliasedName => _alias ?? 'users';
  @override
  String get actualTableName => 'users';
  @override
  VerificationContext validateIntegrity(Insertable<DBUser> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('data')) {
      context.handle(_dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('discriminator')) {
      context.handle(_discriminatorMeta, discriminator.isAcceptableOrUnknown(data['discriminator']!, _discriminatorMeta));
    } else if (isInserting) {
      context.missing(_discriminatorMeta);
    }
    if (data.containsKey('bio')) {
      context.handle(_bioMeta, bio.isAcceptableOrUnknown(data['bio']!, _bioMeta));
    }
    if (data.containsKey('mutual_guilds')) {
      context.handle(_mutualGuildsMeta, mutualGuilds.isAcceptableOrUnknown(data['mutual_guilds']!, _mutualGuildsMeta));
    } else if (isInserting) {
      context.missing(_mutualGuildsMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta, avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('public_flags')) {
      context.handle(_publicFlagsMeta, publicFlags.isAcceptableOrUnknown(data['public_flags']!, _publicFlagsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('connected_accounts')) {
      context.handle(_connectedAccountsMeta, connectedAccounts.isAcceptableOrUnknown(data['connected_accounts']!, _connectedAccountsMeta));
    }
    if (data.containsKey('activities')) {
      context.handle(_activitiesMeta, activities.isAcceptableOrUnknown(data['activities']!, _activitiesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_scanned')) {
      context.handle(_lastScannedMeta, lastScanned.isAcceptableOrUnknown(data['last_scanned']!, _lastScannedMeta));
    }
    if (data.containsKey('first_seen')) {
      context.handle(_firstSeenMeta, firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta));
    }
    if (data.containsKey('premium')) {
      context.handle(_premiumMeta, premium.isAcceptableOrUnknown(data['premium']!, _premiumMeta));
    } else if (isInserting) {
      context.missing(_premiumMeta);
    }
    if (data.containsKey('premium_since')) {
      context.handle(_premiumSinceMeta, premiumSince.isAcceptableOrUnknown(data['premium_since']!, _premiumSinceMeta));
    }
    if (data.containsKey('banner')) {
      context.handle(_bannerMeta, banner.isAcceptableOrUnknown(data['banner']!, _bannerMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBUser(
      data: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      discriminator: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}discriminator'])!,
      bio: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}bio']),
      mutualGuilds: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}mutual_guilds'])!,
      avatarUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      publicFlags: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}public_flags']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      connectedAccounts: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}connected_accounts']),
      activities: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}activities']),
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status']),
      lastScanned: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}last_scanned'])!,
      firstSeen: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}first_seen']),
      premium: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}premium'])!,
      premiumSince: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}premium_since']),
      banner: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}banner']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class DBUser extends DataClass implements Insertable<DBUser> {
  final String data;
  final String id;
  final String name;
  final String discriminator;
  final String? bio;
  final String mutualGuilds;
  final String? avatarUrl;
  final String? publicFlags;
  final DateTime createdAt;
  final String? connectedAccounts;
  final String? activities;
  final String? status;
  final DateTime lastScanned;
  final DateTime? firstSeen;
  final int premium;
  final DateTime? premiumSince;
  final String? banner;
  const DBUser(
      {required this.data,
      required this.id,
      required this.name,
      required this.discriminator,
      this.bio,
      required this.mutualGuilds,
      this.avatarUrl,
      this.publicFlags,
      required this.createdAt,
      this.connectedAccounts,
      this.activities,
      this.status,
      required this.lastScanned,
      this.firstSeen,
      required this.premium,
      this.premiumSince,
      this.banner});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data'] = Variable<String>(data);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['discriminator'] = Variable<String>(discriminator);
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    map['mutual_guilds'] = Variable<String>(mutualGuilds);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || publicFlags != null) {
      map['public_flags'] = Variable<String>(publicFlags);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || connectedAccounts != null) {
      map['connected_accounts'] = Variable<String>(connectedAccounts);
    }
    if (!nullToAbsent || activities != null) {
      map['activities'] = Variable<String>(activities);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['last_scanned'] = Variable<DateTime>(lastScanned);
    if (!nullToAbsent || firstSeen != null) {
      map['first_seen'] = Variable<DateTime>(firstSeen);
    }
    map['premium'] = Variable<int>(premium);
    if (!nullToAbsent || premiumSince != null) {
      map['premium_since'] = Variable<DateTime>(premiumSince);
    }
    if (!nullToAbsent || banner != null) {
      map['banner'] = Variable<String>(banner);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      data: Value(data),
      id: Value(id),
      name: Value(name),
      discriminator: Value(discriminator),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      mutualGuilds: Value(mutualGuilds),
      avatarUrl: avatarUrl == null && nullToAbsent ? const Value.absent() : Value(avatarUrl),
      publicFlags: publicFlags == null && nullToAbsent ? const Value.absent() : Value(publicFlags),
      createdAt: Value(createdAt),
      connectedAccounts: connectedAccounts == null && nullToAbsent ? const Value.absent() : Value(connectedAccounts),
      activities: activities == null && nullToAbsent ? const Value.absent() : Value(activities),
      status: status == null && nullToAbsent ? const Value.absent() : Value(status),
      lastScanned: Value(lastScanned),
      firstSeen: firstSeen == null && nullToAbsent ? const Value.absent() : Value(firstSeen),
      premium: Value(premium),
      premiumSince: premiumSince == null && nullToAbsent ? const Value.absent() : Value(premiumSince),
      banner: banner == null && nullToAbsent ? const Value.absent() : Value(banner),
    );
  }

  factory DBUser.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBUser(
      data: serializer.fromJson<String>(json['data']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      discriminator: serializer.fromJson<String>(json['discriminator']),
      bio: serializer.fromJson<String?>(json['bio']),
      mutualGuilds: serializer.fromJson<String>(json['mutualGuilds']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      publicFlags: serializer.fromJson<String?>(json['publicFlags']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      connectedAccounts: serializer.fromJson<String?>(json['connectedAccounts']),
      activities: serializer.fromJson<String?>(json['activities']),
      status: serializer.fromJson<String?>(json['status']),
      lastScanned: serializer.fromJson<DateTime>(json['lastScanned']),
      firstSeen: serializer.fromJson<DateTime?>(json['firstSeen']),
      premium: serializer.fromJson<int>(json['premium']),
      premiumSince: serializer.fromJson<DateTime?>(json['premiumSince']),
      banner: serializer.fromJson<String?>(json['banner']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'data': serializer.toJson<String>(data),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'discriminator': serializer.toJson<String>(discriminator),
      'bio': serializer.toJson<String?>(bio),
      'mutualGuilds': serializer.toJson<String>(mutualGuilds),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'publicFlags': serializer.toJson<String?>(publicFlags),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'connectedAccounts': serializer.toJson<String?>(connectedAccounts),
      'activities': serializer.toJson<String?>(activities),
      'status': serializer.toJson<String?>(status),
      'lastScanned': serializer.toJson<DateTime>(lastScanned),
      'firstSeen': serializer.toJson<DateTime?>(firstSeen),
      'premium': serializer.toJson<int>(premium),
      'premiumSince': serializer.toJson<DateTime?>(premiumSince),
      'banner': serializer.toJson<String?>(banner),
    };
  }

  DBUser copyWith(
          {String? data,
          String? id,
          String? name,
          String? discriminator,
          Value<String?> bio = const Value.absent(),
          String? mutualGuilds,
          Value<String?> avatarUrl = const Value.absent(),
          Value<String?> publicFlags = const Value.absent(),
          DateTime? createdAt,
          Value<String?> connectedAccounts = const Value.absent(),
          Value<String?> activities = const Value.absent(),
          Value<String?> status = const Value.absent(),
          DateTime? lastScanned,
          Value<DateTime?> firstSeen = const Value.absent(),
          int? premium,
          Value<DateTime?> premiumSince = const Value.absent(),
          Value<String?> banner = const Value.absent()}) =>
      DBUser(
        data: data ?? this.data,
        id: id ?? this.id,
        name: name ?? this.name,
        discriminator: discriminator ?? this.discriminator,
        bio: bio.present ? bio.value : this.bio,
        mutualGuilds: mutualGuilds ?? this.mutualGuilds,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        publicFlags: publicFlags.present ? publicFlags.value : this.publicFlags,
        createdAt: createdAt ?? this.createdAt,
        connectedAccounts: connectedAccounts.present ? connectedAccounts.value : this.connectedAccounts,
        activities: activities.present ? activities.value : this.activities,
        status: status.present ? status.value : this.status,
        lastScanned: lastScanned ?? this.lastScanned,
        firstSeen: firstSeen.present ? firstSeen.value : this.firstSeen,
        premium: premium ?? this.premium,
        premiumSince: premiumSince.present ? premiumSince.value : this.premiumSince,
        banner: banner.present ? banner.value : this.banner,
      );
  @override
  String toString() {
    return (StringBuffer('DBUser(')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('discriminator: $discriminator, ')
          ..write('bio: $bio, ')
          ..write('mutualGuilds: $mutualGuilds, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('publicFlags: $publicFlags, ')
          ..write('createdAt: $createdAt, ')
          ..write('connectedAccounts: $connectedAccounts, ')
          ..write('activities: $activities, ')
          ..write('status: $status, ')
          ..write('lastScanned: $lastScanned, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('premium: $premium, ')
          ..write('premiumSince: $premiumSince, ')
          ..write('banner: $banner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(data, id, name, discriminator, bio, mutualGuilds, avatarUrl, publicFlags, createdAt, connectedAccounts, activities, status,
      lastScanned, firstSeen, premium, premiumSince, banner);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBUser &&
          other.data == this.data &&
          other.id == this.id &&
          other.name == this.name &&
          other.discriminator == this.discriminator &&
          other.bio == this.bio &&
          other.mutualGuilds == this.mutualGuilds &&
          other.avatarUrl == this.avatarUrl &&
          other.publicFlags == this.publicFlags &&
          other.createdAt == this.createdAt &&
          other.connectedAccounts == this.connectedAccounts &&
          other.activities == this.activities &&
          other.status == this.status &&
          other.lastScanned == this.lastScanned &&
          other.firstSeen == this.firstSeen &&
          other.premium == this.premium &&
          other.premiumSince == this.premiumSince &&
          other.banner == this.banner);
}

class UsersCompanion extends UpdateCompanion<DBUser> {
  final Value<String> data;
  final Value<String> id;
  final Value<String> name;
  final Value<String> discriminator;
  final Value<String?> bio;
  final Value<String> mutualGuilds;
  final Value<String?> avatarUrl;
  final Value<String?> publicFlags;
  final Value<DateTime> createdAt;
  final Value<String?> connectedAccounts;
  final Value<String?> activities;
  final Value<String?> status;
  final Value<DateTime> lastScanned;
  final Value<DateTime?> firstSeen;
  final Value<int> premium;
  final Value<DateTime?> premiumSince;
  final Value<String?> banner;
  final Value<int> rowid;
  const UsersCompanion({
    this.data = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.discriminator = const Value.absent(),
    this.bio = const Value.absent(),
    this.mutualGuilds = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.publicFlags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.connectedAccounts = const Value.absent(),
    this.activities = const Value.absent(),
    this.status = const Value.absent(),
    this.lastScanned = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.premium = const Value.absent(),
    this.premiumSince = const Value.absent(),
    this.banner = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String data,
    required String id,
    required String name,
    required String discriminator,
    this.bio = const Value.absent(),
    required String mutualGuilds,
    this.avatarUrl = const Value.absent(),
    this.publicFlags = const Value.absent(),
    required DateTime createdAt,
    this.connectedAccounts = const Value.absent(),
    this.activities = const Value.absent(),
    this.status = const Value.absent(),
    this.lastScanned = const Value.absent(),
    this.firstSeen = const Value.absent(),
    required int premium,
    this.premiumSince = const Value.absent(),
    this.banner = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : data = Value(data),
        id = Value(id),
        name = Value(name),
        discriminator = Value(discriminator),
        mutualGuilds = Value(mutualGuilds),
        createdAt = Value(createdAt),
        premium = Value(premium);
  static Insertable<DBUser> custom({
    Expression<String>? data,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? discriminator,
    Expression<String>? bio,
    Expression<String>? mutualGuilds,
    Expression<String>? avatarUrl,
    Expression<String>? publicFlags,
    Expression<DateTime>? createdAt,
    Expression<String>? connectedAccounts,
    Expression<String>? activities,
    Expression<String>? status,
    Expression<DateTime>? lastScanned,
    Expression<DateTime>? firstSeen,
    Expression<int>? premium,
    Expression<DateTime>? premiumSince,
    Expression<String>? banner,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (data != null) 'data': data,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (discriminator != null) 'discriminator': discriminator,
      if (bio != null) 'bio': bio,
      if (mutualGuilds != null) 'mutual_guilds': mutualGuilds,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (publicFlags != null) 'public_flags': publicFlags,
      if (createdAt != null) 'created_at': createdAt,
      if (connectedAccounts != null) 'connected_accounts': connectedAccounts,
      if (activities != null) 'activities': activities,
      if (status != null) 'status': status,
      if (lastScanned != null) 'last_scanned': lastScanned,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (premium != null) 'premium': premium,
      if (premiumSince != null) 'premium_since': premiumSince,
      if (banner != null) 'banner': banner,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? data,
      Value<String>? id,
      Value<String>? name,
      Value<String>? discriminator,
      Value<String?>? bio,
      Value<String>? mutualGuilds,
      Value<String?>? avatarUrl,
      Value<String?>? publicFlags,
      Value<DateTime>? createdAt,
      Value<String?>? connectedAccounts,
      Value<String?>? activities,
      Value<String?>? status,
      Value<DateTime>? lastScanned,
      Value<DateTime?>? firstSeen,
      Value<int>? premium,
      Value<DateTime?>? premiumSince,
      Value<String?>? banner,
      Value<int>? rowid}) {
    return UsersCompanion(
      data: data ?? this.data,
      id: id ?? this.id,
      name: name ?? this.name,
      discriminator: discriminator ?? this.discriminator,
      bio: bio ?? this.bio,
      mutualGuilds: mutualGuilds ?? this.mutualGuilds,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      publicFlags: publicFlags ?? this.publicFlags,
      createdAt: createdAt ?? this.createdAt,
      connectedAccounts: connectedAccounts ?? this.connectedAccounts,
      activities: activities ?? this.activities,
      status: status ?? this.status,
      lastScanned: lastScanned ?? this.lastScanned,
      firstSeen: firstSeen ?? this.firstSeen,
      premium: premium ?? this.premium,
      premiumSince: premiumSince ?? this.premiumSince,
      banner: banner ?? this.banner,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (discriminator.present) {
      map['discriminator'] = Variable<String>(discriminator.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (mutualGuilds.present) {
      map['mutual_guilds'] = Variable<String>(mutualGuilds.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (publicFlags.present) {
      map['public_flags'] = Variable<String>(publicFlags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (connectedAccounts.present) {
      map['connected_accounts'] = Variable<String>(connectedAccounts.value);
    }
    if (activities.present) {
      map['activities'] = Variable<String>(activities.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastScanned.present) {
      map['last_scanned'] = Variable<DateTime>(lastScanned.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<DateTime>(firstSeen.value);
    }
    if (premium.present) {
      map['premium'] = Variable<int>(premium.value);
    }
    if (premiumSince.present) {
      map['premium_since'] = Variable<DateTime>(premiumSince.value);
    }
    if (banner.present) {
      map['banner'] = Variable<String>(banner.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('data: $data, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('discriminator: $discriminator, ')
          ..write('bio: $bio, ')
          ..write('mutualGuilds: $mutualGuilds, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('publicFlags: $publicFlags, ')
          ..write('createdAt: $createdAt, ')
          ..write('connectedAccounts: $connectedAccounts, ')
          ..write('activities: $activities, ')
          ..write('status: $status, ')
          ..write('lastScanned: $lastScanned, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('premium: $premium, ')
          ..write('premiumSince: $premiumSince, ')
          ..write('banner: $banner, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DarvesterDatabase extends GeneratedDatabase {
  _$DarvesterDatabase(QueryExecutor e) : super(e);
  late final $GuildsTable guilds = $GuildsTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [guilds, users];
}
