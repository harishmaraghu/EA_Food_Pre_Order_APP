import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String userType;
  final Map<String, dynamic> product;

  const OrderSuccessScreen({
    super.key,
    required this.userType,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Success")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text("✅ Order placed successfully!"),
            Text("Role: $userType"),
            Text("Product: ${product["name"]}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
