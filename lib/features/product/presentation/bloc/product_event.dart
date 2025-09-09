import 'package:ea_food_project/features/order/data/models/order.dart';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class IncreaseQty extends ProductEvent {
  final int index;
  final String userType;

  const IncreaseQty(this.index, this.userType);

  @override
  List<Object?> get props => [index, userType];
}

class DecreaseQty extends ProductEvent {
  final int index;

  const DecreaseQty(this.index);

  @override
  List<Object?> get props => [index];
}

class PlaceOrders extends ProductEvent {
  final String userType;

  const PlaceOrders(this.userType);

  @override
  List<Object?> get props => [userType];
}

class DeleteOrder extends ProductEvent {
  final Order order;

  const DeleteOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class LoadOrders extends ProductEvent {
  const LoadOrders();
}

class ClearCart extends ProductEvent {
  const ClearCart();
}