# Changelog

All notable changes to this project will be documented in this file.

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