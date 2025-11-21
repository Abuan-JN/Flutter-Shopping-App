<?php
/**
 * Database Connection Configuration
 * This file handles the database connection for the shopping app
 */

// Database configuration
$host = 'fdb1034.awardspace.net'; // Update with your host
$dbname = '4669819_data'; // Update with your database name
$username = '4669819_data'; // Update with your database username
$password = 'Dcejit9gwGbDJO'; // Update with your database password

// Create connection
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    
    // Set the PDO error mode to exception
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Optional: Set default fetch mode
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
} catch(PDOException $e) {
    // Return error response
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]);
    exit();
}

/**
 * Function to safely prepare and execute SQL statements
 * @param string $sql SQL statement
 * @param array $params Parameters for the SQL statement
 * @return PDOStatement Prepared statement
 */
function executeQuery($sql, $params = []) {
    global $pdo;
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt;
}

/**
 * Function to safely prepare and execute SQL statements that return data
 * @param string $sql SQL statement
 * @param array $params Parameters for the SQL statement
 * @return array Result data
 */
function fetchData($sql, $params = []) {
    $stmt = executeQuery($sql, $params);
    return $stmt->fetchAll();
}

/**
 * Function to safely prepare and execute SQL statements that modify data
 * @param string $sql SQL statement
 * @param array $params Parameters for the SQL statement
 * @return int Number of affected rows
 */
function modifyData($sql, $params = []) {
    $stmt = executeQuery($sql, $params);
    return $stmt->rowCount();
}