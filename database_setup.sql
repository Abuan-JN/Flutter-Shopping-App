-- Database: `shopping_app`
-- This script creates the required tables for the Flutter Shopping App

-- Create the database (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS shopping_app;
USE shopping_app;

-- Table structure for table `flutter2_users` (admin login)
CREATE TABLE IF NOT EXISTS `flutter2_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_categories`
CREATE TABLE IF NOT EXISTS `flutter2_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_products`
CREATE TABLE IF NOT EXISTS `flutter2_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `category_id` int(11) NOT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `flutter2_products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `flutter2_categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_cart`
CREATE TABLE IF NOT EXISTS `flutter2_cart` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(255) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_cart_item` (`session_id`,`product_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `flutter2_cart_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `flutter2_products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_orders`
CREATE TABLE IF NOT EXISTS `flutter2_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(255) NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `customer_email` varchar(100) NOT NULL,
  `customer_phone` varchar(20) DEFAULT NULL,
  `customer_address` text NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_order_items`
CREATE TABLE IF NOT EXISTS `flutter2_order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `flutter2_order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `flutter2_orders` (`id`),
  CONSTRAINT `flutter2_order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `flutter2_products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert some sample data for testing
INSERT INTO `flutter2_users` (`username`, `password`, `email`) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@example.com');

INSERT INTO `flutter2_categories` (`name`, `description`) VALUES
('Electronics', 'Electronic devices and accessories'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and educational materials'),
('Home & Garden', 'Home improvement and garden supplies');

INSERT INTO `flutter2_products` (`name`, `description`, `price`, `category_id`, `image_url`, `stock_quantity`) VALUES
('Smartphone', 'Latest smartphone with advanced features', 699.99, 1, 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Smartphone', 50),
('Laptop', 'Powerful laptop for work and entertainment', 1299.99, 1, 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Laptop', 25),
('T-Shirt', 'Comfortable cotton t-shirt', 19.99, 2, 'https://via.placeholder.com/300x300/000000/FFFFFF?text=T-Shirt', 100),
('Jeans', 'Classic denim jeans', 49.99, 2, 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Jeans', 75),
('Fiction Book', 'Bestselling fiction novel', 14.99, 3, 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Book', 200),
('Garden Tools Set', 'Complete set of gardening tools', 39.99, 4, 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Garden+Tools', 30);