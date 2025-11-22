<?php
// Customer Registration API Endpoint
// Handles customer registration requests

// Handle preflight OPTIONS requests immediately
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // Clear any existing headers to prevent duplication
    if (function_exists('header_remove')) {
        header_remove('Access-Control-Allow-Origin');
        header_remove('Access-Control-Allow-Methods');
        header_remove('Access-Control-Allow-Headers');
        header_remove('Access-Control-Max-Age');
        header_remove('Access-Control-Allow-Credentials');
        header_remove('Vary');
    }
    
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Origin, Accept, Cache-Control, Pragma');
    header('Access-Control-Max-Age: 86400');
    header('Access-Control-Allow-Credentials: true');
    header('Vary: Origin');
    header('Content-Type: application/json');
    http_response_code(200);
    exit();
}

// Clear any existing CORS headers to prevent duplication with .htaccess
if (function_exists('header_remove')) {
    header_remove('Access-Control-Allow-Origin');
    header_remove('Access-Control-Allow-Methods');
    header_remove('Access-Control-Allow-Headers');
    header_remove('Access-Control-Max-Age');
    header_remove('Access-Control-Allow-Credentials');
    header_remove('Vary');
}

// Set CORS headers for actual requests (only if not set by .htaccess)
header('Access-Control-Allow-Origin: *', false);
header('Access-Control-Allow-Methods: POST, OPTIONS', false);
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Origin, Accept, Cache-Control, Pragma', false);
header('Access-Control-Max-Age: 86400', false);
header('Access-Control-Allow-Credentials: true', false);
header('Vary: Origin', false);
header('Content-Type: application/json');

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

// Validate input fields
$required_fields = ['name', 'email', 'phone', 'address', 'password'];
foreach ($required_fields as $field) {
    if (!isset($input[$field]) || empty(trim($input[$field]))) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => ucfirst($field) . ' is required.'
        ]);
        exit;
    }
}

$name = trim($input['name']);
$email = trim($input['email']);
$phone = trim($input['phone']);
$address = trim($input['address']);
$password = $input['password'];

// Validate name
if (strlen($name) < 2 || strlen($name) > 100) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Name must be between 2 and 100 characters.'
    ]);
    exit;
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Please enter a valid email address.'
    ]);
    exit;
}

// Validate phone number (Philippine format)
if (!preg_match('/^(09|\+639)\d{9}$/', $phone)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Please enter a valid Philippine phone number (09XXXXXXXXX or +639XXXXXXXXX).'
    ]);
    exit;
}

// Validate address
if (strlen($address) < 10) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Please enter a complete address (minimum 10 characters).'
    ]);
    exit;
}

// Validate password
if (strlen($password) < 6) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Password must be at least 6 characters long.'
    ]);
    exit;
}

try {
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT id FROM flutter2_users WHERE email = ?");
    $stmt->execute([$email]);
    
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'Email address is already registered.'
        ]);
        exit;
    }
    
    // Hash the password
    $password_hash = password_hash($password, PASSWORD_DEFAULT);
    
    // Insert new user
    $stmt = $pdo->prepare("INSERT INTO flutter2_users (name, email, phone, address, password, role, created_at) VALUES (?, ?, ?, ?, ?, 'customer', NOW())");
    $result = $stmt->execute([$name, $email, $phone, $address, $password_hash]);
    
    if ($result) {
        $user_id = $pdo->lastInsertId();
        
        // Remove password from response
        $user_data = [
            'id' => $user_id,
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'address' => $address,
            'role' => 'customer',
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        echo json_encode([
            'success' => true,
            'message' => 'Registration successful.',
            'data' => [
                'user' => $user_data
            ]
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Registration failed. Please try again.'
        ]);
    }
    
} catch (PDOException $e) {
    error_log('Registration error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error. Please try again later.'
    ]);
} catch (Exception $e) {
    error_log('Registration exception: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An unexpected error occurred.'
    ]);
}
?>