import 'package:ea_food_project/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'features/order/data/models/order.dart';
import 'features/order/presentation/roleselectionscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(OrderAdapter());
  await Hive.openBox<Order>('orders');
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EA Foods Pre-Order',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const RoleSelectionScreen(),
      ),
    );
  }
}


