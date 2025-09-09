import 'package:ea_food_project/features/order/data/models/order.dart';
import 'package:equatable/equatable.dart';

class ProductState extends Equatable {
  final List<Map<String, dynamic>> products;
  final List<Order> orders;
  final bool isLoading;
  final String? error;


  const ProductState({
    required this.products,
    required this.orders,
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<Map<String, dynamic>>? products,
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [products, orders, isLoading, error];
}