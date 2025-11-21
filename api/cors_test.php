<?php
/**
 * CORS Test Endpoint
 * This file helps debug CORS issues by providing detailed information
 * about the request and response headers.
 */

// Handle preflight OPTIONS requests immediately
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Origin, Accept');
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400');
    header('Vary: Origin');
    header('Content-Type: application/json');
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'CORS preflight successful',
        'data' => [
            'status' => 'preflight_handled',
            'timestamp' => date('Y-m-d H:i:s'),
            'request_method' => $_SERVER['REQUEST_METHOD']
        ]
    ]);
    exit();
}

// Set CORS headers for actual requests
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Origin, Accept');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Max-Age: 86400');
header('Vary: Origin');
header('Content-Type: application/json');

// Collect request information
$requestInfo = [
    'request_method' => $_SERVER['REQUEST_METHOD'] ?? 'Unknown',
    'request_uri' => $_SERVER['REQUEST_URI'] ?? 'Unknown',
    'origin' => $_SERVER['HTTP_ORIGIN'] ?? 'Not provided',
    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Not provided',
    'content_type' => $_SERVER['CONTENT_TYPE'] ?? 'Not provided',
    'headers' => []
];

// Collect all request headers
foreach ($_SERVER as $key => $value) {
    if (strpos($key, 'HTTP_') === 0) {
        $headerName = str_replace('HTTP_', '', $key);
        $headerName = str_replace('_', '-', $headerName);
        $requestInfo['headers'][$headerName] = $value;
    }
}

// Check for specific CORS-related headers
$corsStatus = [
    'has_origin_header' => isset($_SERVER['HTTP_ORIGIN']),
    'has_access_control_request_method' => isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']),
    'has_access_control_request_headers' => isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']),
    'is_preflight' => $_SERVER['REQUEST_METHOD'] === 'OPTIONS'
];

$response = [
    'success' => true,
    'message' => 'CORS test completed successfully',
    'data' => [
        'timestamp' => date('Y-m-d H:i:s'),
        'server_info' => [
            'php_version' => PHP_VERSION,
            'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
            'server_protocol' => $_SERVER['SERVER_PROTOCOL'] ?? 'Unknown'
        ],
        'request_info' => $requestInfo,
        'cors_status' => $corsStatus,
        'instructions' => [
            'To test CORS, make a POST request to this endpoint',
            'Check the browser console for any CORS errors',
            'Verify that all required headers are present in the response'
        ]
    ]
];

echo json_encode($response, JSON_PRETTY_PRINT);
?>