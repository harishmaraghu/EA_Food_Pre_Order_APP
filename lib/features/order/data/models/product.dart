import 'package:hive/hive.dart';



@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  int stock;

  Product({required this.id, required this.name, required this.stock});
}
