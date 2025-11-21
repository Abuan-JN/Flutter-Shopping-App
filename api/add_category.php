<?php
/**
 * Add Category API Endpoint
 * Adds a new category to the database
 */

require_once 'db_connect.php';

// Set CORS headers for API access
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit();
}

try {
    // Get POST data
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (empty($data['name'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Category name is required'
        ]);
        exit();
    }
    
    // Prepare category data
    $name = trim($data['name']);
    $description = !empty($data['description']) ? trim($data['description']) : null;
    
    // Validate name length
    if (strlen($name) < 2) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Category name must be at least 2 characters long'
        ]);
        exit();
    }
    
    // Check if category name already exists
    $category_check = fetchData("SELECT id FROM flutter2_categories WHERE name = ?", [$name]);
    if (!empty($category_check)) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'Category with this name already exists'
        ]);
        exit();
    }
    
    // Insert category into database
    $sql = "INSERT INTO flutter2_categories (name, description)
            VALUES (?, ?)";
    
    $affected_rows = modifyData($sql, [
        $name,
        $description
    ]);
    
    if ($affected_rows > 0) {
        // Get the newly created category
        $category_id = $pdo->lastInsertId();
        $category = fetchData("SELECT
                                id,
                                name,
                                description,
                                created_at,
                                updated_at
                            FROM flutter2_categories
                            WHERE id = ?", [$category_id]);
        
        // Return success response
        echo json_encode([
            'success' => true,
            'message' => 'Category added successfully',
            'data' => $category[0]
        ]);
    } else {
        throw new Exception('Failed to add category');
    }
    
} catch (Exception $e) {
    // Return error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error adding category: ' . $e->getMessage()
    ]);
}