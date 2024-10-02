// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:hive/hive.dart';
part 'syncing_local_db.g.dart';

@HiveType(typeId: 12)
class SyncingLocalDb {
  static String boxName = "syncinglocaldb";

  @HiveField(0)
  Map<String, dynamic> payload;

  @HiveField(1)
  int generatedTime;

  @HiveField(2)
  String graphqlMethod;

  // @HiveField(3)
  // String title;

  //  @HiveField(4)
  // String title;

  

  SyncingLocalDb({
    required this.payload,
    required this.generatedTime,
    required this.graphqlMethod,
  });
}

Box<SyncingLocalDb> syncdbgetBox() =>
    Hive.box<SyncingLocalDb>(SyncingLocalDb.boxName);
