<?php
/**
 * Get Products API Endpoint
 * Returns a list of all active products with their categories
 */

require_once 'db_connect.php';

try {
    // SQL query to get products with category information
    $sql = "SELECT
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
            WHERE p.is_active = 1
            ORDER BY p.created_at DESC";
    
    $products = fetchData($sql);
    
    // Return success response
    echo json_encode([
        'success' => true,
        'message' => 'Products retrieved successfully',
        'data' => $products
    ]);
    
} catch (Exception $e) {
    // Return error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error retrieving products: ' . $e->getMessage(),
        'data' => []
    ]);
}