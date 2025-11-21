<?php
/**
 * Add Product API Endpoint
 * Adds a new product to the database
 */

require_once 'db_connect.php';

// Set CORS headers for API access
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit();
}

try {
    // Get POST data
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (empty($data['name']) || empty($data['price']) || empty($data['category_id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Name, price, and category_id are required'
        ]);
        exit();
    }
    
    // Prepare product data
    $name = trim($data['name']);
    $description = !empty($data['description']) ? trim($data['description']) : null;
    $price = floatval($data['price']);
    $category_id = intval($data['category_id']);
    $image_url = !empty($data['image_url']) ? trim($data['image_url']) : null;
    $stock_quantity = !empty($data['stock_quantity']) ? intval($data['stock_quantity']) : 0;
    
    // Validate price
    if ($price < 0) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Price must be a positive number'
        ]);
        exit();
    }
    
    // Check if category exists
    $category_check = fetchData("SELECT id FROM categories WHERE id = ?", [$category_id]);
    if (empty($category_check)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid category ID'
        ]);
        exit();
    }
    
    // Insert product into database
    $sql = "INSERT INTO products (name, description, price, category_id, image_url, stock_quantity)
            VALUES (?, ?, ?, ?, ?, ?)";
    
    $affected_rows = modifyData($sql, [
        $name,
        $description,
        $price,
        $category_id,
        $image_url,
        $stock_quantity
    ]);
    
    if ($affected_rows > 0) {
        // Get the newly created product
        $product_id = $pdo->lastInsertId();
        $product = fetchData("SELECT 
                                p.id,
                                p.name,
                                p.description,
                                p.price,
                                p.category_id,
                                c.name as category_name,
                                p.image_url,
                                p.stock_quantity,
                                p.is_active,
                                p.created_at,
                                p.updated_at
                            FROM products p
                            LEFT JOIN categories c ON p.category_id = c.id
                            WHERE p.id = ?", [$product_id]);
        
        // Return success response
        echo json_encode([
            'success' => true,
            'message' => 'Product added successfully',
            'data' => $product[0]
        ]);
    } else {
        throw new Exception('Failed to add product');
    }
    
} catch (Exception $e) {
    // Return error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error adding product: ' . $e->getMessage()
    ]);
}