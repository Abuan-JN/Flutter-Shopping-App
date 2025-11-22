-- Database: `shopping_app`
-- This script creates the required tables for the Flutter Shopping App
-- Updated schema with proper customer authentication, product management, and order processing

-- Create the database (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS shopping_app;
USE shopping_app;

-- Table structure for table `flutter2_users` (customer and admin users)
CREATE TABLE IF NOT EXISTS `flutter2_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text,
  `password` varchar(255) NOT NULL,
  `role` enum('customer','admin') NOT NULL DEFAULT 'customer',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `email_verified_at` timestamp NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `role` (`role`),
  KEY `is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_categories`
CREATE TABLE IF NOT EXISTS `flutter2_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `image_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_products`
CREATE TABLE IF NOT EXISTS `flutter2_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `category_id` int(11) NOT NULL,
  `image` varchar(500) DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `is_active` (`is_active`),
  KEY `stock` (`stock`),
  CONSTRAINT `flutter2_products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `flutter2_categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_cart`
CREATE TABLE IF NOT EXISTS `flutter2_cart` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_cart_item_user` (`user_id`,`product_id`),
  UNIQUE KEY `unique_cart_item_session` (`session_id`,`product_id`),
  KEY `product_id` (`product_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `flutter2_cart_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `flutter2_products` (`id`),
  CONSTRAINT `flutter2_cart_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `flutter2_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_orders`
CREATE TABLE IF NOT EXISTS `flutter2_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `customer_name` varchar(100) NOT NULL,
  `customer_email` varchar(100) NOT NULL,
  `customer_phone` varchar(20) DEFAULT NULL,
  `customer_address` text NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_status` varchar(50) DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `status` (`status`),
  KEY `created_at` (`created_at`),
  CONSTRAINT `flutter2_orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `flutter2_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `flutter2_order_items`
CREATE TABLE IF NOT EXISTS `flutter2_order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `product_name` varchar(200) NOT NULL,
  `product_image` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `flutter2_order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `flutter2_orders` (`id`),
  CONSTRAINT `flutter2_order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `flutter2_products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data for testing

-- Admin user for backend management
INSERT INTO `flutter2_users` (`name`, `email`, `phone`, `address`, `password`, `role`, `is_active`) VALUES
('Admin User', 'admin@example.com', '09123456789', 'Admin Office, City, Country', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 1);

-- Customer users for testing
INSERT INTO `flutter2_users` (`name`, `email`, `phone`, `address`, `password`, `role`, `is_active`) VALUES
('John Doe', 'john@example.com', '09123456789', '123 Main Street, Manila, Philippines', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer', 1),
('Jane Smith', 'jane@example.com', '09987654321', '456 Oak Avenue, Quezon City, Philippines', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer', 1);

-- Product categories
INSERT INTO `flutter2_categories` (`name`, `description`, `image_url`, `is_active`) VALUES
('Electronics', 'Electronic devices and accessories', 'https://via.placeholder.com/300x300/007bff/FFFFFF?text=Electronics', 1),
('Clothing', 'Apparel and fashion items', 'https://via.placeholder.com/300x300/28a745/FFFFFF?text=Clothing', 1),
('Books', 'Books and educational materials', 'https://via.placeholder.com/300x300/17a2b8/FFFFFF?text=Books', 1),
('Home & Garden', 'Home improvement and garden supplies', 'https://via.placeholder.com/300x300/20c079/FFFFFF?text=Home+%26+Garden', 1),
('Sports & Outdoors', 'Sports equipment and outdoor gear', 'https://via.placeholder.com/300x300/dc3545/FFFFFF?text=Sports+%26+Outdoors', 1);

-- Sample products with improved data structure
INSERT INTO `flutter2_products` (`name`, `description`, `price`, `category_id`, `image`, `stock`, `is_active`) VALUES
-- Electronics
('iPhone 15 Pro', 'Latest iPhone with A17 Pro chip, titanium design, and advanced camera system', 1299.99, 1, 'https://via.placeholder.com/300x300/000000/FFFFFF?text=iPhone+15+Pro', 20, 1),
('MacBook Air M3', 'Ultrafast and ultraportable laptop with M3 chip and all-day battery life', 1199.99, 1, 'https://via.placeholder.com/300x300/6c757d/FFFFFF?text=MacBook+Air+M3', 15, 1),
('Sony WH-1000XM5', 'Industry leading noise canceling headphones with 30-hour battery life', 399.99, 1, 'https://via.placeholder.com/300x300/495057/FFFFFF?text=Sony+WH-1000XM5', 25, 1),
('Samsung 65 inch QLED TV', '4K Ultra HD Smart TV with Quantum Dot technology and HDR10 plus', 1899.99, 1, 'https://via.placeholder.com/300x300/003366/FFFFFF?text=Samsung+QLED+TV', 10, 1),

-- Clothing
('Nike Air Force 1', 'Classic basketball shoes with modern comfort and style', 99.99, 2, 'https://via.placeholder.com/300x300/f8f9fa/000000?text=Nike+Air+Force+1', 50, 1),
('Levis 501 Jeans', 'Iconic straight fit jeans made with premium denim', 79.99, 2, 'https://via.placeholder.com/300x300/6c757d/FFFFFF?text=Levis+501+Jeans', 40, 1),
('Uniqlo Ultra Light Down Jacket', 'Water-repellent lightweight down jacket perfect for travel', 89.99, 2, 'https://via.placeholder.com/300x300/17a2b8/FFFFFF?text=Ultra+Light+Down', 35, 1),

-- Books
('The Psychology of Money', 'Timeless lessons on wealth, greed, and happiness', 15.99, 3, 'https://via.placeholder.com/300x300/151515/FFFFFF?text=Psychology+of+Money', 100, 1),
('Atomic Habits', 'An easy and proven way to build good habits and break bad ones', 17.99, 3, 'https://via.placeholder.com/300x300/495057/FFFFFF?text=Atomic+Habits', 80, 1),
('Dune by Frank Herbert', 'Epic science fiction novel set in the distant future amidst a feudal interstellar society', 14.99, 3, 'https://via.placeholder.com/300x300/dc3545/FFFFFF?text=Dune', 60, 1),

-- Home & Garden
('Dyson V15 Detect', 'Cordless vacuum cleaner with laser dust detection and HEPA filter', 749.99, 4, 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Dyson+V15', 12, 1),
('IKEA KALLAX Shelf Unit', 'Versatile storage unit with 4 compartments, perfect for any room', 79.99, 4, 'https://via.placeholder.com/300x300/6c757d/FFFFFF?text=KALLAX+Shelf', 25, 1),
('Philips Smart LED Bulb', 'WiFi connected LED bulb with 16 million colors and white light', 49.99, 4, 'https://via.placeholder.com/300x300/17a2b8/FFFFFF?text=Smart+LED+Bulb', 50, 1),

-- Sports & Outdoors
('Yoga Mat (Non-Slip)', 'Extra thick 10mm non-slip yoga mat with carrying strap', 29.99, 5, 'https://via.placeholder.com/300x300/28a745/FFFFFF?text=Yoga+Mat', 45, 1),
('Coleman Camping Tent', '4-person weatherproof camping tent with bathtub floor', 129.99, 5, 'https://via.placeholder.com/300x300/dc3545/FFFFFF?text=Camping+Tent', 20, 1),
('Nike Running Shoes', 'Breathable running shoes with responsive cushioning', 89.99, 5, 'https://via.placeholder.com/300x300/f8f9fa/000000?text=Running+Shoes', 30, 1);

-- Sample orders for testing
INSERT INTO `flutter2_orders` (`user_id`, `customer_name`, `customer_email`, `customer_phone`, `customer_address`, `total_amount`, `status`, `payment_method`, `payment_status`, `notes`) VALUES
(2, 'John Doe', 'john@example.com', '09123456789', '123 Main Street Manila Philippines', 1399.97, 'completed', 'Cash on Delivery', 'pending', 'Please handle with care'),
(3, 'Jane Smith', 'jane@example.com', '09987654321', '456 Oak Avenue Quezon City Philippines', 289.97, 'processing', 'GCash', 'paid', 'Gift wrapping requested'),
(2, 'John Doe', 'john@example.com', '09123456789', '123 Main Street Manila Philippines', 99.99, 'pending', 'Bank Transfer', 'pending', NULL);

-- Sample order items for testing
-- Note: Using actual product IDs from the products table above
-- Products 1-4: Electronics, 5-7: Clothing, 8-10: Books, 11-13: Home & Garden, 14-16: Sports & Outdoors
INSERT INTO `flutter2_order_items` (`order_id`, `product_id`, `quantity`, `price`, `product_name`, `product_image`) VALUES
-- Order 1 items (John Doe's order)
(1, 1, 1, 1299.99, 'iPhone 15 Pro', 'https://via.placeholder.com/300x300/000000/FFFFFF?text=iPhone+15+Pro'),
(1, 5, 1, 99.99, 'Nike Air Force 1', 'https://via.placeholder.com/300x300/f8f9fa/000000?text=Nike+Air+Force+1'),
-- Order 2 items (Jane Smith's order)
(2, 8, 1, 15.99, 'The Psychology of Money', 'https://via.placeholder.com/300x300/151515/FFFFFF?text=Psychology+of+Money'),
(2, 9, 1, 17.99, 'Atomic Habits', 'https://via.placeholder.com/300x300/495057/FFFFFF?text=Atomic+Habits'),
(2, 10, 1, 14.99, 'Dune by Frank Herbert', 'https://via.placeholder.com/300x300/dc3545/FFFFFF?text=Dune'),
(2, 6, 1, 79.99, 'Levis 501 Jeans', 'https://via.placeholder.com/300x300/6c757d/FFFFFF?text=Levis+501+Jeans'),
(2, 7, 1, 89.99, 'Uniqlo Ultra Light Down Jacket', 'https://via.placeholder.com/300x300/17a2b8/FFFFFF?text=Ultra+Light+Down'),
(2, 11, 1, 79.99, 'IKEA KALLAX Shelf Unit', 'https://via.placeholder.com/300x300/6c757d/FFFFFF?text=KALLAX+Shelf'),
-- Order 3 items (John Doe's second order)
(3, 5, 1, 99.99, 'Nike Air Force 1', 'https://via.placeholder.com/300x300/f8f9fa/000000?text=Nike+Air+Force+1');

-- Create indexes for better performance
CREATE INDEX idx_products_category_active ON `flutter2_products`(`category_id`, `is_active`);
CREATE INDEX idx_products_stock ON `flutter2_products`(`stock`);
CREATE INDEX idx_orders_user_status ON `flutter2_orders`(`user_id`, `status`);
CREATE INDEX idx_cart_user_product ON `flutter2_cart`(`user_id`, `product_id`);
CREATE INDEX idx_order_items_order_product ON `flutter2_order_items`(`order_id`, `product_id`);

-- Add constraints for data integrity
ALTER TABLE `flutter2_products` ADD CONSTRAINT `chk_price_positive` CHECK (`price` >= 0);
ALTER TABLE `flutter2_products` ADD CONSTRAINT `chk_stock_non_negative` CHECK (`stock` >= 0);
ALTER TABLE `flutter2_cart` ADD CONSTRAINT `chk_cart_quantity_positive` CHECK (`quantity` > 0);
ALTER TABLE `flutter2_order_items` ADD CONSTRAINT `chk_order_item_quantity_positive` CHECK (`quantity` > 0);
ALTER TABLE `flutter2_order_items` ADD CONSTRAINT `chk_order_item_price_positive` CHECK (`price` >= 0);
ALTER TABLE `flutter2_orders` ADD CONSTRAINT `chk_order_total_positive` CHECK (`total_amount` >= 0);

-- Add triggers for automatic stock updates
DELIMITER $$
CREATE TRIGGER `update_stock_on_order` AFTER INSERT ON `flutter2_order_items`
FOR EACH ROW
BEGIN
    UPDATE `flutter2_products` 
    SET `stock` = `stock` - NEW.`quantity`
    WHERE `id` = NEW.`product_id`;
END$$
DELIMITER ;

-- Add views for easier data access

-- View for product inventory status
CREATE VIEW `product_inventory_view` AS
SELECT 
    p.id,
    p.name,
    p.description,
    p.price,
    c.name as category_name,
    p.stock,
    p.is_active,
    CASE 
        WHEN p.stock = 0 THEN 'out_of_stock'
        WHEN p.stock <= 5 THEN 'low_stock'
        ELSE 'in_stock'
    END as stock_status
FROM `flutter2_products` p
JOIN `flutter2_categories` c ON p.category_id = c.id;

-- View for order summary
CREATE VIEW `order_summary_view` AS
SELECT 
    o.id,
    o.user_id,
    o.customer_name,
    o.customer_email,
    o.total_amount,
    o.status,
    o.payment_method,
    o.payment_status,
    o.created_at,
    COUNT(oi.id) as item_count
FROM `flutter2_orders` o
LEFT JOIN `flutter2_order_items` oi ON o.id = oi.order_id
GROUP BY o.id;

-- View for sales analytics
CREATE VIEW `sales_analytics_view` AS
SELECT 
    DATE(o.created_at) as order_date,
    COUNT(o.id) as order_count,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    COUNT(DISTINCT o.user_id) as unique_customers
FROM `flutter2_orders` o
WHERE o.status NOT IN ('cancelled')
GROUP BY DATE(o.created_at)
ORDER BY order_date DESC;