<?php
/**
 * Orders Management Page
 * Admin interface for managing customer orders
 */

require_once 'config/auth.php';

// Require authentication for this page
requireAuth();

// Get current admin information
$admin = getCurrentAdmin();

// Get database connection using centralized API config
require_once 'config/database.php';
$pdo = getCentralizedDBConnection();

// Handle order status updates
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_status'])) {
    if (!validateCSRFToken($_POST['csrf_token'])) {
        $_SESSION['error'] = 'Invalid request. Please try again.';
    } else {
        $order_id = intval($_POST['order_id'] ?? 0);
        $new_status = sanitizeInput($_POST['status'] ?? '');
        $allowed_statuses = ['pending', 'processing', 'completed', 'cancelled'];
        
        if ($order_id > 0 && in_array($new_status, $allowed_statuses)) {
            try {
                $stmt = $pdo->prepare("UPDATE flutter2_orders SET status = ?, updated_at = NOW() WHERE id = ?");
                $result = $stmt->execute([$new_status, $order_id]);
                
                if ($result) {
                    $_SESSION['success'] = 'Order status updated successfully.';
                    logSecurityEvent('order_management', "Admin {$admin['name']} updated order #{$order_id} status to: $new_status", $admin['id']);
                } else {
                    $_SESSION['error'] = 'Failed to update order status.';
                }
            } catch (Exception $e) {
                $_SESSION['error'] = 'An error occurred while updating order status.';
                error_log("Order status update error: " . $e->getMessage());
            }
        } else {
            $_SESSION['error'] = 'Invalid order or status.';
        }
    }
    
    header('Location: orders.php');
    exit();
}

// Get orders data
try {
    $search = $_GET['search'] ?? '';
    $status = $_GET['status'] ?? '';
    
    $query = "
        SELECT o.id, o.customer_name, o.customer_email, o.customer_phone, o.customer_address,
               o.total_amount, o.status, o.payment_method, o.payment_status, o.notes, o.created_at,
               COUNT(oi.id) as item_count
        FROM flutter2_orders o
        LEFT JOIN flutter2_order_items oi ON o.id = oi.order_id
    ";
    
    $params = [];
    
    if (!empty($search)) {
        $query .= " WHERE (o.customer_name LIKE ? OR o.customer_email LIKE ? OR o.id = ?)";
        $searchParam = "%$search%";
        $params[] = $searchParam;
        $params[] = $searchParam;
        $params[] = $search;
    } else {
        $query .= " WHERE 1=1";
    }
    
    if (!empty($status)) {
        $query .= " AND o.status = ?";
        $params[] = $status;
    }
    
    $query .= " GROUP BY o.id ORDER BY o.created_at DESC";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $orders = $stmt->fetchAll();
    
} catch (Exception $e) {
    $_SESSION['error'] = 'Failed to load orders.';
    error_log("Orders query error: " . $e->getMessage());
    $orders = [];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Orders - Admin Panel</title>
    
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
                        <i class="fas fa-shopping-bag me-2"></i>
                        Order Management
                    </h1>
                    <p class="text-muted mb-0 mt-2">Manage customer orders and their status</p>
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
                <form method="GET" action="orders.php" class="row g-3">
                    <div class="col-md-6">
                        <input type="text" class="form-control" name="search" placeholder="Search by customer name, email, or order ID..." 
                               value="<?php echo htmlspecialchars($_GET['search'] ?? ''); ?>">
                    </div>
                    <div class="col-md-4">
                        <select class="form-select" name="status">
                            <option value="">All Statuses</option>
                            <option value="pending" <?php echo ($_GET['status'] ?? '') === 'pending' ? 'selected' : ''; ?>>
                                Pending
                            </option>
                            <option value="processing" <?php echo ($_GET['status'] ?? '') === 'processing' ? 'selected' : ''; ?>>
                                Processing
                            </option>
                            <option value="completed" <?php echo ($_GET['status'] ?? '') === 'completed' ? 'selected' : ''; ?>>
                                Completed
                            </option>
                            <option value="cancelled" <?php echo ($_GET['status'] ?? '') === 'cancelled' ? 'selected' : ''; ?>>
                                Cancelled
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
        
        <!-- Orders Table -->
        <div class="card">
            <div class="card-header bg-transparent border-0">
                <h5 class="card-title mb-0">
                    <i class="fas fa-list me-2"></i>
                    Orders (<?php echo count($orders); ?>)
                </h5>
            </div>
            <div class="card-body">
                <?php if (empty($orders)): ?>
                    <div class="text-center py-5">
                        <i class="fas fa-shopping-bag text-muted" style="font-size: 3rem;"></i>
                        <h5 class="text-muted mt-3">No orders found</h5>
                        <p class="text-muted">Try adjusting your search criteria</p>
                    </div>
                <?php else: ?>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Customer</th>
                                    <th>Amount</th>
                                    <th>Items</th>
                                    <th>Status</th>
                                    <th>Payment</th>
                                    <th>Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($orders as $order): ?>
                                <tr>
                                    <td>
                                        <strong>#<?php echo $order['id']; ?></strong>
                                    </td>
                                    <td>
                                        <div>
                                            <div class="fw-semibold"><?php echo htmlspecialchars($order['customer_name']); ?></div>
                                            <div class="small text-muted"><?php echo htmlspecialchars($order['customer_email']); ?></div>
                                        </div>
                                    </td>
                                    <td class="text-primary fw-bold">$<?php echo number_format($order['total_amount'], 2); ?></td>
                                    <td>
                                        <span class="badge bg-secondary"><?php echo $order['item_count']; ?></span>
                                    </td>
                                    <td>
                                        <span class="status-badge 
                                            <?php echo $order['status'] === 'completed' ? 'status-completed' : 
                                                   ($order['status'] === 'processing' ? 'status-processing' : 
                                                   ($order['status'] === 'cancelled' ? 'status-cancelled' : 'status-pending')); ?>">
                                            <i class="fas fa-<?php echo $order['status'] === 'completed' ? 'check-circle' : 
                                                                   ($order['status'] === 'processing' ? 'cog' : 
                                                                   ($order['status'] === 'cancelled' ? 'times-circle' : 'clock')); ?> me-1"></i>
                                            <?php echo htmlspecialchars(ucfirst($order['status'])); ?>
                                        </span>
                                    </td>
                                    <td>
                                        <div>
                                            <div>
                                                <span class="badge bg-<?php echo $order['payment_status'] === 'paid' ? 'success' : 'warning'; ?>">
                                                    <?php echo htmlspecialchars(ucfirst($order['payment_status'])); ?>
                                                </span>
                                            </div>
                                            <div class="small text-muted"><?php echo htmlspecialchars($order['payment_method'] ?? 'N/A'); ?></div>
                                        </div>
                                    </td>
                                    <td>
                                        <div><?php echo date('M j, Y', strtotime($order['created_at'])); ?></div>
                                        <div class="small text-muted"><?php echo date('H:i', strtotime($order['created_at'])); ?></div>
                                    </td>
                                    <td>
                                        <!-- Order Status Update Form -->
                                        <form method="POST" style="margin-bottom: 5px;" onsubmit="return confirm('Update order status?')">
                                            <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                                            <input type="hidden" name="order_id" value="<?php echo $order['id']; ?>">
                                            <input type="hidden" name="update_status" value="1">
                                            <select class="form-select form-select-sm" name="status" onchange="this.form.submit()">
                                                <option value="">Change Status</option>
                                                <option value="pending" <?php echo $order['status'] === 'pending' ? 'selected' : ''; ?>>Pending</option>
                                                <option value="processing" <?php echo $order['status'] === 'processing' ? 'selected' : ''; ?>>Processing</option>
                                                <option value="completed" <?php echo $order['status'] === 'completed' ? 'selected' : ''; ?>>Completed</option>
                                                <option value="cancelled" <?php echo $order['status'] === 'cancelled' ? 'selected' : ''; ?>>Cancelled</option>
                                            </select>
                                        </form>
                                        
                                        <!-- View Order Details Button -->
                                        <button class="btn btn-sm btn-outline-primary" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#orderModal_<?php echo $order['id']; ?>">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </td>
                                </tr>
                                
                                <!-- Order Details Modal -->
                                <div class="modal fade" id="orderModal_<?php echo $order['id']; ?>" tabindex="-1">
                                    <div class="modal-dialog modal-lg">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">
                                                    <i class="fas fa-receipt me-2"></i>
                                                    Order Details - #<?php echo $order['id']; ?>
                                                </h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <!-- Order Information -->
                                                <div class="row mb-4">
                                                    <div class="col-md-6">
                                                        <h6>Customer Information</h6>
                                                        <table class="table table-sm">
                                                            <tr>
                                                                <td><strong>Name:</strong></td>
                                                                <td><?php echo htmlspecialchars($order['customer_name']); ?></td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Email:</strong></td>
                                                                <td><?php echo htmlspecialchars($order['customer_email']); ?></td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Phone:</strong></td>
                                                                <td><?php echo htmlspecialchars($order['customer_phone'] ?? 'N/A'); ?></td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Address:</strong></td>
                                                                <td><?php echo nl2br(htmlspecialchars($order['customer_address'])); ?></td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <h6>Order Information</h6>
                                                        <table class="table table-sm">
                                                            <tr>
                                                                <td><strong>Order ID:</strong></td>
                                                                <td>#<?php echo $order['id']; ?></td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Date:</strong></td>
                                                                <td><?php echo htmlspecialchars($order['created_at']); ?></td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Status:</strong></td>
                                                                <td>
                                                                    <span class="badge bg-<?php echo $order['status'] === 'completed' ? 'success' :
                                                                                                        ($order['status'] === 'processing' ? 'info' :
                                                                                                        ($order['status'] === 'cancelled' ? 'danger' : 'warning')); ?>">
                                                                        <?php echo htmlspecialchars(ucfirst($order['status'])); ?>
                                                                    </span>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Payment:</strong></td>
                                                                <td>
                                                                    <span class="badge bg-<?php echo $order['payment_status'] === 'paid' ? 'success' : 'warning'; ?>">
                                                                        <?php echo htmlspecialchars(ucfirst($order['payment_status'])); ?> - <?php echo htmlspecialchars($order['payment_method'] ?? 'N/A'); ?>
                                                                    </span>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                                
                                                <!-- Order Items -->
                                                <div class="mb-4">
                                                    <h6>Order Items</h6>
                                                    <?php
                                                    // Get order items
                                                    $stmt = $pdo->prepare("
                                                        SELECT product_name, quantity, price, product_image
                                                        FROM flutter2_order_items
                                                        WHERE order_id = ?
                                                    ");
                                                    $stmt->execute([$order['id']]);
                                                    $items = $stmt->fetchAll();
                                                    ?>
                                                    <div class="table-responsive">
                                                        <table class="table table-sm">
                                                            <thead>
                                                                <tr>
                                                                    <th>Product</th>
                                                                    <th>Quantity</th>
                                                                    <th>Unit Price</th>
                                                                    <th>Total</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <?php foreach ($items as $item): ?>
                                                                <tr>
                                                                    <td><?php echo htmlspecialchars($item['product_name']); ?></td>
                                                                    <td><?php echo $item['quantity']; ?></td>
                                                                    <td>$<?php echo number_format($item['price'], 2); ?></td>
                                                                    <td class="fw-bold">$<?php echo number_format($item['price'] * $item['quantity'], 2); ?></td>
                                                                </tr>
                                                                <?php endforeach; ?>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                                
                                                <!-- Order Notes -->
                                                <?php if ($order['notes']): ?>
                                                <div>
                                                    <h6>Customer Notes</h6>
                                                    <p class="bg-light p-3 rounded">
                                                        <?php echo htmlspecialchars($order['notes']); ?>
                                                    </p>
                                                </div>
                                                <?php endif; ?>
                                            </div>
                                        </div>
                                    </div>
                                </div>
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