<?php
/**
 * Delete Product API Endpoint
 * Deletes a product from the database
 */

require_once 'db_connect.php';

// Set CORS headers for API access
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, DELETE');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit();
}

try {
    // Get POST/DELETE data
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Try to get product ID from request data
    $product_id = null;
    if (!empty($data['id'])) {
        $product_id = intval($data['id']);
    } elseif (!empty($_GET['id'])) {
        $product_id = intval($_GET['id']);
    } elseif (!empty($_POST['id'])) {
        $product_id = intval($_POST['id']);
    }
    
    // Validate product ID
    if (empty($product_id)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Product ID is required'
        ]);
        exit();
    }
    
    // Check if product exists
    $product_check = fetchData("SELECT id, name FROM flutter2_products WHERE id = ?", [$product_id]);
    if (empty($product_check)) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Product not found'
        ]);
        exit();
    }
    
    $product_name = $product_check[0]['name'];
    
    // Check if product has any orders
    $order_check = fetchData("SELECT COUNT(*) as order_count FROM flutter2_order_items WHERE product_id = ?", [$product_id]);
    if ($order_check[0]['order_count'] > 0) {
        // Instead of hard deleting, mark as inactive
        $sql = "UPDATE flutter2_products SET is_active = 0, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        $affected_rows = modifyData($sql, [$product_id]);
        
        if ($affected_rows > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Product marked as inactive (cannot be deleted due to existing orders)',
                'data' => [
                    'id' => $product_id,
                    'name' => $product_name
                ]
            ]);
        } else {
            throw new Exception('Failed to deactivate product');
        }
    } else {
        // Safe to hard delete
        $sql = "DELETE FROM flutter2_products WHERE id = ?";
        $affected_rows = modifyData($sql, [$product_id]);
        
        if ($affected_rows > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Product deleted successfully',
                'data' => [
                    'id' => $product_id,
                    'name' => $product_name
                ]
            ]);
        } else {
            throw new Exception('Failed to delete product');
        }
    }
    
} catch (Exception $e) {
    // Return error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error deleting product: ' . $e->getMessage()
    ]);
}