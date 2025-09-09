import 'package:ea_food_project/features/order/data/models/order.dart';

import 'package:hive/hive.dart';
import '../models/order.dart';

class OrderRepository {
  final Box<Order> _orderBox = Hive.box<Order>('orders');

  Future<List<Order>> getOrders() async {
    final box = await Hive.openBox<Order>('orders');
    return box.values.toList();
  }

  Future<void> addOrder(Order order) async {
    await _orderBox.add(order);
  }

  Future<void> deleteOrder(Order order) async {
    await order.delete(); // HiveObject delete
  }
}

