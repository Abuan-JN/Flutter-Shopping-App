import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/customer_product_list_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_details_screen.dart';
import 'models/product.dart';
import 'models/cart_item.dart';

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
        home: AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/products': (context) => const CustomerProductListScreen(),
          '/cart': (context) => const CartScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
          '/checkout': (context) => CheckoutScreen(cartItems: ModalRoute.of(context)?.settings.arguments as List<CartItem>),
          '/product-details': (context) => ProductDetailsScreen(product: ModalRoute.of(context)?.settings.arguments as Product),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is already logged in
    if (authProvider.isUserLoggedIn) {
      return const CustomerProductListScreen();
    } else {
      return const LoginScreen();
    }
  }
}
