import 'dart:io';

import 'package:darvester/util.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DataClassName("DBGuild")
class Guilds extends Table {
  TextColumn get data => text()();
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get owner => text().nullable()();
  TextColumn get splashUrl => text().nullable()();
  TextColumn get memberCount => text()();
  TextColumn get description => text().nullable()();
  TextColumn get features => text().nullable()();
  IntColumn get premiumTier => integer()();
  IntColumn get boosts => integer().nullable()();
  DateTimeColumn get firstSeen => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("DBUser")
class Users extends Table {
  TextColumn get data => text()();
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get discriminator => text()();
  TextColumn get bio => text().nullable()();
  TextColumn get mutualGuilds => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get publicFlags => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get connectedAccounts => text().nullable()();
  TextColumn get activities => text().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get lastScanned => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get firstSeen => dateTime().nullable()();
  IntColumn get premium => integer()();
  DateTimeColumn get premiumSince => dateTime().nullable()();
  TextColumn get banner => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Guilds, Users])
class DarvesterDatabase extends _$DarvesterDatabase {
  DarvesterDatabase._privateConstructor() : super(_openConnection());
  static final DarvesterDatabase instance = DarvesterDatabase._privateConstructor();

  @override
  int get schemaVersion => 1;

  Future<List<DBUser?>> getGuildMembers(String id, int limit, int offset) {
    return (select(users)
          ..limit(limit, offset: offset)
          ..where((u) => u.mutualGuilds.like("%$id%")))
        .get();
  }

  Future<DBGuild> getGuild(String id) {
    return (select(guilds)..where((g) => g.id.isValue(id))).getSingle();
  }

  Future<List<DBGuild?>> getGuilds() {
    return select(guilds).get();
  }

  Future<DBUser> getUser(String id) {
    return (select(users)..where((u) => u.id.isValue(id))).getSingle();
  }

  Future<List<DBUser?>> getUsers({int limit = 50, int offset = 0}) {
    return (select(users)..limit(limit, offset: offset)).get();
  }

  Future<int> getTableCount(String table, {String? searchTerm}) async {
    // TODO: implement null safety
    String whereSlice = "";
    if (searchTerm?.isNotEmpty ?? false) {
      whereSlice = "WHERE data LIKE '%$searchTerm%'";
    }
    QueryRow row = await customSelect("SELECT COUNT(1) FROM $table $whereSlice").getSingle();
    return row.read("COUNT(1)");
  }

  Future upsertUser(DBUser user) async {
    if ((await getTableCount("users", searchTerm: user.id)) <= 0) {
      user = user.copyWith(firstSeen: Value(DateTime.now()));
    }
    return into(users).insertOnConflictUpdate(user);
  }

  Future upsertGuild(DBGuild guild) async {
    if ((await getTableCount("guilds", searchTerm: guild.id)) <= 0) {
      guild = guild.copyWith(firstSeen: Value(DateTime.now()));
    }
    return into(guilds).insertOnConflictUpdate(guild);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final File file;
    String databasePath = await Preferences.instance.getString("databasePath");
    if (databasePath.isEmpty) {
      final dbFolder = await getApplicationDocumentsDirectory();
      file = File(p.join(dbFolder.path, 'harvested.db'));
    } else {
      file = File(databasePath);
    }
    return NativeDatabase.createInBackground(file);
  });
}
