<?php
/**
 * Centralized Database Connection Configuration
 * This file serves as the single source of truth for database connections
 * Used by both admin dashboard and API endpoints
 */

// Database configuration - Update these values for your environment
define('DB_HOST', 'fdb1034.awardspace.net');
define('DB_NAME', '4669819_data');
define('DB_USER', '4669819_data');
define('DB_PASS', 'Dcejit9gwGbDJO');

// For local development, use these settings:
// define('DB_HOST', 'localhost');
// define('DB_NAME', 'shopping_app');
// define('DB_USER', 'root');
// define('DB_PASS', '');

// Create connection
try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    
    // Set the PDO error mode to exception
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Optional: Set default fetch mode
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
    // Optional: Enable persistent connections for better performance
    $pdo->setAttribute(PDO::ATTR_PERSISTENT, true);
    
} catch(PDOException $e) {
    // For admin dashboard, log error and show user-friendly message
    if (strpos($_SERVER['PHP_SELF'], 'admin') !== false) {
        error_log("Admin Database connection failed: " . $e->getMessage());
        die("Database connection error. Please contact administrator.");
    } else {
        // For API, return JSON error response
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed: ' . $e->getMessage()
        ]);
        exit();
    }
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

/**
 * Function to get a new database connection (alternative to global $pdo)
 * @return PDO Database connection object
 */
function getDBConnection() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4";
        
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::ATTR_PERSISTENT         => true,
        ];
        
        return new PDO($dsn, DB_USER, DB_PASS, $options);
    } catch (PDOException $e) {
        error_log("Database connection failed: " . $e->getMessage());
        throw new Exception("Database connection error. Please try again later.");
    }
}