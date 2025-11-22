<?php
// Add to Cart API Endpoint
// Handles adding products to the shopping cart

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

// Validate input
if (!isset($input['product_id']) || !isset($input['quantity'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Product ID and quantity are required.'
    ]);
    exit;
}

$product_id = intval($input['product_id']);
$quantity = max(1, intval($input['quantity'])); // Ensure minimum quantity of 1
$session_id = isset($input['session_id']) ? trim($input['session_id']) : '';

// Validate input
if ($product_id <= 0) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid product ID.'
    ]);
    exit;
}

if ($quantity > 99) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Quantity cannot exceed 99.'
    ]);
    exit;
}

// Generate session ID if not provided (for guest users)
if (empty($session_id)) {
    $session_id = session_id();
    if (empty($session_id)) {
        $session_id = 'guest_' . bin2hex(random_bytes(16));
    }
}

try {
    // Check if product exists and is active
    $stmt = $pdo->prepare("SELECT id, name, price, stock FROM flutter2_products WHERE id = ? AND is_active = 1");
    $stmt->execute([$product_id]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$product) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Product not found or unavailable.'
        ]);
        exit;
    }
    
    // Check stock availability
    if ($product['stock'] < $quantity) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Insufficient stock. Only ' . $product['stock'] . ' items available.',
            'data' => [
                'available_quantity' => $product['stock']
            ]
        ]);
        exit;
    }
    
    // Check if item already exists in cart for this session
    $stmt = $pdo->prepare("SELECT id, quantity FROM flutter2_cart WHERE session_id = ? AND product_id = ?");
    $stmt->execute([$session_id, $product_id]);
    $existing_item = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($existing_item) {
        // Update existing cart item quantity
        $new_quantity = $existing_item['quantity'] + $quantity;
        
        // Check if new quantity exceeds stock
        if ($product['stock'] < $new_quantity) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Cannot add more items. Maximum available is ' . $product['stock'] . ' total.',
                'data' => [
                    'available_quantity' => $product['stock'],
                    'current_cart_quantity' => $existing_item['quantity']
                ]
            ]);
            exit;
        }
        
        $stmt = $pdo->prepare("UPDATE flutter2_cart SET quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?");
        $stmt->execute([$new_quantity, $existing_item['id']]);
        
        $action = 'updated';
        $cart_item_id = $existing_item['id'];
    } else {
        // Add new item to cart
        $stmt = $pdo->prepare("INSERT INTO flutter2_cart (session_id, product_id, quantity) VALUES (?, ?, ?)");
        $stmt->execute([$session_id, $product_id, $quantity]);
        
        $action = 'added';
        $cart_item_id = $pdo->lastInsertId();
    }
    
    // Get updated cart total
    $stmt = $pdo->prepare("
        SELECT 
            c.id,
            c.product_id,
            c.quantity,
            p.name,
            p.price,
            p.image,
            (c.quantity * p.price) as total_price
        FROM flutter2_cart c
        JOIN flutter2_products p ON c.product_id = p.id
        WHERE c.session_id = ?
    ");
    $stmt->execute([$session_id]);
    $cart_items = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $cart_total = array_sum(array_column($cart_items, 'total_price'));
    $cart_count = array_sum(array_column($cart_items, 'quantity'));
    
    echo json_encode([
        'success' => true,
        'message' => 'Item ' . $action . ' to cart successfully.',
        'data' => [
            'cart_item_id' => $cart_item_id,
            'session_id' => $session_id,
            'cart_count' => $cart_count,
            'cart_total' => (float)number_format($cart_total, 2),
            'item' => [
                'product_id' => $product_id,
                'name' => $product['name'],
                'quantity' => $quantity,
                'price' => (float)$product['price'],
                'total_price' => (float)number_format($quantity * $product['price'], 2)
            ]
        ]
    ]);
    
} catch (PDOException $e) {
    error_log('Add to cart error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error. Please try again later.'
    ]);
} catch (Exception $e) {
    error_log('Add to cart exception: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An unexpected error occurred.'
    ]);
}
?>