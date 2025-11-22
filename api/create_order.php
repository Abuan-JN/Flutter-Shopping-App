<?php
// Create Order API Endpoint
// Handles order creation from cart items

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_connect.php';

// Check if request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed. Use POST method.'
    ]);
    exit;
}

// Get input data
$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required_fields = [
    'customer_name' => 'Customer name',
    'customer_email' => 'Customer email',
    'customer_address' => 'Customer address',
    'session_id' => 'Session ID'
];

foreach ($required_fields as $field => $field_name) {
    if (!isset($input[$field]) || empty(trim($input[$field]))) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => $field_name . ' is required.'
        ]);
        exit;
    }
}

// Extract and sanitize input data
$customer_name = trim($input['customer_name']);
$customer_email = trim($input['customer_email']);
$customer_phone = isset($input['customer_phone']) ? trim($input['customer_phone']) : '';
$customer_address = trim($input['customer_address']);
$session_id = trim($input['session_id']);
$user_id = isset($input['user_id']) ? intval($input['user_id']) : null;

// Validate email format
if (!filter_var($customer_email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email format.'
    ]);
    exit;
}

// Validate name length
if (strlen($customer_name) < 2 || strlen($customer_name) > 100) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Customer name must be between 2 and 100 characters.'
    ]);
    exit;
}

// Validate address length
if (strlen($customer_address) < 5 || strlen($customer_address) > 500) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Customer address must be between 5 and 500 characters.'
    ]);
    exit;
}

try {
    // Start transaction
    $pdo->beginTransaction();
    
    // Get cart items for this session
    $stmt = $pdo->prepare("
        SELECT 
            c.id as cart_id,
            c.product_id,
            c.quantity,
            c.session_id,
            p.name,
            p.price,
            p.stock
        FROM flutter2_cart c
        JOIN flutter2_products p ON c.product_id = p.id
        WHERE c.session_id = ? AND p.is_active = 1
    ");
    $stmt->execute([$session_id]);
    $cart_items = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Check if cart is empty
    if (empty($cart_items)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Cannot create order: Cart is empty.'
        ]);
        exit;
    }
    
    // Validate stock availability for all items
    $stock_issues = [];
    $total_amount = 0;
    
    foreach ($cart_items as $item) {
        if ($item['stock'] < $item['quantity']) {
            $stock_issues[] = [
                'product_name' => $item['name'],
                'requested' => $item['quantity'],
                'available' => $item['stock']
            ];
        }
        $total_amount += $item['price'] * $item['quantity'];
    }
    
    // Return error if stock issues found
    if (!empty($stock_issues)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Stock availability issues. Please update your cart.',
            'data' => [
                'stock_issues' => $stock_issues
            ]
        ]);
        exit;
    }
    
    // Create order
    $stmt = $pdo->prepare("
        INSERT INTO flutter2_orders (
            user_id, session_id, customer_name, customer_email, 
            customer_phone, customer_address, total_amount, status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')
    ");
    
    $stmt->execute([
        $user_id, $session_id, $customer_name, $customer_email,
        $customer_phone, $customer_address, $total_amount
    ]);
    
    $order_id = $pdo->lastInsertId();
    
    // Create order items and update stock
    foreach ($cart_items as $item) {
        // Insert order item
        $stmt = $pdo->prepare("
            INSERT INTO flutter2_order_items (order_id, product_id, quantity, price)
            VALUES (?, ?, ?, ?)
        ");
        $stmt->execute([
            $order_id, 
            $item['product_id'], 
            $item['quantity'], 
            $item['price']
        ]);
        
        // Update product stock
        $stmt = $pdo->prepare("UPDATE flutter2_products SET stock = stock - ? WHERE id = ?");
        $stmt->execute([$item['quantity'], $item['product_id']]);
    }
    
    // Clear cart after successful order
    $stmt = $pdo->prepare("DELETE FROM flutter2_cart WHERE session_id = ?");
    $stmt->execute([$session_id]);
    
    // Commit transaction
    $pdo->commit();
    
    // Get created order details
    $stmt = $pdo->prepare("
        SELECT 
            o.id,
            o.user_id,
            o.session_id,
            o.customer_name,
            o.customer_email,
            o.customer_phone,
            o.customer_address,
            o.total_amount,
            o.status,
            o.created_at,
            o.updated_at,
            COUNT(oi.id) as item_count
        FROM flutter2_orders o
        LEFT JOIN flutter2_order_items oi ON o.id = oi.order_id
        WHERE o.id = ?
        GROUP BY o.id
    ");
    $stmt->execute([$order_id]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'Order created successfully.',
        'data' => [
            'order' => $order,
            'order_items' => array_map(function($item) {
                return [
                    'product_id' => $item['product_id'],
                    'product_name' => $item['name'],
                    'quantity' => $item['quantity'],
                    'price' => (float)$item['price'],
                    'total_price' => (float)number_format($item['price'] * $item['quantity'], 2)
                ];
            }, $cart_items)
        ]
    ]);
    
} catch (Exception $e) {
    // Rollback transaction on error
    if ($pdo->inTransaction()) {
        $pdo->rollback();
    }
    
    error_log('Create order error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to create order. Please try again later.'
    ]);
}
?>