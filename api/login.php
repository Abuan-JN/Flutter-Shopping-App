<?php
// Admin Login API Endpoint
// Handles admin authentication requests

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
if (!isset($input['username']) || !isset($input['password'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Username and password are required.'
    ]);
    exit;
}

$username = trim($input['username']);
$password = $input['password'];

// Validate input length
if (strlen($username) < 3 || strlen($username) > 50) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Username must be between 3 and 50 characters.'
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
    $stmt = $pdo->prepare("SELECT id, username, password, email, created_at FROM flutter2_users WHERE username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Check if user exists
    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid username or password.'
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