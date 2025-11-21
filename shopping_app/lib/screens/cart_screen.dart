import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late ApiService _apiService;
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For now, we'll use a default user ID. In a real app, this would come from auth
      const int userId = 1;
      
      final cartItems = await _apiService.getCartItems(userId);
      
      setState(() {
        _cartItems = cartItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(CartItem cartItem, int newQuantity) async {
    if (newQuantity <= 0) {
      _removeItem(cartItem.id);
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // For now, we'll use a default user ID. In a real app, this would come from auth
      const int userId = 1;
      
      // First remove the existing item
      await _apiService.addToCart(
        userId: userId,
        productId: cartItem.productId,
        quantity: newQuantity,
      );

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated quantity for ${cartItem.productName}')),
      );

      _loadCartItems(); // Refresh the cart
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeItem(int cartItemId) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _apiService.removeCartItem(cartItemId);

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item removed from cart')),
      );

      _loadCartItems(); // Refresh the cart
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: ${e.toString()}')),
      );
    }
  }

  double _calculateSubtotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double _calculateTax(double subtotal) {
    return subtotal * 0.12; // 12% tax
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final tax = _calculateTax(subtotal);
    return subtotal + tax;
  }

  void _proceedToCheckout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cartItems: _cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCartItems,
            tooltip: 'Refresh Cart',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomSummary(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 16),
            Text('Loading cart items...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCartItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Start shopping to add items to your cart',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCartItems,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = _cartItems[index];
          return _buildCartItemCard(cartItem);
        },
      ),
    );
  }

  Widget _buildCartItemCard(CartItem cartItem) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: cartItem.productImage.isNotEmpty
                      ? Image.network(
                          cartItem.productImage,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image, color: Colors.grey),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        'Category: ${cartItem.productName}', // Note: CartItem doesn't have categoryName, using product name instead
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        '₱${cartItem.productPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Stock Status
                      Row(
                        children: [
                          Icon(
                            cartItem.productStock > 0 ? Icons.check_circle : Icons.cancel,
                            color: cartItem.productStock > 0 ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cartItem.productStock > 0
                                ? 'In Stock (${cartItem.productStock} available)'
                                : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 12,
                              color: cartItem.productStock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quantity Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                Row(
                  children: [
                    // Decrease Button
                    IconButton(
                      onPressed: _isUpdating || cartItem.quantity <= 1
                          ? null
                          : () => _updateQuantity(cartItem, cartItem.quantity - 1),
                      icon: const Icon(Icons.remove),
                      style: IconButton.styleFrom(
                        backgroundColor: cartItem.quantity > 1 && !_isUpdating 
                            ? Colors.deepPurple 
                            : Colors.grey,
                      ),
                      tooltip: 'Decrease quantity',
                    ),
                    
                    // Quantity Display
                    Container(
                      width: 60,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          cartItem.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Increase Button
                    IconButton(
                      onPressed: _isUpdating || cartItem.quantity >= cartItem.productStock
                          ? null
                          : () => _updateQuantity(cartItem, cartItem.quantity + 1),
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: cartItem.quantity < cartItem.productStock && !_isUpdating
                            ? Colors.deepPurple 
                            : Colors.grey,
                      ),
                      tooltip: 'Increase quantity',
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Item Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₱${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                
                IconButton(
                  onPressed: _isUpdating
                      ? null
                      : () => _removeItem(cartItem.id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove item',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    if (_cartItems.isEmpty || _isLoading) {
      return const SizedBox.shrink();
    }

    final subtotal = _calculateSubtotal();
    final tax = _calculateTax(subtotal);
    final total = _calculateTotal();

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '₱${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tax (12%):',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '₱${tax.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Divider(color: Colors.grey[300]),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _proceedToCheckout,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}