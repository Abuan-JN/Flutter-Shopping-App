<?php
/**
 * Products Management Page
 * Basic admin interface for viewing products (read-only for now)
 */

require_once 'config/auth.php';

// Require authentication for this page
requireAuth();

// Get current admin information
$admin = getCurrentAdmin();

// Get database connection using centralized API config
require_once 'config/database.php';
$pdo = getCentralizedDBConnection();

// Get products data
try {
    $search = $_GET['search'] ?? '';
    $category = $_GET['category'] ?? '';
    $status = $_GET['status'] ?? '';
    
    $query = "
        SELECT p.id, p.name, p.description, p.price, p.stock, p.is_active, p.created_at,
               c.name as category_name, c.id as category_id
        FROM flutter2_products p
        LEFT JOIN flutter2_categories c ON p.category_id = c.id
    ";
    
    $params = [];
    
    if (!empty($search)) {
        $query .= " WHERE (p.name LIKE ? OR p.description LIKE ?)";
        $searchParam = "%$search%";
        $params[] = $searchParam;
        $params[] = $searchParam;
    } else {
        $query .= " WHERE 1=1";
    }
    
    if (!empty($category)) {
        $query .= " AND p.category_id = ?";
        $params[] = $category;
    }
    
    if ($status === 'active') {
        $query .= " AND p.is_active = 1";
    } elseif ($status === 'inactive') {
        $query .= " AND p.is_active = 0";
    }
    
    $query .= " ORDER BY p.created_at DESC";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $products = $stmt->fetchAll();
    
    // Get categories for filter dropdown
    $stmt = $pdo->query("SELECT id, name FROM flutter2_categories WHERE is_active = 1 ORDER BY name");
    $categories = $stmt->fetchAll();
    
} catch (Exception $e) {
    error_log("Products query error: " . $e->getMessage());
    $products = [];
    $categories = [];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products - Admin Panel</title>
    
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
                        <i class="fas fa-box me-2"></i>
                        Product Management
                    </h1>
                    <p class="text-muted mb-0 mt-2">View and manage your product catalog</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <button class="btn btn-primary" onclick="window.location.reload()">
                        <i class="fas fa-refresh me-2"></i>
                        Refresh
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Search and Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="GET" action="products.php" class="row g-3">
                    <div class="col-md-5">
                        <input type="text" class="form-control" name="search" placeholder="Search by product name or description..." 
                               value="<?php echo htmlspecialchars($_GET['search'] ?? ''); ?>">
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" name="category">
                            <option value="">All Categories</option>
                            <?php foreach ($categories as $category): ?>
                                <option value="<?php echo $category['id']; ?>" 
                                    <?php echo ($_GET['category'] ?? '') == $category['id'] ? 'selected' : ''; ?>>
                                    <?php echo htmlspecialchars($category['name']); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <select class="form-select" name="status">
                            <option value="">All Products</option>
                            <option value="active" <?php echo ($_GET['status'] ?? '') === 'active' ? 'selected' : ''; ?>>
                                Active
                            </option>
                            <option value="inactive" <?php echo ($_GET['status'] ?? '') === 'inactive' ? 'selected' : ''; ?>>
                                Inactive
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
        
        <!-- Products Grid -->
        <div class="card">
            <div class="card-header bg-transparent border-0">
                <h5 class="card-title mb-0">
                    <i class="fas fa-list me-2"></i>
                    Products (<?php echo count($products); ?>)
                </h5>
            </div>
            <div class="card-body">
                <?php if (empty($products)): ?>
                    <div class="text-center py-5">
                        <i class="fas fa-box text-muted" style="font-size: 3rem;"></i>
                        <h5 class="text-muted mt-3">No products found</h5>
                        <p class="text-muted">Try adjusting your search criteria</p>
                    </div>
                <?php else: ?>
                    <div class="row">
                        <?php foreach ($products as $product): ?>
                        <div class="col-md-6 col-lg-4 mb-4">
                            <div class="card h-100">
                                <div class="position-relative">
                                    <img src="<?php echo htmlspecialchars($product['image'] ?? 'https://via.placeholder.com/300x300/6c757d/FFFFFF?text=No+Image'); ?>" 
                                         class="card-img-top" alt="<?php echo htmlspecialchars($product['name']); ?>"
                                         style="height: 200px; object-fit: cover;">
                                    <div class="position-absolute top-0 end-0 m-2">
                                        <span class="badge bg-<?php echo $product['is_active'] ? 'success' : 'danger'; ?>">
                                            <?php echo $product['is_active'] ? 'Active' : 'Inactive'; ?>
                                        </span>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <h6 class="card-title fw-semibold">
                                        <?php echo htmlspecialchars($product['name']); ?>
                                    </h6>
                                    <p class="card-text text-muted small">
                                        <?php echo htmlspecialchars(substr($product['description'], 0, 100)); ?>
                                        <?php echo strlen($product['description']) > 100 ? '...' : ''; ?>
                                    </p>
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <div>
                                            <span class="badge bg-primary"><?php echo htmlspecialchars($product['category_name']); ?></span>
                                        </div>
                                        <div class="text-primary fw-bold fs-5">
                                            $<?php echo number_format($product['price'], 2); ?>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <small class="text-muted">
                                            <i class="fas fa-box me-1"></i>
                                            Stock: <?php echo $product['stock']; ?>
                                        </small>
                                        <button class="btn btn-outline-primary btn-sm" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#productModal_<?php echo $product['id']; ?>">
                                            <i class="fas fa-eye me-1"></i>
                                            View Details
                                        </button>
                                    </div>
                                </div>
                                <div class="card-footer bg-transparent border-0 pt-0">
                                    <small class="text-muted">
                                        <i class="fas fa-calendar me-1"></i>
                                        Added: <?php echo date('M j, Y', strtotime($product['created_at'])); ?>
                                    </small>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Product Details Modal -->
                        <div class="modal fade" id="productModal_<?php echo $product['id']; ?>" tabindex="-1">
                            <div class="modal-dialog modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">
                                            <i class="fas fa-info-circle me-2"></i>
                                            Product Details
                                        </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <img src="<?php echo htmlspecialchars($product['image'] ?? 'https://via.placeholder.com/400x400/6c757d/FFFFFF?text=No+Image'); ?>" 
                                                     class="img-fluid rounded" alt="<?php echo htmlspecialchars($product['name']); ?>">
                                            </div>
                                            <div class="col-md-6">
                                                <h5 class="fw-semibold"><?php echo htmlspecialchars($product['name']); ?></h5>
                                                <p class="text-muted"><?php echo htmlspecialchars($product['description']); ?></p>
                                                
                                                <div class="row mt-3">
                                                    <div class="col-6">
                                                        <strong>Price:</strong>
                                                        <br>
                                                        <span class="text-primary fs-5 fw-bold">$<?php echo number_format($product['price'], 2); ?></span>
                                                    </div>
                                                    <div class="col-6">
                                                        <strong>Stock:</strong>
                                                        <br>
                                                        <span class="<?php echo $product['stock'] <= 5 ? 'text-warning' : 'text-success'; ?>">
                                                            <?php echo $product['stock']; ?> units
                                                            <?php if ($product['stock'] <= 5 && $product['stock'] > 0): ?>
                                                                <small class="text-warning">(Low Stock)</small>
                                                            <?php elseif ($product['stock'] == 0): ?>
                                                                <small class="text-danger">(Out of Stock)</small>
                                                            <?php endif; ?>
                                                        </span>
                                                    </div>
                                                </div>
                                                
                                                <div class="mt-3">
                                                    <strong>Category:</strong>
                                                    <br>
                                                    <span class="badge bg-secondary"><?php echo htmlspecialchars($product['category_name']); ?></span>
                                                </div>
                                                
                                                <div class="mt-3">
                                                    <strong>Status:</strong>
                                                    <br>
                                                    <span class="badge bg-<?php echo $product['is_active'] ? 'success' : 'danger'; ?>">
                                                        <?php echo $product['is_active'] ? 'Active' : 'Inactive'; ?>
                                                    </span>
                                                </div>
                                                
                                                <div class="mt-3">
                                                    <strong>Added:</strong>
                                                    <br>
                                                    <span class="text-muted"><?php echo htmlspecialchars($product['created_at']); ?></span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>