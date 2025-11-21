<?php
// Remove Cart Item API Endpoint
// Handles removing items from the shopping cart

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_connect.php';

// Check if request method is POST or DELETE
if (!in_array($_SERVER['REQUEST_METHOD'], ['POST', 'DELETE'])) {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed. Use POST or DELETE method.'
    ]);
    exit;
}

// Get input data
$input = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($input['cart_item_id']) && !isset($input['product_id'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Cart item ID or product ID is required.'
    ]);
    exit;
}

$cart_item_id = isset($input['cart_item_id']) ? intval($input['cart_item_id']) : null;
$product_id = isset($input['product_id']) ? intval($input['product_id']) : null;
$session_id = isset($input['session_id']) ? trim($input['session_id']) : '';

// Validate IDs
if (($cart_item_id !== null && $cart_item_id <= 0) && ($product_id !== null && $product_id <= 0)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid cart item ID or product ID.'
    ]);
    exit;
}

if (empty($session_id)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Session ID is required.'
    ]);
    exit;
}

try {
    // Determine which item to remove
    $item_to_remove = null;
    
    if ($cart_item_id !== null) {
        // Remove by cart item ID
        $stmt = $pdo->prepare("SELECT * FROM flutter2_cart WHERE id = ? AND session_id = ?");
        $stmt->execute([$cart_item_id, $session_id]);
        $item_to_remove = $stmt->fetch(PDO::FETCH_ASSOC);
    } else {
        // Remove by product ID
        $stmt = $pdo->prepare("SELECT * FROM flutter2_cart WHERE product_id = ? AND session_id = ?");
        $stmt->execute([$product_id, $session_id]);
        $item_to_remove = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    // Check if item exists
    if (!$item_to_remove) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Cart item not found.'
        ]);
        exit;
    }
    
    // Remove the item
    if ($cart_item_id !== null) {
        $stmt = $pdo->prepare("DELETE FROM flutter2_cart WHERE id = ?");
        $stmt->execute([$cart_item_id]);
    } else {
        $stmt = $pdo->prepare("DELETE FROM flutter2_cart WHERE product_id = ? AND session_id = ?");
        $stmt->execute([$product_id, $session_id]);
    }
    
    // Get updated cart total
    $stmt = $pdo->prepare("
        SELECT 
            c.id,
            c.product_id,
            c.quantity,
            c.session_id,
            c.created_at,
            c.updated_at,
            p.name,
            p.price,
            c.quantity * p.price as total_price
        FROM flutter2_cart c
        JOIN flutter2_products p ON c.product_id = p.id
        WHERE c.session_id = ? AND p.is_active = 1
    ");
    $stmt->execute([$session_id]);
    $cart_items = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $cart_count = 0;
    $cart_total = 0.0;
    
    if (!empty($cart_items)) {
        $quantities = array_column($cart_items, 'quantity');
        $totals = array_column($cart_items, 'total_price');
        
        $cart_count = array_sum($quantities);
        $cart_total = array_sum($totals);
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Item removed from cart successfully.',
        'data' => [
            'removed_item' => [
                'cart_item_id' => $item_to_remove['id'],
                'product_id' => $item_to_remove['product_id'],
                'quantity' => $item_to_remove['quantity']
            ],
            'session_id' => $session_id,
            'cart_count' => $cart_count,
            'cart_total' => (float)number_format($cart_total, 2)
        ]
    ]);
    
} catch (PDOException $e) {
    error_log('Remove cart item error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error. Please try again later.'
    ]);
} catch (Exception $e) {
    error_log('Remove cart item exception: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An unexpected error occurred.'
    ]);
}
?>