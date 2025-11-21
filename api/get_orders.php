<?php
// Get Orders API Endpoint
// Retrieves order history for admin viewing or customer order tracking

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

// Get parameters
$session_id = '';
$user_id = null;
$order_id = null;

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $session_id = isset($_GET['session_id']) ? trim($_GET['session_id']) : '';
    $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
    $order_id = isset($_GET['order_id']) ? intval($_GET['order_id']) : null;
} else {
    $input = json_decode(file_get_contents('php://input'), true);
    $session_id = isset($input['session_id']) ? trim($input['session_id']) : '';
    $user_id = isset($input['user_id']) ? intval($input['user_id']) : null;
    $order_id = isset($input['order_id']) ? intval($input['order_id']) : null;
}

// Validate parameters
if (empty($session_id) && $user_id === null && $order_id === null) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Session ID, User ID, or Order ID is required.'
    ]);
    exit;
}

try {
    $orders = [];
    
    if ($order_id !== null) {
        // Get specific order
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
                o.updated_at
            FROM flutter2_orders o
            WHERE o.id = ?
        ");
        $stmt->execute([$order_id]);
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } elseif ($user_id !== null) {
        // Get orders for specific user (admin or authenticated user)
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
            WHERE o.user_id = ?
            GROUP BY o.id
            ORDER BY o.created_at DESC
        ");
        $stmt->execute([$user_id]);
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } else {
        // Get orders for session (guest user)
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
            WHERE o.session_id = ?
            GROUP BY o.id
            ORDER BY o.created_at DESC
        ");
        $stmt->execute([$session_id]);
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    $order_details = [];
    
    foreach ($orders as $order) {
        // Get order items
        $stmt = $pdo->prepare("
            SELECT 
                oi.id,
                oi.product_id,
                oi.quantity,
                oi.price,
                oi.created_at,
                p.name as product_name,
                p.image_url
            FROM flutter2_order_items oi
            JOIN flutter2_products p ON oi.product_id = p.id
            WHERE oi.order_id = ?
        ");
        $stmt->execute([$order['id']]);
        $order_items = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Get order status history (if implemented)
        $status_history = [];
        
        $order_details[] = [
            'order' => [
                'id' => $order['id'],
                'user_id' => $order['user_id'],
                'session_id' => $order['session_id'],
                'customer_name' => $order['customer_name'],
                'customer_email' => $order['customer_email'],
                'customer_phone' => $order['customer_phone'],
                'customer_address' => $order['customer_address'],
                'total_amount' => (float)$order['total_amount'],
                'status' => $order['status'],
                'created_at' => $order['created_at'],
                'updated_at' => $order['updated_at'],
                'item_count' => $order['item_count'] ?? count($order_items)
            ],
            'items' => array_map(function($item) {
                return [
                    'id' => $item['id'],
                    'product_id' => $item['product_id'],
                    'product_name' => $item['product_name'],
                    'image_url' => $item['image_url'],
                    'quantity' => $item['quantity'],
                    'price' => (float)$item['price'],
                    'total_price' => (float)number_format($item['price'] * $item['quantity'], 2)
                ];
            }, $order_items),
            'status_history' => $status_history
        ];
    }
    
    // Get order statistics (for admin view)
    $stats = null;
    if ($user_id === null && $order_id === null) {
        // Only provide stats for admin session-based queries
        $stmt = $pdo->prepare("
            SELECT 
                COUNT(*) as total_orders,
                SUM(total_amount) as total_revenue,
                AVG(total_amount) as average_order_value,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_orders,
                COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_orders,
                COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_orders
            FROM flutter2_orders
        ");
        $stmt->execute();
        $stats_data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $stats = [
            'total_orders' => (int)$stats_data['total_orders'],
            'total_revenue' => (float)number_format($stats_data['total_revenue'] ?? 0, 2),
            'average_order_value' => (float)number_format($stats_data['average_order_value'] ?? 0, 2),
            'pending_orders' => (int)$stats_data['pending_orders'],
            'completed_orders' => (int)$stats_data['completed_orders'],
            'cancelled_orders' => (int)$stats_data['cancelled_orders']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Orders retrieved successfully.',
        'data' => [
            'orders' => $order_details,
            'statistics' => $stats,
            'count' => count($order_details)
        ]
    ]);
    
} catch (PDOException $e) {
    error_log('Get orders error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error. Please try again later.'
    ]);
} catch (Exception $e) {
    error_log('Get orders exception: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An unexpected error occurred.'
    ]);
}
?>