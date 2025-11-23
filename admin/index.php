<?php
/**
 * Admin Dashboard Main Page
 * Secure dashboard with navigation and admin features
 */

require_once 'config/auth.php';

// Require authentication for this page
requireAuth();

// Get current admin information
$admin = getCurrentAdmin();

// Get database connection using centralized API config
require_once 'config/database.php';
$pdo = getCentralizedDBConnection();

// Get statistics for dashboard
try {
    // Total users
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM flutter2_users WHERE role = 'customer'");
    $totalUsers = $stmt->fetch()['total'];
    
    // Total orders
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM flutter2_orders");
    $totalOrders = $stmt->fetch()['total'];
    
    // Total revenue
    $stmt = $pdo->query("SELECT COALESCE(SUM(total_amount), 0) as total FROM flutter2_orders WHERE status NOT IN ('cancelled')");
    $totalRevenue = $stmt->fetch()['total'];
    
    // Recent orders
    $stmt = $pdo->prepare("
        SELECT o.id, o.customer_name, o.total_amount, o.status, o.created_at, COUNT(oi.id) as item_count
        FROM flutter2_orders o
        LEFT JOIN flutter2_order_items oi ON o.id = oi.order_id
        GROUP BY o.id
        ORDER BY o.created_at DESC
        LIMIT 5
    ");
    $recentOrders = $stmt->execute() ? $stmt->fetchAll() : [];
    
    // Recent security events
    $stmt = $pdo->prepare("
        SELECT event_type, description, user_name, created_at
        FROM recent_security_events
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT 5
    ");
    $stmt->execute([$admin['id']]);
    $recentActivity = $stmt->fetchAll();
    
} catch (Exception $e) {
    error_log("Dashboard statistics query failed: " . $e->getMessage());
    $totalUsers = 0;
    $totalOrders = 0;
    $totalRevenue = 0;
    $recentOrders = [];
    $recentActivity = [];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Shopping App</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <style>
        :root {
            --primary-color: #667eea;
            --secondary-color: #764ba2;
            --sidebar-width: 250px;
        }
        
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .sidebar {
            width: var(--sidebar-width);
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            min-height: 100vh;
            position: fixed;
            z-index: 1000;
            box-shadow: 5px 0 15px rgba(0, 0, 0, 0.1);
        }
        
        .sidebar-header {
            padding: 20px;
            color: white;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .nav-link {
            color: rgba(255, 255, 255, 0.8);
            margin: 5px 0;
            padding: 12px 20px;
            border-radius: 8px;
            transition: all 0.3s ease;
        }
        
        .nav-link:hover, .nav-link.active {
            color: white;
            background-color: rgba(255, 255, 255, 0.1);
            transform: translateX(5px);
        }
        
        .nav-link i {
            margin-right: 10px;
            font-size: 1.1em;
        }
        
        .main-content {
            margin-left: var(--sidebar-width);
            padding: 30px;
        }
        
        .header-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            border-left: 4px solid var(--primary-color);
            transition: transform 0.2s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--primary-color);
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            transition: transform 0.2s ease;
        }
        
        .card:hover {
            transform: translateY(-3px);
        }
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .table thead {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status-processing {
            background-color: #cff4fc;
            color: #055160;
        }
        
        .status-completed {
            background-color: #d1e7dd;
            color: #0f5132;
        }
        
        .status-cancelled {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }
            
            .sidebar.active {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h4>
                <i class="fas fa-shield-alt me-2"></i>
                Admin Panel
            </h4>
            <div class="mt-2">
                <small class="text-light opacity-75">
                    Welcome, <?php echo htmlspecialchars($admin['name']); ?>
                </small>
            </div>
        </div>
        
        <div class="px-3">
            <div class="nav flex-column">
                <a class="nav-link active" href="index.php">
                    <i class="fas fa-tachometer-alt"></i>
                    Dashboard
                </a>
                <a class="nav-link" href="users.php">
                    <i class="fas fa-users"></i>
                    User Management
                </a>
                <a class="nav-link" href="orders.php">
                    <i class="fas fa-shopping-bag"></i>
                    Orders
                </a>
                <a class="nav-link" href="products.php">
                    <i class="fas fa-box"></i>
                    Products
                </a>
                <a class="nav-link" href="categories.php">
                    <i class="fas fa-tags"></i>
                    Categories
                </a>
                <a class="nav-link" href="reports.php">
                    <i class="fas fa-chart-bar"></i>
                    Reports
                </a>
                <a class="nav-link" href="activity.php">
                    <i class="fas fa-history"></i>
                    Activity Log
                </a>
                <a class="nav-link" href="profile.php">
                    <i class="fas fa-user-cog"></i>
                    Profile
                </a>
                <a class="nav-link text-danger" href="logout.php">
                    <i class="fas fa-sign-out-alt"></i>
                    Logout
                </a>
            </div>
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="main-content">
        <!-- Header -->
        <div class="header-section">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="h2 mb-0 text-primary">
                        <i class="fas fa-tachometer-alt me-2"></i>
                        Admin Dashboard
                    </h1>
                    <p class="text-muted mb-0 mt-2">Overview of your shopping app</p>
                </div>
                <div class="col-md-6 text-md-end mt-3 mt-md-0">
                    <button class="btn btn-outline-primary" id="toggleSidebar">
                        <i class="fas fa-bars"></i>
                        Menu
                    </button>
                    <span class="badge bg-primary ms-2">
                        <i class="fas fa-circle me-1"></i>
                        Online
                    </span>
                </div>
            </div>
        </div>
        
        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3 mb-3">
                <div class="stat-card text-center">
                    <div class="stat-number"><?php echo number_format($totalUsers); ?></div>
                    <div class="stat-label">Total Users</div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="stat-card text-center">
                    <div class="stat-number"><?php echo number_format($totalOrders); ?></div>
                    <div class="stat-label">Total Orders</div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="stat-card text-center">
                    <div class="stat-number">$<?php echo number_format($totalRevenue, 2); ?></div>
                    <div class="stat-label">Total Revenue</div>
                </div>
            </div>
            <div class="col-md-3 mb-3">
                <div class="stat-card text-center">
                    <div class="stat-number"><?php echo date('H:i'); ?></div>
                    <div class="stat-label">Current Time</div>
                </div>
            </div>
        </div>
        
        <!-- Main Content Row -->
        <div class="row">
            <!-- Recent Orders -->
            <div class="col-lg-8 mb-4">
                <div class="card">
                    <div class="card-header bg-transparent border-0">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-shopping-bag me-2"></i>
                            Recent Orders
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Customer</th>
                                        <th>Amount</th>
                                        <th>Items</th>
                                        <th>Status</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($recentOrders as $order): ?>
                                    <tr>
                                        <td>#<?php echo htmlspecialchars($order['id']); ?></td>
                                        <td><?php echo htmlspecialchars($order['customer_name']); ?></td>
                                        <td class="text-primary fw-bold">$<?php echo number_format($order['total_amount'], 2); ?></td>
                                        <td><?php echo $order['item_count']; ?></td>
                                        <td>
                                            <span class="status-badge 
                                                <?php echo $order['status'] === 'completed' ? 'status-completed' : 
                                                       ($order['status'] === 'processing' ? 'status-processing' : 
                                                       ($order['status'] === 'cancelled' ? 'status-cancelled' : 'status-pending')); ?>">
                                                <?php echo htmlspecialchars(ucfirst($order['status'])); ?>
                                            </span>
                                        </td>
                                        <td><?php echo date('M j, Y', strtotime($order['created_at'])); ?></td>
                                    </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                        <div class="text-center mt-3">
                            <a href="orders.php" class="btn btn-primary btn-sm">
                                View All Orders <i class="fas fa-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Recent Activity -->
            <div class="col-lg-4 mb-4">
                <div class="card">
                    <div class="card-header bg-transparent border-0">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-history me-2"></i>
                            Recent Activity
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="activity-timeline">
                            <?php foreach ($recentActivity as $activity): ?>
                            <div class="d-flex mb-3">
                                <div class="flex-shrink-0">
                                    <div class="avatar-sm bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center">
                                        <i class="fas fa-<?php echo $activity['event_type'] === 'login_success' ? 'sign-in-alt' : 
                                                                   ($activity['event_type'] === 'logout' ? 'sign-out-alt' : 'info'); ?>"></i>
                                    </div>
                                </div>
                                <div class="flex-grow-1 ms-3">
                                    <h6 class="font-size-14 mb-1">
                                        <?php echo htmlspecialchars($activity['event_type']); ?>
                                    </h6>
                                    <p class="text-muted mb-1 font-size-12">
                                        <?php echo htmlspecialchars(substr($activity['description'], 0, 50)); ?>
                                        <?php echo strlen($activity['description']) > 50 ? '...' : ''; ?>
                                    </p>
                                    <p class="text-muted font-size-11 mb-0">
                                        <i class="far fa-clock me-1"></i>
                                        <?php echo date('M j, Y H:i', strtotime($activity['created_at'])); ?>
                                    </p>
                                </div>
                            </div>
                            <?php endforeach; ?>
                        </div>
                        <div class="text-center mt-3">
                            <a href="activity.php" class="btn btn-outline-primary btn-sm">
                                View All Activity <i class="fas fa-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Mobile sidebar toggle
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('active');
        });
        
        // Auto-refresh dashboard every 5 minutes
        setInterval(function() {
            location.reload();
        }, 300000);
    </script>
</body>
</html>