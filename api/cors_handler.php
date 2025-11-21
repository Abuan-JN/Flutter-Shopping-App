<?php
/**
 * CORS Handler Utility
 * Centralized CORS configuration for all API endpoints
 * Include this file at the top of each PHP API endpoint
 */

/**
 * Function to handle CORS preflight and set headers
 * @param string $allowedMethods Comma-separated list of allowed HTTP methods
 * @param string $allowedHeaders Comma-separated list of allowed headers
 */
function handleCors($allowedMethods = 'GET, POST, PUT, DELETE, OPTIONS', $allowedHeaders = 'Content-Type, Authorization, X-Requested-With, Origin, Accept') {
    // Handle preflight OPTIONS requests
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        // Get the Origin header from the request
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
        
        // Set CORS headers for preflight response
        header("Access-Control-Allow-Origin: $origin");
        header('Access-Control-Allow-Methods: ' . $allowedMethods);
        header('Access-Control-Allow-Headers: ' . $allowedHeaders);
        header('Access-Control-Max-Age: 86400'); // 24 hours cache
        header('Access-Control-Allow-Credentials: true'); // Allow credentials
        header('Vary: Origin'); // Important for caching
        header('Content-Type: application/json');
        
        // End the request here for OPTIONS
        http_response_code(200);
        exit();
    }
    
    // Set CORS headers for actual requests
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
    header("Access-Control-Allow-Origin: $origin");
    header('Access-Control-Allow-Methods: ' . $allowedMethods);
    header('Access-Control-Allow-Headers: ' . $allowedHeaders);
    header('Access-Control-Max-Age: 86400');
    header('Access-Control-Allow-Credentials: true');
    header('Vary: Origin');
    header('Content-Type: application/json');
}

/**
 * Function to validate origin (optional security enhancement)
 * @param string $origin The origin to validate
 * @return bool Whether the origin is allowed
 */
function isValidOrigin($origin) {
    // List of allowed origins (you can customize this)
    $allowedOrigins = [
        'http://abuanplmunflutter.sportsontheweb.net',
        'https://abuanplmunflutter.sportsontheweb.net',
        'http://localhost',
        'https://localhost',
        'capacitor://localhost',
        'ionic://localhost',
        'http://127.0.0.1',
        'https://127.0.0.1'
    ];
    
    return in_array($origin, $allowedOrigins) || empty($origin);
}

// Auto-handle CORS for common API patterns
if (isset($_SERVER['HTTP_ORIGIN'])) {
    $origin = $_SERVER['HTTP_ORIGIN'];
    
    // For security, you might want to validate the origin
    if (!isValidOrigin($origin)) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'Origin not allowed'
        ]);
        exit();
    }
}