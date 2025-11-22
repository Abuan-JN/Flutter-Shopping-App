<?php
// Admin Login API Endpoint
// Handles admin authentication requests

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

// Validate input
if (!isset($input['email']) || !isset($input['password'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Email and password are required.'
    ]);
    exit;
}

$email = trim($input['email']);
$password = $input['password'];

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Please enter a valid email address.'
    ]);
    exit;
}

if (strlen($password) < 1) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Password is required.'
    ]);
    exit;
}

try {
    // Prepare SQL statement to fetch user
    $stmt = $pdo->prepare("SELECT id, name, email, phone, address, password, role, created_at FROM flutter2_users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Check if user exists
    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid email or password.'
        ]);
        exit;
    }
    
    // Verify password (assuming password is hashed using password_hash())
    if (!password_verify($password, $user['password'])) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid username or password.'
        ]);
        exit;
    }
    
    // Remove password from response
    unset($user['password']);
    
    // Generate a simple token (in production, use JWT or similar)
    $token = bin2hex(random_bytes(32));
    
    // Store token in database (you might want to add a tokens table)
    // For now, we'll just return success without persistent token storage
    // In a production app, you'd want to store this token with expiration
    
    echo json_encode([
        'success' => true,
        'message' => 'Login successful.',
        'data' => [
            'user' => $user,
            'token' => $token,
            'token_expires_in' => 3600 // 1 hour
        ]
    ]);
    
} catch (PDOException $e) {
    error_log('Login error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error. Please try again later.'
    ]);
} catch (Exception $e) {
    error_log('Login exception: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An unexpected error occurred.'
    ]);
}
?>