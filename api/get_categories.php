<?php
/**
 * Get Categories API Endpoint
 * Returns a list of all product categories
 */

require_once 'db_connect.php';

try {
    // SQL query to get all categories
    $sql = "SELECT
                id,
                name,
                description,
                created_at,
                updated_at
            FROM flutter2_categories
            ORDER BY name ASC";
    
    $categories = fetchData($sql);
    
    // Return success response
    echo json_encode([
        'success' => true,
        'message' => 'Categories retrieved successfully',
        'data' => $categories
    ]);
    
} catch (Exception $e) {
    // Return error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error retrieving categories: ' . $e->getMessage(),
        'data' => []
    ]);
}