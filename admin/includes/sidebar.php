<?php
/**
 * Sidebar Navigation Include
 * Common sidebar for all admin pages
 */

require_once '../config/auth.php';

// Get current admin information
$admin = getCurrentAdmin();
?>

<!-- Sidebar -->
<div class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <h4>
            <i class="fas fa-shield-alt me-2"></i>
            Admin Panel
        </h4>
        <div class="mt-2">
            <small class="text-light opacity-75">
                Welcome, <?php echo htmlspecialchars($admin['name'] ?? 'Admin'); ?>
            </small>
        </div>
    </div>
    
    <div class="px-3">
        <div class="nav flex-column">
            <a class="nav-link <?php echo basename($_SERVER['PHP_SELF']) === 'index.php' ? 'active' : ''; ?>" href="index.php">
                <i class="fas fa-tachometer-alt"></i>
                Dashboard
            </a>
            <a class="nav-link <?php echo basename($_SERVER['PHP_SELF']) === 'users.php' ? 'active' : ''; ?>" href="users.php">
                <i class="fas fa-users"></i>
                User Management
            </a>
            <a class="nav-link <?php echo basename($_SERVER['PHP_SELF']) === 'orders.php' ? 'active' : ''; ?>" href="orders.php">
                <i class="fas fa-shopping-bag"></i>
                Orders
            </a>
            <a class="nav-link <?php echo basename($_SERVER['PHP_SELF']) === 'products.php' ? 'active' : ''; ?>" href="products.php">
                <i class="fas fa-box"></i>
                Products
            </a>
            <a class="nav-link <?php echo basename($_SERVER['PHP_SELF']) === 'categories.php' ? 'active' : ''; ?>" href="categories.php">
                <i class="fas fa-tags"></i>
                Categories
            </a>
            <a class="nav-link <?php echo basename($_SERVER['PHP_SELF']) === 'reports.php' ? 'active' : ''; ?>" href="reports.php">
                <i class="fas fa-chart-bar"></i>
                Reports
            </a>
            <a class="nav-link <?php echo basename($_SERVER['PHP_SELF']) === 'activity.php' ? 'active' : ''; ?>" href="activity.php">
                <i class="fas fa-history"></i>
                Activity Log
            </a>
            <a class="nav-link <?php echo basename($_SERVER['PHP_SELF']) === 'profile.php' ? 'active' : ''; ?>" href="profile.php">
                <i class="fas fa-user-cog"></i>
                Profile
            </a>
            <hr class="text-light opacity-25">
            <a class="nav-link text-danger" href="logout.php">
                <i class="fas fa-sign-out-alt"></i>
                Logout
            </a>
        </div>
    </div>
</div>