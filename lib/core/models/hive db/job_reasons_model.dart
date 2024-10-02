// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';
part 'job_reasons_model.g.dart';

@HiveType(typeId: 11)
class ReasonsDb {
  static String boxName = "reasons";

  @HiveField(0)
  String identifier;

  @HiveField(1)
  String name;

  ReasonsDb({
    required this.identifier,
    required this.name,
  });

  static Box<ReasonsDb> getBox() => Hive.box<ReasonsDb>(boxName);
}
