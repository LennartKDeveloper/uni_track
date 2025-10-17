import 'package:hive/hive.dart';
part 'hive_modul.g.dart';

@HiveType(typeId: 0)
enum Importance {
  @HiveField(0)
  red,
  @HiveField(1)
  yellow,
  @HiveField(2)
  green,
}

@HiveType(typeId: 1)
class Module extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String link;

  Module({required this.name, this.link = ''});
}
