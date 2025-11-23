<?php
/**
 * Authentication system for admin dashboard
 * Handles login, logout, session management, and access control
 */

require_once 'database.php';
require_once 'security.php';

/**
 * Start secure session with additional security measures
 */
function startSecureSession() {
    // Regenerate session ID to prevent session fixation
    if (session_status() === PHP_SESSION_NONE) {
        // Configure session security
        session_set_cookie_params([
            'lifetime' => 0,
            'path' => '/',
            'domain' => $_SERVER['HTTP_HOST'],
            'secure' => isset($_SERVER['HTTPS']),
            'httponly' => true,
            'samesite' => 'Strict'
        ]);
        
        session_start();
        
        // Regenerate session ID after login
        if (!isset($_SESSION['regenerated'])) {
            session_regenerate_id(true);
            $_SESSION['regenerated'] = true;
        }
    }
}

/**
 * Authenticate admin user
 * 
 * @param string $email User email
 * @param string $password User password
 * @return array Authentication result
 */
function authenticateAdmin($email, $password) {
    global $pdo;
    
    // Input validation
    if (empty($email) || empty($password)) {
        return [
            'success' => false,
            'message' => 'Please enter both email and password'
        ];
    }
    
    // Sanitize inputs
    $email = sanitizeInput($email);
    $password = sanitizeInput($password);
    
    // Rate limiting check
    if (isRateLimited($email, 'login_attempt', 5, 300)) {
        logSecurityEvent('rate_limited', "Login attempts exceeded for email: $email");
        return [
            'success' => false,
            'message' => 'Too many login attempts. Please try again later.'
        ];
    }
    
    try {
        // Check if user exists and is admin
        $stmt = $pdo->prepare("
            SELECT id, name, email, password, role, is_active, created_at
            FROM flutter2_users 
            WHERE email = ? AND role = 'admin' AND is_active = 1
        ");
        
        $stmt->execute([$email]);
        $user = $stmt->fetch();
        
        if (!$user) {
            logSecurityEvent('login_failed', "Admin login attempt with non-existent email: $email");
            return [
                'success' => false,
                'message' => 'Invalid email or password'
            ];
        }
        
        // Verify password
        if (!verifyPassword($password, $user['password'])) {
            logSecurityEvent('login_failed', "Admin login attempt with wrong password for email: $email", $user['id']);
            return [
                'success' => false,
                'message' => 'Invalid email or password'
            ];
        }
        
        // Successful login
        startSecureSession();
        
        // Store user data in session
        $_SESSION['admin_id'] = $user['id'];
        $_SESSION['admin_name'] = $user['name'];
        $_SESSION['admin_email'] = $user['email'];
        $_SESSION['admin_role'] = $user['role'];
        $_SESSION['login_time'] = time();
        $_SESSION['last_activity'] = time();
        
        // Generate CSRF token
        generateCSRFToken();
        
        // Log successful login
        logSecurityEvent('login_success', "Admin login successful for email: $email", $user['id']);
        
        return [
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email']
            ]
        ];
        
    } catch (Exception $e) {
        logSecurityEvent('suspicious_activity', "Database error during admin login: " . $e->getMessage());
        return [
            'success' => false,
            'message' => 'An error occurred. Please try again later.'
        ];
    }
}

/**
 * Check if user is logged in and session is valid
 * 
 * @return bool True if user is authenticated, false otherwise
 */
function isAdminAuthenticated() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    // Check if admin session exists
    if (!isset($_SESSION['admin_id'])) {
        return false;
    }
    
    // Check session timeout (2 hours of inactivity)
    $timeout = 7200; // 2 hours
    $last_activity = $_SESSION['last_activity'] ?? 0;
    
    if (time() - $last_activity > $timeout) {
        logoutAdmin();
        return false;
    }
    
    // Update last activity
    $_SESSION['last_activity'] = time();
    
    return true;
}

/**
 * Get current admin user information
 * 
 * @return array|null Admin user data or null if not logged in
 */
function getCurrentAdmin() {
    if (!isAdminAuthenticated()) {
        return null;
    }
    
    return [
        'id' => $_SESSION['admin_id'],
        'name' => $_SESSION['admin_name'],
        'email' => $_SESSION['admin_email'],
        'role' => $_SESSION['admin_role'],
        'login_time' => $_SESSION['login_time'],
        'last_activity' => $_SESSION['last_activity']
    ];
}

/**
 * Logout admin user
 */
function logoutAdmin() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    if (isset($_SESSION['admin_id'])) {
        $admin_id = $_SESSION['admin_id'];
        logSecurityEvent('logout', 'Admin logout', $admin_id);
    }
    
    // Destroy all session data
    $_SESSION = [];
    
    if (ini_get("session.use_cookies")) {
        $params = session_get_cookie_params();
        setcookie(
            session_name(),
            '',
            time() - 42000,
            $params["path"],
            $params["domain"],
            $params["secure"],
            $params["httponly"]
        );
    }
    
    session_destroy();
}

/**
 * Check if user has specific permission
 * 
 * @param string $permission Permission to check
 * @return bool True if user has permission, false otherwise
 */
function hasPermission($permission) {
    if (!isAdminAuthenticated()) {
        return false;
    }
    
    // For now, all admins have full access
    // This can be extended for role-based permissions
    return true;
}

/**
 * Redirect to login page if not authenticated
 */
function requireAuth() {
    if (!isAdminAuthenticated()) {
        header('Location: login.php');
        exit();
    }
}

/**
 * Redirect to dashboard if already authenticated
 */
function preventAuthAccess() {
    if (isAdminAuthenticated()) {
        header('Location: index.php');
        exit();
    }
}