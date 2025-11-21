# Changelog

All notable changes to this project will be documented in this file.

## [0.0.4] - 2025-11-21

### Added
- Flutter Project Initialization (Batch 3.1)
  - Created new Flutter project using `flutter create shopping_app`
  - Added required dependencies to pubspec.yaml:
    - `http: ^1.0.0` for API communication
    - `provider: ^6.0.0` for optional state management
  - Successfully installed dependencies with `flutter pub get`
  - Project structure created with 130 files including main.dart entry point
  - Ready for API configuration and data model implementation
- Configuration Setup (Batch 3.2)
  - Created `ApiConfig` class in `lib/config/api_config.dart`
  - Implemented static base URL: `http://abuanplmunflutter.sportsontheweb.net/api/`
  - Added all API endpoint constants for easy reference
  - Organized endpoints by functionality (products, categories, auth, cart, orders)
  - Ready for data model implementation and API service creation
- Data Models Implementation (Batch 3.3)
  - Created `Product` model in `lib/models/product.dart`
    - Includes all product fields: id, name, description, price, category_id, image, stock, is_active, created_at
    - Implemented fromJson and toJson methods for JSON serialization
    - Added computed properties and proper toString method
  - Created `Category` model in `lib/models/category.dart`
    - Includes category fields: id, name, description, is_active, created_at
    - Implemented proper JSON serialization methods
  - Created `CartItem` model in `lib/models/cart_item.dart`
    - Includes cart-specific fields plus product display data
    - Added totalPrice computed property for easy calculations
    - Supports cart functionality with quantity management
  - Created `Order` and `OrderItem` models in `lib/models/order.dart`
    - Order model includes customer information and order status
    - OrderItem model handles individual items within orders
    - Supports complex order structure with nested items
    - Ready for API service integration and state management
- API Service Implementation (Batch 3.4)
  - Created comprehensive `ApiService` class in `lib/services/api_service.dart`
  - Implemented all CRUD operations for products and categories (admin functions)
  - Added cart management functions: addToCart, getCartItems, removeCartItem
  - Implemented order processing: createOrder, getOrders
  - Added authentication function: login
  - Included proper error handling and response parsing
  - Used proper HTTP methods (GET/POST) with JSON serialization
  - Implemented security headers and request validation
  - Added client disposal method for resource management
  - Ready for Flutter UI implementation and state management integration

## [0.0.3] - 2025-11-21

### Added
- Authentication API endpoint
  - `api/login.php` - Admin login functionality with secure password verification
  - Input validation for username and password fields
  - JSON Web Token (JWT) style token generation for session management
  - Error handling for authentication failures
- Cart Management API endpoints
  - `api/add_to_cart.php` - Add products to shopping cart with stock validation
  - `api/get_cart.php` - Retrieve all cart items with totals and stock warnings
  - `api/remove_cart_item.php` - Remove items from cart by ID or product
  - Session-based cart management for guest users
  - Stock quantity validation and availability checks
  - Cart item count and total calculation
- Order Processing API endpoints
  - `api/create_order.php` - Complete checkout process with cart-to-order conversion
  - `api/get_orders.php` - View order history with detailed order information
  - Full transaction management with database transactions
  - Customer information validation and storage
  - Automatic stock deduction and cart clearing
  - Order status tracking (pending, completed, cancelled)
  - Order statistics and analytics for admin users

### Changed
- Updated all table names in `database_setup.sql` and API files to include "flutter2_" prefix for consistency
- Tables renamed:
  - `users` → `flutter2_users`
  - `categories` → `flutter2_categories`
  - `products` → `flutter2_products`
  - `cart` → `flutter2_cart`
  - `orders` → `flutter2_orders`
  - `order_items` → `flutter2_order_items`
- Updated all SQL queries in API endpoints (`add_category.php`, `add_product.php`, `delete_product.php`, `get_categories.php`, `get_products.php`, `update_product.php`) to reference the new table names
- Updated foreign key constraints and relationships in database schema accordingly

## [0.0.1] - 2025-11-21

### Added
- Initial project setup for Flutter Shopping App with PHP Backend
- Database structure with SQL script (`database_setup.sql`)
  - Created tables: `flutter2_users`, `flutter2_products`, `flutter2_categories`, `flutter2_cart`, `flutter2_orders`, `flutter2_order_items`
  - Added sample data for testing
- Backend API foundation
  - Database connection handler (`api/db_connect.php`)
  - Product management endpoints:
    - `api/get_products.php` - Retrieve all active products
    - `api/add_product.php` - Add new products
    - `api/update_product.php` - Update existing products
    - `api/delete_product.php` - Delete or deactivate products
  - Category management endpoints:
    - `api/get_categories.php` - Retrieve all categories
    - `api/add_category.php` - Add new categories
- Project documentation
  - `README.md` - Comprehensive project overview and requirements
  - `Batch_Task.md` - Sequential task roadmap
  - This `changelog.md` file

### Features
- Full CRUD operations for products and categories
- Database relationships and foreign key constraints
- Input validation and error handling
- CORS support for API access
- JSON response formatting
- Sample data for immediate testing

### Technical Details
- PHP backend with MySQL database
- PDO for database connections with error handling
- RESTful API design principles
- Security considerations (input validation, SQL injection prevention)
- Structured project organization

### Next Steps
- Upload files to hosting server (`http://abuanplmunflutter.sportsontheweb.net`)
- Configure database credentials in `db_connect.php`
- Test API endpoints for functionality
- Proceed with Batch 2: Advanced Backend Logic