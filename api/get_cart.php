<?php
// Get Cart API Endpoint
// Retrieves all items in the shopping cart for a session

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_connect.php';

// Check if request method is GET or POST
if (!in_array($_SERVER['REQUEST_METHOD'], ['GET', 'POST'])) {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed.'
    ]);
    exit;
}

// Get session ID from query parameter or POST data
$session_id = '';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $session_id = isset($_GET['session_id']) ? trim($_GET['session_id']) : '';
} else {
    $input = json_decode(file_get_contents('php://input'), true);
    $session_id = isset($input['session_id']) ? trim($input['session_id']) : '';
}

// Validate session ID
if (empty($session_id)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Session ID is required.'
    ]);
    exit;
}

try {
    // Get cart items with product details
    $stmt = $pdo->prepare("
        SELECT 
            c.id as cart_item_id,
            c.product_id,
            c.quantity,
            c.session_id,
            c.created_at,
            c.updated_at,
            p.name,
            p.description,
            p.price,
            p.image,
            p.stock,
            p.category_id,
            c.quantity * p.price as total_price
        FROM flutter2_cart c
        JOIN flutter2_products p ON c.product_id = p.id
        WHERE c.session_id = ? AND p.is_active = 1
        ORDER BY c.created_at DESC
    ");
    $stmt->execute([$session_id]);
    $cart_items = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Calculate cart totals
    $cart_count = 0;
    $cart_total = 0.0;
    
    if (!empty($cart_items)) {
        $quantities = array_column($cart_items, 'quantity');
        $totals = array_column($cart_items, 'total_price');
        
        $cart_count = array_sum($quantities);
        $cart_total = array_sum($totals);
    }
    
    // Check for any items that might have stock issues
    $stock_warnings = [];
    foreach ($cart_items as $item) {
        if ($item['stock'] < $item['quantity']) {
            $stock_warnings[] = [
                'product_id' => $item['product_id'],
                'product_name' => $item['name'],
                'requested_quantity' => $item['quantity'],
                'available_quantity' => $item['stock'],
                'message' => 'Only ' . $item['stock'] . ' items available for ' . $item['name']
            ];
        }
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Cart retrieved successfully.',
        'data' => [
            'session_id' => $session_id,
            'cart_items' => $cart_items,
            'cart_count' => $cart_count,
            'cart_total' => (float)number_format($cart_total, 2),
            'stock_warnings' => $stock_warnings
        ]
    ]);
    
} catch (PDOException $e) {
    error_log('Get cart error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error. Please try again later.'
    ]);
} catch (Exception $e) {
    error_log('Get cart exception: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An unexpected error occurred.'
    ]);
}
?>