import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../product/presentation/bloc/product_bloc.dart';
import '../../product/presentation/bloc/product_event.dart';
import '../../product/presentation/bloc/product_state.dart';
import '../data/models/order.dart';


class OrderHistoryScreen extends StatelessWidget {
  final String userType;

  const OrderHistoryScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final roleColor = AppColors.getRoleColor(userType);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "$userType Order History",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: roleColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter orders by user type
          final userOrders = state.orders
              .where((order) => order.userType == userType)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first

          if (userOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.history,
                      size: 64,
                      color: roleColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No orders found",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your $userType orders will appear here",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: roleColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Start Shopping"),
                  ),
                ],
              ),
            );
          }

          // Group orders by date
          final groupedOrders = <String, List<Order>>{};
          for (final order in userOrders) {
            final dateKey = _formatDateKey(order.date);
            groupedOrders.putIfAbsent(dateKey, () => []).add(order);
          }

          return Column(
            children: [
              // Statistics Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: roleColor.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Total Orders",
                        "${userOrders.length}",
                        Icons.shopping_bag,
                        roleColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        "Total Items",
                        "${userOrders.fold<int>(0, (sum, order) => sum + order.qty)}",
                        Icons.inventory,
                        roleColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        "This Month",
                        "${_getThisMonthOrders(userOrders).length}",
                        Icons.calendar_today,
                        roleColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Order List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedOrders.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedOrders.keys.elementAt(index);
                    final dayOrders = groupedOrders[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: roleColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateKey,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: roleColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${dayOrders.length} order${dayOrders.length > 1 ? 's' : ''}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: roleColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Orders for this date
                        ...dayOrders.map((order) {
                          // Calculate delivery info based on order booking time
                          final deliveryInfo = _calculateDeliveryInfo(order.date);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
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
                                children: [
                                  // Main order info row
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _getProductColor(order.productName).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getProductIcon(order.productName),
                                          color: _getProductColor(order.productName),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    order.productName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: roleColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    userType,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: roleColor,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Quantity: ${order.qty} ${_getProductUnit(order.productName)}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                        ),
                                        onPressed: () => _showDeleteConfirmation(context, order),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Order timing and delivery info
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        // Stock booking time
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.inventory,
                                              size: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Stock booked:",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatTime(order.date),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: deliveryInfo['statusColor'].withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                deliveryInfo['cutoffStatus'],
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: deliveryInfo['statusColor'],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Delivery info
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.local_shipping,
                                              size: 16,
                                              color: deliveryInfo['statusColor'],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              deliveryInfo['deliveryType'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: deliveryInfo['statusColor'],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.event,
                                              size: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                deliveryInfo['deliveryDateTime'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w500,
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
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Calculate delivery info based on stock booking time
  Map<String, dynamic> _calculateDeliveryInfo(DateTime stockBookingTime) {
    final cutoffTime = DateTime(stockBookingTime.year, stockBookingTime.month, stockBookingTime.day, 18, 0);
    final isStockBookedBeforeCutoff = stockBookingTime.isBefore(cutoffTime);

    DateTime deliveryDate;
    String deliveryType;
    String cutoffStatus;
    Color statusColor;

    if (isStockBookedBeforeCutoff) {
      deliveryDate = stockBookingTime.add(const Duration(days: 1));
      deliveryType = "Next Day";
      cutoffStatus = "Before 6PM";
      statusColor = Colors.green;
    } else {
      deliveryDate = stockBookingTime.add(const Duration(days: 2));
      deliveryType = "Extended (+2 days)";
      cutoffStatus = "After 6PM";
      statusColor = Colors.orange;
    }

    final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][deliveryDate.weekday - 1];
    final deliveryDateString = "${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}";

    return {
      'deliveryType': deliveryType,
      'deliveryDateTime': "$dayName, $deliveryDateString",
      'cutoffStatus': cutoffStatus,
      'statusColor': statusColor,
    };
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) {
      return "Today";
    } else if (orderDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  List<Order> _getThisMonthOrders(List<Order> orders) {
    final now = DateTime.now();
    return orders.where((order) =>
    order.date.year == now.year && order.date.month == now.month
    ).toList();
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

  String _getProductUnit(String productName) {
    switch (productName.toLowerCase()) {
      case 'milk':
      case 'oil':
        return 'L';
      case 'bread':
        return 'packets';
      case 'rice':
        return 'kg';
      default:
        return 'units';
    }
  }

  void _showFilterOptions(BuildContext context) {
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
              "Filter Options",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text("Today's Orders"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("This Month"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("All Orders"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Order order) {
    final deliveryInfo = _calculateDeliveryInfo(order.date);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8),
            Text("Delete Order"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete this order?",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${order.productName} - ${order.qty} ${_getProductUnit(order.productName)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Ordered: ${_formatDateKey(order.date)} at ${_formatTime(order.date)}"),
                  const SizedBox(height: 4),
                  Text(
                    "Delivery: ${deliveryInfo['deliveryType']} - ${deliveryInfo['deliveryDateTime']}",
                    style: TextStyle(
                      color: deliveryInfo['statusColor'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Time Slot: ${deliveryInfo['deliverySlot']}",
                    style: TextStyle(
                      fontSize: 12,
                      color: deliveryInfo['statusColor'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              if (!state.isLoading && state.error == null) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Order deleted: ${order.productName}"),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state.error != null) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error deleting order: ${state.error}"),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<ProductBloc>().add(DeleteOrder(order)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: state.isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text("Delete"),
              );
            },
          ),
        ],
      ),
    );
  }
}