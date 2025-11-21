# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2025-11-21

### Added
- Initial project setup for Flutter Shopping App with PHP Backend
- Database structure with SQL script (`database_setup.sql`)
  - Created tables: `users`, `products`, `categories`, `cart`, `orders`, `order_items`
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