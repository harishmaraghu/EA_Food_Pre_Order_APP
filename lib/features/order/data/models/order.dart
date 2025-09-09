import 'package:hive/hive.dart';

part "Order.g.dart";

@HiveType(typeId: 0)
class Order extends HiveObject {
  @HiveField(0)
  String userType;

  @HiveField(1)
  String productName;

  @HiveField(2)
  int qty;

  @HiveField(3)
  DateTime date;

  Order({
    required this.userType,
    required this.productName,
    required this.qty,
    required this.date,
  });
}
