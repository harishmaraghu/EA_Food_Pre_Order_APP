import 'package:ea_food_project/features/order/data/models/order.dart';
import 'package:ea_food_project/features/order/data/repositories/OrderRepository.dart';
import 'package:ea_food_project/features/order/presentation/OrderHistoryScreen.dart';
import 'package:ea_food_project/features/order/presentation/role_limit.dart';
import 'package:ea_food_project/features/order/presentation/roleselectionscreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../product/presentation/bloc/product_bloc.dart';
import '../../product/presentation/bloc/product_event.dart';
import '../../product/presentation/bloc/product_state.dart';


class ProductListScreen extends StatefulWidget {
  final String userType;

  const ProductListScreen({super.key, required this.userType});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    final roleColor = AppColors.getRoleColor(widget.userType);

    return BlocProvider(
      create: (_) => ProductBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.userType} Dashboard",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                RoleLimits.getRoleDescription(widget.userType),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          backgroundColor: roleColor,
          elevation: 0,
          actions: [
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                final cartCount = state.products
                    .fold<int>(0, (sum, product) => sum + (product["qty"] as int));

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () => _showCartSummary(context, state),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProductBloc>(),
                      child: OrderHistoryScreen(userType: widget.userType),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Role Info Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: roleColor.withOpacity(0.2)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getRoleIcon(widget.userType),
                            color: roleColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Typical Quantities for ${widget.userType}:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: roleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: RoleLimits.getTypicalQuantities(widget.userType)
                            .map((qty) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: roleColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            qty,
                            style: TextStyle(
                              fontSize: 11,
                              color: roleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // Product List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      final productName = product["name"] as String;
                      final maxAllowed = RoleLimits.getMaxQuantity(widget.userType, productName);
                      final currentQty = product["qty"] as int;
                      final stock = product["stock"] as int;
                      final unit = product["unit"] as String;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: currentQty > 0
                              ? Border.all(color: roleColor.withOpacity(0.5), width: 2)
                              : Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getProductColor(productName).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getProductIcon(productName),
                                      color: _getProductColor(productName),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "Stock: $stock $unit",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: roleColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                "Max: $maxAllowed $unit",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: roleColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Quantity Controls
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: currentQty > 0
                                              ? () => context.read<ProductBloc>().add(DecreaseQty(index))
                                              : null,
                                          color: currentQty > 0 ? roleColor : AppColors.textLight,
                                        ),
                                        Container(
                                          constraints: const BoxConstraints(minWidth: 40),
                                          child: Text(
                                            "$currentQty",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: currentQty > 0 ? roleColor : AppColors.textSecondary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: currentQty < stock && currentQty < maxAllowed
                                              ? () => context.read<ProductBloc>().add(
                                            IncreaseQty(index, widget.userType),
                                          )
                                              : null,
                                          color: currentQty < stock && currentQty < maxAllowed
                                              ? roleColor
                                              : AppColors.textLight,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (currentQty > 0) ...[
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$currentQty $unit selected",
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  if (currentQty >= maxAllowed)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 14,
                                            color: AppColors.warning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Role limit reached",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.warning,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      final hasSelected = state.products.any((p) => p["qty"] > 0);
                      final totalItems = state.products.fold<int>(
                        0,
                            (sum, product) => sum + (product["qty"] as int),
                      );

                      return Column(
                        children: [
                          if (hasSelected) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Items: $totalItems",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: roleColor,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.read<ProductBloc>().add(const ClearCart()),
                                  child: const Text("Clear Cart"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: hasSelected
                                      ? () => _placeOrder(context)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasSelected ? roleColor : AppColors.textLight,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.shopping_cart_checkout),
                                      const SizedBox(width: 8),
                                      Text(
                                        hasSelected
                                            ? "Place Order ($totalItems items)"
                                            : "Select Products First",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _getRoleIcon(String userType) {
    switch (userType) {
      case 'Customer':
        return Icons.person;
      case 'TSU':
        return Icons.store;
      case 'SR':
        return Icons.business_center;
      default:
        return Icons.person;
    }
  }

  IconData _getProductIcon(String productName) {
    switch (productName.toLowerCase()) {
      case 'milk':
        return Icons.local_drink;
      case 'bread':
        return Icons.bakery_dining;
      case 'rice':
        return Icons.rice_bowl;
      case 'oil':
        return Icons.water_drop;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getProductColor(String productName) {
    switch (productName.toLowerCase()) {
      case 'milk':
        return Colors.blue;
      case 'bread':
        return Colors.orange;
      case 'rice':
        return Colors.brown;
      case 'oil':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }

  void _showCartSummary(BuildContext context, ProductState state) {
    final selectedProducts = state.products.where((p) => p["qty"] > 0).toList();

    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cart Summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...selectedProducts.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(_getProductIcon(product["name"]), size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(product["name"])),
                  Text(
                    "${product["qty"]} ${product["unit"]}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _placeOrder(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getRoleColor(widget.userType),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Place Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final hasSelected = productBloc.state.products.any((p) => p["qty"] > 0);

    if (hasSelected) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text("Confirm Order"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Place order as ${widget.userType}?",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.getRoleColor(widget.userType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: productBloc.state.products
                      .where((p) => p["qty"] > 0)
                      .map((product) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          _getProductIcon(product["name"]),
                          size: 16,
                          color: AppColors.getRoleColor(widget.userType),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(product["name"])),
                        Text(
                          "${product["qty"]} ${product["unit"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getRoleColor(widget.userType),
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Order will be saved with userType = ${widget.userType}",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                productBloc.add(PlaceOrders(widget.userType));

                // Get next day slot info
                final nextDay = DateTime.now().add(const Duration(days: 1));
                final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][nextDay.weekday - 1];
                final dateString = "${nextDay.day}/${nextDay.month}/${nextDay.year}";

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Order placed successfully!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Delivery scheduled for next day: $dayName, $dateString",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Your order flows into consolidated stock planning",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 4),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getRoleColor(widget.userType),
                foregroundColor: Colors.white,
              ),
              child: const Text("Place Order"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one product"),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}
