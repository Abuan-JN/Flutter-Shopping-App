import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/category.dart' as models;
import 'product_details_screen.dart';

class CustomerProductListScreen extends StatefulWidget {
  const CustomerProductListScreen({super.key});

  @override
  State<CustomerProductListScreen> createState() => _CustomerProductListScreenState();
}

class _CustomerProductListScreenState extends State<CustomerProductListScreen> {
  late ApiService _apiService;
  List<Product> _products = [];
  List<models.Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedCategoryId = 0; // 0 means all categories

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load both products and categories
      final products = await _apiService.getProducts();
      final categories = await _apiService.getCategories();
      
      setState(() {
        _products = products;
        _categories = categories;
        _isLoading = false;
      });
      
      // Filter products after loading
      _filterProducts();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _filterProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _apiService.getProducts();
      
      // Filter products by category if a specific category is selected
      List<Product> filteredProducts = products;
      if (_selectedCategoryId > 0) {
        filteredProducts = products.where((product) => product.categoryId == _selectedCategoryId).toList();
      }
      
      setState(() {
        _products = filteredProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _viewProductDetails(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
    
    // Refresh products if something was added to cart
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    _filterProducts();
  }

  Future<void> _addToCart(Product product) async {
    try {
      // For now, we'll use a default user ID. In a real app, this would come from auth
      const int userId = 1;
      const int quantity = 1;

      final result = await _apiService.addToCart(
        userId: userId,
        productId: product.id,
        quantity: quantity,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${product.name} to cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.pushNamed(context, '/orders');
            },
            tooltip: 'Order History',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            tooltip: 'View Cart',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildCategoryFilter(),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: _categories.isNotEmpty
          ? ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // "All" category button
                _buildCategoryChip(
                  categoryId: 0,
                  categoryName: 'All',
                  isSelected: _selectedCategoryId == 0,
                ),
                
                // Individual category buttons
                for (final category in _categories)
                  _buildCategoryChip(
                    categoryId: category.id,
                    categoryName: category.name,
                    isSelected: _selectedCategoryId == category.id,
                  ),
              ],
            )
          : const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
    );
  }

  Widget _buildCategoryChip({
    required int categoryId,
    required String categoryName,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(categoryName),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategoryId = selected ? categoryId : 0;
          });
          _filterProducts();
        },
        selectedColor: Colors.deepPurple,
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inventory_2, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new products',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _viewProductDetails(product),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: product.image.isNotEmpty
                    ? Image.network(
                        product.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, size: 60, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.image, size: 60, color: Colors.grey),
              ),
            ),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Category
                  Text(
                    product.categoryName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.deepPurple,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // Price
                  Text(
                    '₱${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Stock Status
                  Text(
                    product.stock > 0 ? 'In Stock: ${product.stock}' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.stock > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: product.stock > 0 ? () => _addToCart(product) : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: product.stock > 0 ? Colors.deepPurple : Colors.grey,
                      ),
                      child: Text(
                        product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
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