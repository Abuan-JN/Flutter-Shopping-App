<?php
/**
 * Activity Log Page
 * Display security events and user activity
 */

require_once 'config/auth.php';

// Require authentication for this page
requireAuth();

// Get current admin information
$admin = getCurrentAdmin();

// Get database connection using centralized API config
require_once 'config/database.php';
$pdo = getCentralizedDBConnection();

// Get filter parameters
$page = intval($_GET['page'] ?? 1);
$limit = 20;
$offset = ($page - 1) * $limit;

$event_type = $_GET['event_type'] ?? '';
$user_filter = $_GET['user_filter'] ?? '';
$date_from = $_GET['date_from'] ?? '';
$date_to = $_GET['date_to'] ?? '';

// Build query
$query = "
    SELECT sl.id, sl.event_type, sl.description, sl.user_id, sl.ip_address, 
           sl.user_agent, sl.created_at, u.name as user_name, u.email as user_email
    FROM security_logs sl
    LEFT JOIN flutter2_users u ON sl.user_id = u.id
";

$countQuery = "
    SELECT COUNT(*) as total
    FROM security_logs sl
    LEFT JOIN flutter2_users u ON sl.user_id = u.id
";

$whereConditions = [];
$params = [];

if (!empty($event_type)) {
    $whereConditions[] = "sl.event_type = ?";
    $params[] = $event_type;
}

if (!empty($user_filter)) {
    $whereConditions[] = "(u.name LIKE ? OR u.email LIKE ?)";
    $searchParam = "%$user_filter%";
    $params[] = $searchParam;
    $params[] = $searchParam;
}

if (!empty($date_from)) {
    $whereConditions[] = "DATE(sl.created_at) >= ?";
    $params[] = $date_from;
}

if (!empty($date_to)) {
    $whereConditions[] = "DATE(sl.created_at) <= ?";
    $params[] = $date_to;
}

if (!empty($whereConditions)) {
    $query .= " WHERE " . implode(" AND ", $whereConditions);
    $countQuery .= " WHERE " . implode(" AND ", $whereConditions);
}

$query .= " ORDER BY sl.created_at DESC LIMIT ? OFFSET ?";
$params[] = $limit;
$params[] = $offset;

try {
    // Get activities
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $activities = $stmt->fetchAll();
    
    // Get total count
    $stmt = $pdo->prepare($countQuery);
    $stmt->execute(array_slice($params, 0, -2)); // Remove LIMIT and OFFSET params
    $total = $stmt->fetch()['total'];
    $totalPages = ceil($total / $limit);
    
    // Get event types for filter dropdown
    $stmt = $pdo->query("SELECT DISTINCT event_type FROM security_logs ORDER BY event_type");
    $eventTypes = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
} catch (Exception $e) {
    error_log("Activity log query error: " . $e->getMessage());
    $activities = [];
    $total = 0;
    $totalPages = 1;
    $eventTypes = [];
}

function getEventIcon($eventType) {
    switch ($eventType) {
        case 'login_success':
            return 'sign-in-alt text-success';
        case 'login_failed':
        case 'login_attempt':
            return 'exclamation-triangle text-warning';
        case 'logout':
            return 'sign-out-alt text-info';
        case 'password_change':
        case 'profile_update':
            return 'user-check text-success';
        case 'user_management':
            return 'users-cog text-primary';
        case 'suspicious_activity':
        case 'rate_limited':
            return 'shield-alt text-danger';
        default:
            return 'info-circle text-muted';
    }
}

function getEventClass($eventType) {
    switch ($eventType) {
        case 'login_success':
        case 'password_change':
        case 'profile_update':
            return 'success';
        case 'login_failed':
        case 'login_attempt':
        case 'rate_limited':
            return 'warning';
        case 'suspicious_activity':
            return 'danger';
        case 'logout':
        case 'user_management':
            return 'info';
        default:
            return 'secondary';
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Activity Log - Admin Panel</title>
    
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
                        <i class="fas fa-history me-2"></i>
                        Activity Log
                    </h1>
                    <p class="text-muted mb-0 mt-2">Security events and administrative actions</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <span class="badge bg-info">
                        <i class="fas fa-shield-alt me-1"></i>
                        <?php echo number_format($total); ?> Events Logged
                    </span>
                </div>
            </div>
        </div>
        
        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="GET" action="activity.php" class="row g-3">
                    <div class="col-md-3">
                        <select class="form-select" name="event_type">
                            <option value="">All Event Types</option>
                            <?php foreach ($eventTypes as $type): ?>
                                <option value="<?php echo htmlspecialchars($type); ?>" 
                                    <?php echo $event_type === $type ? 'selected' : ''; ?>>
                                    <?php echo htmlspecialchars(ucfirst(str_replace('_', ' ', $type))); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <input type="text" class="form-control" name="user_filter" 
                               placeholder="Filter by user..." 
                               value="<?php echo htmlspecialchars($user_filter); ?>">
                    </div>
                    <div class="col-md-2">
                        <input type="date" class="form-control" name="date_from" 
                               value="<?php echo htmlspecialchars($date_from); ?>">
                    </div>
                    <div class="col-md-2">
                        <input type="date" class="form-control" name="date_to" 
                               value="<?php echo htmlspecialchars($date_to); ?>">
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-filter me-2"></i>
                            Filter
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Activity Table -->
        <div class="card">
            <div class="card-header bg-transparent border-0">
                <h5 class="card-title mb-0">
                    <i class="fas fa-list me-2"></i>
                    Security Events
                </h5>
            </div>
            <div class="card-body p-0">
                <?php if (empty($activities)): ?>
                    <div class="text-center py-5">
                        <i class="fas fa-history text-muted" style="font-size: 3rem;"></i>
                        <h5 class="text-muted mt-3">No activity found</h5>
                        <p class="text-muted">Try adjusting your filters</p>
                    </div>
                <?php else: ?>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Time</th>
                                    <th>Event</th>
                                    <th>Description</th>
                                    <th>User</th>
                                    <th>IP Address</th>
                                    <th>Details</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($activities as $activity): ?>
                                <tr>
                                    <td>
                                        <div class="fw-semibold">
                                            <?php echo date('H:i:s', strtotime($activity['created_at'])); ?>
                                        </div>
                                        <div class="small text-muted">
                                            <?php echo date('M j, Y', strtotime($activity['created_at'])); ?>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-<?php echo getEventClass($activity['event_type']); ?>">
                                            <i class="fas fa-<?php echo getEventIcon($activity['event_type']); ?>"></i>
                                            <?php echo htmlspecialchars(ucfirst(str_replace('_', ' ', $activity['event_type']))); ?>
                                        </span>
                                    </td>
                                    <td>
                                        <div style="max-width: 300px;">
                                            <?php echo htmlspecialchars($activity['description']); ?>
                                        </div>
                                    </td>
                                    <td>
                                        <?php if ($activity['user_name']): ?>
                                            <div>
                                                <div class="fw-semibold">
                                                    <?php echo htmlspecialchars($activity['user_name']); ?>
                                                </div>
                                                <div class="small text-muted">
                                                    <?php echo htmlspecialchars($activity['user_email']); ?>
                                                </div>
                                            </div>
                                        <?php else: ?>
                                            <span class="text-muted">System</span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-dark">
                                            <?php echo htmlspecialchars($activity['ip_address']); ?>
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#activityModal_<?php echo $activity['id']; ?>">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </td>
                                </tr>
                                
                                <!-- Activity Detail Modal -->
                                <div class="modal fade" id="activityModal_<?php echo $activity['id']; ?>" tabindex="-1">
                                    <div class="modal-dialog modal-lg">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">
                                                    <i class="fas fa-<?php echo getEventIcon($activity['event_type']); ?> me-2"></i>
                                                    Event Details
                                                </h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <h6>Event Information</h6>
                                                        <table class="table table-sm">
                                                            <tr>
                                                                <td><strong>ID:</strong></td>
                                                                <td><?php echo $activity['id']; ?></td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Event Type:</strong></td>
                                                                <td><?php echo htmlspecialchars($activity['event_type']); ?></td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Timestamp:</strong></td>
                                                                <td><?php echo htmlspecialchars($activity['created_at']); ?></td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>IP Address:</strong></td>
                                                                <td><code><?php echo htmlspecialchars($activity['ip_address']); ?></code></td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <h6>User Information</h6>
                                                        <table class="table table-sm">
                                                            <tr>
                                                                <td><strong>User ID:</strong></td>
                                                                <td>
                                                                    <?php echo $activity['user_id'] ? $activity['user_id'] : '<span class="text-muted">System</span>'; ?>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Name:</strong></td>
                                                                <td>
                                                                    <?php echo $activity['user_name'] ? htmlspecialchars($activity['user_name']) : '<span class="text-muted">System</span>'; ?>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td><strong>Email:</strong></td>
                                                                <td>
                                                                    <?php echo $activity['user_email'] ? htmlspecialchars($activity['user_email']) : '<span class="text-muted">System</span>'; ?>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                                
                                                <div class="mt-3">
                                                    <h6>Description</h6>
                                                    <p class="bg-light p-3 rounded">
                                                        <?php echo htmlspecialchars($activity['description']); ?>
                                                    </p>
                                                </div>
                                                
                                                <?php if ($activity['user_agent']): ?>
                                                <div class="mt-3">
                                                    <h6>User Agent</h6>
                                                    <p class="bg-light p-3 rounded" style="font-size: 0.8rem; max-height: 100px; overflow-y: auto;">
                                                        <?php echo htmlspecialchars($activity['user_agent']); ?>
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
                    
                    <!-- Pagination -->
                    <div class="card-footer bg-transparent border-0">
                        <div class="row align-items-center">
                            <div class="col-md-6">
                                <p class="text-muted mb-0">
                                    Showing <?php echo ($offset + 1); ?> to <?php echo min($offset + $limit, $total); ?> of <?php echo $total; ?> events
                                </p>
                            </div>
                            <div class="col-md-6">
                                <nav aria-label="Activity pagination" class="float-end">
                                    <ul class="pagination pagination-sm">
                                        <?php if ($page > 1): ?>
                                            <li class="page-item">
                                                <a class="page-link" href="?page=<?php echo $page - 1; ?>&<?php echo http_build_query(array_filter(['event_type' => $event_type, 'user_filter' => $user_filter, 'date_from' => $date_from, 'date_to' => $date_to])); ?>">
                                                    Previous
                                                </a>
                                            </li>
                                        <?php endif; ?>
                                        
                                        <?php for ($i = max(1, $page - 2); $i <= min($totalPages, $page + 2); $i++): ?>
                                            <li class="page-item <?php echo $i === $page ? 'active' : ''; ?>">
                                                <a class="page-link" href="?page=<?php echo $i; ?>&<?php echo http_build_query(array_filter(['event_type' => $event_type, 'user_filter' => $user_filter, 'date_from' => $date_from, 'date_to' => $date_to])); ?>">
                                                    <?php echo $i; ?>
                                                </a>
                                            </li>
                                        <?php endfor; ?>
                                        
                                        <?php if ($page < $totalPages): ?>
                                            <li class="page-item">
                                                <a class="page-link" href="?page=<?php echo $page + 1; ?>&<?php echo http_build_query(array_filter(['event_type' => $event_type, 'user_filter' => $user_filter, 'date_from' => $date_from, 'date_to' => $date_to])); ?>">
                                                    Next
                                                </a>
                                            </li>
                                        <?php endif; ?>
                                    </ul>
                                </nav>
                            </div>
                        </div>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>