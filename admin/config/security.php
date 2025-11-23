<?php
/**
 * Security functions for admin dashboard
 * Includes password hashing, CSRF protection, and input validation
 */

/**
 * Hash a password using bcrypt
 * 
 * @param string $password Plain text password
 * @return string Hashed password
 */
function hashPassword($password) {
    if (empty($password)) {
        throw new InvalidArgumentException("Password cannot be empty");
    }
    
    return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
}

/**
 * Verify a password against its hash
 * 
 * @param string $password Plain text password
 * @param string $hash Hashed password
 * @return bool True if password matches, false otherwise
 */
function verifyPassword($password, $hash) {
    if (empty($password) || empty($hash)) {
        return false;
    }
    
    return password_verify($password, $hash);
}

/**
 * Generate CSRF token and store it in session
 * 
 * @return string CSRF token
 */
function generateCSRFToken() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    $token = bin2hex(random_bytes(32));
    $_SESSION['csrf_token'] = $token;
    $_SESSION['csrf_token_time'] = time();
    
    return $token;
}

/**
 * Validate CSRF token
 * 
 * @param string $token CSRF token to validate
 * @return bool True if token is valid, false otherwise
 */
function validateCSRFToken($token) {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    // Check if token exists in session
    if (!isset($_SESSION['csrf_token']) || !isset($_SESSION['csrf_token_time'])) {
        return false;
    }
    
    // Check if token has expired (1 hour limit)
    $tokenAge = time() - $_SESSION['csrf_token_time'];
    if ($tokenAge > 3600) { // 1 hour
        unset($_SESSION['csrf_token']);
        unset($_SESSION['csrf_token_time']);
        return false;
    }
    
    // Verify token
    $isValid = hash_equals($_SESSION['csrf_token'], $token);
    
    // Optional: Regenerate token after use (for sensitive operations)
    if ($isValid) {
        generateCSRFToken();
    }
    
    return $isValid;
}

/**
 * Sanitize input data
 * 
 * @param string $input Input data to sanitize
 * @return string Sanitized input
 */
function sanitizeInput($input) {
    if (is_array($input)) {
        return array_map('sanitizeInput', $input);
    }
    
    $input = trim($input);
    $input = stripslashes($input);
    $input = htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
    
    return $input;
}

/**
 * Validate email format
 * 
 * @param string $email Email address to validate
 * @return bool True if email is valid, false otherwise
 */
function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

/**
 * Validate password strength
 * 
 * @param string $password Password to validate
 * @return array Validation result with success status and messages
 */
function validatePassword($password) {
    $errors = [];
    
    if (strlen($password) < 8) {
        $errors[] = "Password must be at least 8 characters long";
    }
    
    if (!preg_match('/[a-z]/', $password)) {
        $errors[] = "Password must contain at least one lowercase letter";
    }
    
    if (!preg_match('/[A-Z]/', $password)) {
        $errors[] = "Password must contain at least one uppercase letter";
    }
    
    if (!preg_match('/[0-9]/', $password)) {
        $errors[] = "Password must contain at least one number";
    }
    
    if (!preg_match('/[^a-zA-Z0-9]/', $password)) {
        $errors[] = "Password must contain at least one special character";
    }
    
    return [
        'valid' => empty($errors),
        'errors' => $errors
    ];
}

/**
 * Log security events
 * 
 * @param string $event_type Type of security event
 * @param string $description Description of the event
 * @param int|null $user_id User ID (if applicable)
 * @param string $ip IP address
 * @param string $user_agent User agent string
 */
function logSecurityEvent($event_type, $description, $user_id = null, $ip = null, $user_agent = null) {
    global $pdo;
    
    try {
        $ip = $ip ?: $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $user_agent = $user_agent ?: $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
        
        $stmt = $pdo->prepare("
            INSERT INTO security_logs (event_type, description, user_id, ip_address, user_agent, created_at)
            VALUES (?, ?, ?, ?, ?, NOW())
        ");
        
        $stmt->execute([$event_type, $description, $user_id, $ip, $user_agent]);
    } catch (Exception $e) {
        // Log to error log if database logging fails
        error_log("Failed to log security event: " . $e->getMessage());
    }
}

/**
 * Check if user is rate limited
 * 
 * @param string $identifier Unique identifier (IP, email, etc.)
 * @param string $action Action being performed
 * @param int $max_attempts Maximum attempts allowed
 * @param int $time_window Time window in seconds
 * @return bool True if rate limited, false otherwise
 */
function isRateLimited($identifier, $action, $max_attempts = 5, $time_window = 300) {
    global $pdo;
    
    try {
        $cutoff_time = date('Y-m-d H:i:s', time() - $time_window);
        
        $stmt = $pdo->prepare("
            SELECT COUNT(*) as attempts
            FROM security_logs 
            WHERE event_type = ? AND description LIKE ? AND created_at > ?
        ");
        
        $stmt->execute([$action, "%$identifier%", $cutoff_time]);
        $result = $stmt->fetch();
        
        return $result['attempts'] >= $max_attempts;
    } catch (Exception $e) {
        error_log("Rate limiting check failed: " . $e->getMessage());
        return false; // Fail open for availability
    }
}