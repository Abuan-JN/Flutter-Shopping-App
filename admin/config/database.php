<?php
/**
 * Database configuration and connection
 * Secure PDO connection for admin dashboard
 * Uses centralized database configuration from API
 */

// Include centralized database connection from API
require_once '../api/db_connect.php';

/**
 * Create and return a secure PDO database connection
 * Uses the centralized connection from api/db_connect.php
 *
 * @return PDO Database connection object
 * @throws Exception If connection fails
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
        
        $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        
        return $pdo;
    } catch (PDOException $e) {
        error_log("Database connection failed: " . $e->getMessage());
        throw new Exception("Database connection error. Please try again later.");
    }
}

/**
 * Close database connection
 *
 * @param PDO $pdo Database connection to close
 */
function closeDBConnection($pdo) {
    $pdo = null;
}

/**
 * Get database connection using centralized API connection
 * This function uses the global $pdo from api/db_connect.php
 *
 * @return PDO Database connection object from centralized config
 */
function getCentralizedDBConnection() {
    global $pdo;
    
    // Test connection
    try {
        $pdo->query("SELECT 1");
        return $pdo;
    } catch (PDOException $e) {
        // Connection lost, recreate it
        return getDBConnection();
    }
}