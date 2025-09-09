// product_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:ea_food_project/features/order/data/repositories/OrderRepository.dart';
import '../../../order/data/models/order.dart';
import '../../../order/presentation/role_limit.dart';
import '../../../order/presentation/roleselectionscreen.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final OrderRepository orderRepository = OrderRepository();

  ProductBloc() : super(ProductState(
    products: [
      {"id": "1", "name": "Milk", "originalStock": 1000, "stock": 1000, "qty": 0, "unit": "L"},
      {"id": "2", "name": "Bread", "originalStock": 500, "stock": 500, "qty": 0, "unit": "packets"},
      {"id": "3", "name": "Rice", "originalStock": 2000, "stock": 2000, "qty": 0, "unit": "kg"},
      {"id": "4", "name": "Oil", "originalStock": 500, "stock": 500, "qty": 0, "unit": "L"},
    ],
    orders: [],
  )) {
    on<LoadOrders>(_onLoadOrders);
    on<IncreaseQty>(_onIncreaseQty);
    on<DecreaseQty>(_onDecreaseQty);
    on<PlaceOrders>(_onPlaceOrders);
    on<DeleteOrder>(_onDeleteOrder);
    on<ClearCart>(_onClearCart);

    // Load orders when bloc is created
    add(const LoadOrders());
  }

  void _onLoadOrders(LoadOrders event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final orders = await orderRepository.getOrders();
      emit(state.copyWith(orders: orders, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onIncreaseQty(IncreaseQty event, Emitter<ProductState> emit) {
    final products = List<Map<String, dynamic>>.from(state.products);
    final product = products[event.index];
    final productName = product["name"] as String;
    final currentQty = product["qty"] as int;
    final stock = product["stock"] as int;

    final maxAllowed = RoleLimits.getMaxQuantity(event.userType, productName);

    if (currentQty < stock && currentQty < maxAllowed) {
      product["qty"] = currentQty + 1;
      emit(state.copyWith(products: products));
    }
  }

  void _onDecreaseQty(DecreaseQty event, Emitter<ProductState> emit) {
    final products = List<Map<String, dynamic>>.from(state.products);
    final product = products[event.index];
    final currentQty = product["qty"] as int;

    if (currentQty > 0) {
      product["qty"] = currentQty - 1;
      emit(state.copyWith(products: products));
    }
  }

  void _onPlaceOrders(PlaceOrders event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = List<Map<String, dynamic>>.from(state.products);
      final orders = List<Order>.from(state.orders);

      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        final qty = product["qty"] as int;
        if (qty > 0) {
          product["stock"] = (product["stock"] as int) - qty;
          product["qty"] = 0;

          final order = Order(
            userType: event.userType,
            productName: product["name"],
            qty: qty,
            date: DateTime.now(),
          );

          orders.add(order);
          await orderRepository.addOrder(order);
        }
      }

      emit(state.copyWith(
        products: products,
        orders: orders,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onDeleteOrder(DeleteOrder event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final orders = List<Order>.from(state.orders);
      final products = List<Map<String, dynamic>>.from(state.products);

      orders.removeWhere((order) =>
      order.userType == event.order.userType &&
          order.productName == event.order.productName &&
          order.qty == event.order.qty
      );

      await orderRepository.deleteOrder(event.order);

      final productIndex = products.indexWhere((p) => p["name"] == event.order.productName);
      if (productIndex != -1) {
        products[productIndex]["stock"] += event.order.qty;
      }

      emit(state.copyWith(
        products: products,
        orders: orders,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onClearCart(ClearCart event, Emitter<ProductState> emit) {
    final products = List<Map<String, dynamic>>.from(state.products);
    for (var product in products) {
      product["qty"] = 0;
    }
    emit(state.copyWith(products: products));
  }
}
