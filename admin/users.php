<?php
/**
 * User Management Page
 * Admin interface for managing customer users
 */

require_once 'config/auth.php';

// Require authentication for this page
requireAuth();

// Get current admin information
$admin = getCurrentAdmin();

// Get database connection using centralized API config
require_once 'config/database.php';
$pdo = getCentralizedDBConnection();

// Handle user actions (activate/deactivate)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    if (!validateCSRFToken($_POST['csrf_token'])) {
        $_SESSION['error'] = 'Invalid request. Please try again.';
        header('Location: users.php');
        exit();
    }
    
    $action = $_POST['action'];
    $user_id = intval($_POST['user_id'] ?? 0);
    
    if ($user_id > 0) {
        try {
            if ($action === 'activate') {
                $stmt = $pdo->prepare("UPDATE flutter2_users SET is_active = 1 WHERE id = ? AND role = 'customer'");
                $stmt->execute([$user_id]);
                $_SESSION['success'] = 'User activated successfully.';
                logSecurityEvent('user_management', "Admin {$admin['name']} activated user ID: $user_id", $admin['id']);
            } elseif ($action === 'deactivate') {
                $stmt = $pdo->prepare("UPDATE flutter2_users SET is_active = 0 WHERE id = ? AND role = 'customer'");
                $stmt->execute([$user_id]);
                $_SESSION['success'] = 'User deactivated successfully.';
                logSecurityEvent('user_management', "Admin {$admin['name']} deactivated user ID: $user_id", $admin['id']);
            }
        } catch (Exception $e) {
            $_SESSION['error'] = 'An error occurred while updating user status.';
            error_log("User management error: " . $e->getMessage());
        }
    }
    
    header('Location: users.php');
    exit();
}

// Get users data
try {
    $search = $_GET['search'] ?? '';
    $status = $_GET['status'] ?? '';
    
    $query = "
        SELECT u.id, u.name, u.email, u.phone, u.is_active, u.created_at, COUNT(o.id) as order_count
        FROM flutter2_users u
        LEFT JOIN flutter2_orders o ON u.id = o.user_id
        WHERE u.role = 'customer'
    ";
    
    $params = [];
    
    if (!empty($search)) {
        $query .= " AND (u.name LIKE ? OR u.email LIKE ?)";
        $searchParam = "%$search%";
        $params[] = $searchParam;
        $params[] = $searchParam;
    }
    
    if ($status === 'active') {
        $query .= " AND u.is_active = 1";
    } elseif ($status === 'inactive') {
        $query .= " AND u.is_active = 0";
    }
    
    $query .= " GROUP BY u.id ORDER BY u.created_at DESC";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $users = $stmt->fetchAll();
    
} catch (Exception $e) {
    $_SESSION['error'] = 'Failed to load users.';
    error_log("User query error: " . $e->getMessage());
    $users = [];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Admin Panel</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <!-- Include sidebar -->
    <?php include 'includes/sidebar.php'; ?>
    
    <!-- Main Content -->
    <div class="main-content">
        <!-- Header -->
        <div class="header-section">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="h2 mb-0 text-primary">
                        <i class="fas fa-users me-2"></i>
                        User Management
                    </h1>
                    <p class="text-muted mb-0 mt-2">Manage customer accounts and their status</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <button class="btn btn-primary" onclick="window.location.reload()">
                        <i class="fas fa-refresh me-2"></i>
                        Refresh
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Alerts -->
        <?php if (isset($_SESSION['success'])): ?>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <?php echo htmlspecialchars($_SESSION['success']); ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <?php unset($_SESSION['success']); ?>
        <?php endif; ?>
        
        <?php if (isset($_SESSION['error'])): ?>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i>
                <?php echo htmlspecialchars($_SESSION['error']); ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <?php unset($_SESSION['error']); ?>
        <?php endif; ?>
        
        <!-- Search and Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="GET" action="users.php" class="row g-3">
                    <div class="col-md-6">
                        <input type="text" class="form-control" name="search" placeholder="Search by name or email..." 
                               value="<?php echo htmlspecialchars($_GET['search'] ?? ''); ?>">
                    </div>
                    <div class="col-md-4">
                        <select class="form-select" name="status">
                            <option value="">All Users</option>
                            <option value="active" <?php echo ($_GET['status'] ?? '') === 'active' ? 'selected' : ''; ?>>
                                Active Users
                            </option>
                            <option value="inactive" <?php echo ($_GET['status'] ?? '') === 'inactive' ? 'selected' : ''; ?>>
                                Inactive Users
                            </option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search me-2"></i>
                            Search
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Users Table -->
        <div class="card">
            <div class="card-header bg-transparent border-0">
                <h5 class="card-title mb-0">
                    <i class="fas fa-user-friends me-2"></i>
                    Customer Users (<?php echo count($users); ?>)
                </h5>
            </div>
            <div class="card-body">
                <?php if (empty($users)): ?>
                    <div class="text-center py-5">
                        <i class="fas fa-users text-muted" style="font-size: 3rem;"></i>
                        <h5 class="text-muted mt-3">No users found</h5>
                        <p class="text-muted">Try adjusting your search criteria</p>
                    </div>
                <?php else: ?>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Orders</th>
                                    <th>Status</th>
                                    <th>Member Since</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($users as $user): ?>
                                <tr>
                                    <td><strong>#<?php echo $user['id']; ?></strong></td>
                                    <td>
                                        <div>
                                            <div class="fw-semibold"><?php echo htmlspecialchars($user['name']); ?></div>
                                        </div>
                                    </td>
                                    <td>
                                        <a href="mailto:<?php echo htmlspecialchars($user['email']); ?>">
                                            <?php echo htmlspecialchars($user['email']); ?>
                                        </a>
                                    </td>
                                    <td>
                                        <?php echo $user['phone'] ? htmlspecialchars($user['phone']) : '<span class="text-muted">Not provided</span>'; ?>
                                    </td>
                                    <td>
                                        <span class="badge bg-primary"><?php echo $user['order_count']; ?></span>
                                    </td>
                                    <td>
                                        <span class="badge <?php echo $user['is_active'] ? 'bg-success' : 'bg-danger'; ?>">
                                            <?php echo $user['is_active'] ? 'Active' : 'Inactive'; ?>
                                        </span>
                                    </td>
                                    <td><?php echo date('M j, Y', strtotime($user['created_at'])); ?></td>
                                    <td>
                                        <form method="POST" style="display: inline;" 
                                              onsubmit="return confirm('<?php echo $user['is_active'] ? 'Deactivate' : 'Activate'; ?> this user?')">
                                            <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                                            <input type="hidden" name="user_id" value="<?php echo $user['id']; ?>">
                                            <input type="hidden" name="action" value="<?php echo $user['is_active'] ? 'deactivate' : 'activate'; ?>">
                                            <button type="submit" class="btn btn-sm <?php echo $user['is_active'] ? 'btn-outline-danger' : 'btn-outline-success'; ?>">
                                                <i class="fas fa-<?php echo $user['is_active'] ? 'times-circle' : 'check-circle'; ?> me-1"></i>
                                                <?php echo $user['is_active'] ? 'Deactivate' : 'Activate'; ?>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            });
        }, 5000);
    </script>
</body>
</html>