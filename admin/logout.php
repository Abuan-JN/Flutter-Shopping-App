<?php
/**
 * Admin Logout Handler
 * Secure logout with session cleanup and logging
 */

require_once 'config/auth.php';
require_once 'config/security.php';

// Perform logout
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Log logout if user was authenticated
if (isset($_SESSION['admin_id'])) {
    logSecurityEvent('logout', 'Admin logout from dashboard', $_SESSION['admin_id']);
}

// Clear all session data and destroy session
logoutAdmin();

// Redirect to login page
header('Location: login.php?logout=success');
exit();