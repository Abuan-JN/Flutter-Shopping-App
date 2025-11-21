<?php
/**
 * Update Product API Endpoint
 * Updates an existing product in the database
 */

require_once 'db_connect.php';

// Set CORS headers for API access
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, PUT');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'PUT') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit();
}

try {
    // Get POST/PUT data
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (empty($data['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Product ID is required'
        ]);
        exit();
    }
    
    $product_id = intval($data['id']);
    
    // Check if product exists
    $product_check = fetchData("SELECT id FROM flutter2_products WHERE id = ?", [$product_id]);
    if (empty($product_check)) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Product not found'
        ]);
        exit();
    }
    
    // Prepare update data
    $name = !empty($data['name']) ? trim($data['name']) : null;
    $description = !empty($data['description']) ? trim($data['description']) : null;
    $price = !empty($data['price']) ? floatval($data['price']) : null;
    $category_id = !empty($data['category_id']) ? intval($data['category_id']) : null;
    $image_url = !empty($data['image_url']) ? trim($data['image_url']) : null;
    $stock_quantity = isset($data['stock_quantity']) ? intval($data['stock_quantity']) : null;
    $is_active = !empty($data['is_active']) ? ($data['is_active'] ? 1 : 0) : null;
    
    // Build dynamic update query
    $update_fields = [];
    $params = [];
    
    if ($name !== null) {
        $update_fields[] = "name = ?";
        $params[] = $name;
    }
    if ($description !== null) {
        $update_fields[] = "description = ?";
        $params[] = $description;
    }
    if ($price !== null) {
        if ($price < 0) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Price must be a positive number'
            ]);
            exit();
        }
        $update_fields[] = "price = ?";
        $params[] = $price;
    }
    if ($category_id !== null) {
        // Check if category exists
        $category_check = fetchData("SELECT id FROM flutter2_categories WHERE id = ?", [$category_id]);
        if (empty($category_check)) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid category ID'
            ]);
            exit();
        }
        $update_fields[] = "category_id = ?";
        $params[] = $category_id;
    }
    if ($image_url !== null) {
        $update_fields[] = "image_url = ?";
        $params[] = $image_url;
    }
    if ($stock_quantity !== null) {
        $update_fields[] = "stock_quantity = ?";
        $params[] = $stock_quantity;
    }
    if ($is_active !== null) {
        $update_fields[] = "is_active = ?";
        $params[] = $is_active;
    }
    
    // If no fields to update
    if (empty($update_fields)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'No fields to update'
        ]);
        exit();
    }
    
    // Add product ID to params
    $params[] = $product_id;
    
    // Update product in database
    $sql = "UPDATE flutter2_products SET " . implode(', ', $update_fields) . ", updated_at = CURRENT_TIMESTAMP WHERE id = ?";
    
    $affected_rows = modifyData($sql, $params);
    
    if ($affected_rows > 0) {
        // Get the updated product
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
                            FROM flutter2_products p
                            LEFT JOIN flutter2_categories c ON p.category_id = c.id
                            WHERE p.id = ?", [$product_id]);
        
        // Return success response
        echo json_encode([
            'success' => true,
            'message' => 'Product updated successfully',
            'data' => $product[0]
        ]);
    } else {
        throw new Exception('Failed to update product');
    }
    
} catch (Exception $e) {
    // Return error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error updating product: ' . $e->getMessage()
    ]);
}