import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/customer_product_list_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Shopping App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/products',
        routes: {
          '/login': (context) => const AdminLoginScreen(),
          '/dashboard': (context) => const AdminDashboardScreen(),
          '/products': (context) => const CustomerProductListScreen(),
          '/cart': (context) => const CartScreen(),
          '/orders': (context) => OrderHistoryScreen(isAdminView: false),
          '/admin/orders': (context) => OrderHistoryScreen(isAdminView: true),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
