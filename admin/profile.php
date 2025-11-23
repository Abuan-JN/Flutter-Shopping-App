<?php
/**
 * Admin Profile Management Page
 * Allow admins to view and update their profile information
 */

require_once 'config/auth.php';

// Require authentication for this page
requireAuth();

// Get current admin information
$admin = getCurrentAdmin();

// Get database connection using centralized API config
require_once 'config/database.php';
$pdo = getCentralizedDBConnection();

// Initialize variables
$error = '';
$success = '';

// Handle profile update
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_profile'])) {
    if (!validateCSRFToken($_POST['csrf_token'])) {
        $error = 'Invalid request. Please try again.';
        logSecurityEvent('suspicious_activity', 'CSRF token validation failed during profile update', $admin['id']);
    } else {
        // Get and sanitize input
        $name = sanitizeInput($_POST['name'] ?? '');
        $email = sanitizeInput($_POST['email'] ?? '');
        $phone = sanitizeInput($_POST['phone'] ?? '');
        $address = sanitizeInput($_POST['address'] ?? '');
        
        // Validate input
        if (empty($name)) {
            $error = 'Name is required.';
        } elseif (empty($email)) {
            $error = 'Email is required.';
        } elseif (!validateEmail($email)) {
            $error = 'Please enter a valid email address.';
        } else {
            try {
                // Update profile
                $stmt = $pdo->prepare("
                    UPDATE flutter2_users 
                    SET name = ?, email = ?, phone = ?, address = ?, updated_at = NOW()
                    WHERE id = ?
                ");
                
                $result = $stmt->execute([$name, $email, $phone, $address, $admin['id']]);
                
                if ($result) {
                    // Update session data
                    $_SESSION['admin_name'] = $name;
                    $_SESSION['admin_email'] = $email;
                    
                    $success = 'Profile updated successfully.';
                    logSecurityEvent('profile_update', "Admin profile updated: $name ($email)", $admin['id']);
                } else {
                    $error = 'Failed to update profile. Please try again.';
                }
            } catch (Exception $e) {
                $error = 'An error occurred while updating your profile.';
                error_log("Profile update error: " . $e->getMessage());
            }
        }
    }
}

// Handle password change
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['change_password'])) {
    if (!validateCSRFToken($_POST['csrf_token'])) {
        $error = 'Invalid request. Please try again.';
    } else {
        $current_password = sanitizeInput($_POST['current_password'] ?? '');
        $new_password = sanitizeInput($_POST['new_password'] ?? '');
        $confirm_password = sanitizeInput($_POST['confirm_password'] ?? '');
        
        if (empty($current_password)) {
            $error = 'Current password is required.';
        } elseif (empty($new_password)) {
            $error = 'New password is required.';
        } elseif ($new_password !== $confirm_password) {
            $error = 'New passwords do not match.';
        } else {
            // Validate password strength
            $passwordValidation = validatePassword($new_password);
            if (!$passwordValidation['valid']) {
                $error = implode(' ', $passwordValidation['errors']);
            } else {
                try {
                    // Verify current password
                    $stmt = $pdo->prepare("SELECT password FROM flutter2_users WHERE id = ?");
                    $stmt->execute([$admin['id']]);
                    $user = $stmt->fetch();
                    
                    if (!$user || !verifyPassword($current_password, $user['password'])) {
                        $error = 'Current password is incorrect.';
                    } else {
                        // Update password
                        $hashedPassword = hashPassword($new_password);
                        $stmt = $pdo->prepare("UPDATE flutter2_users SET password = ?, updated_at = NOW() WHERE id = ?");
                        $result = $stmt->execute([$hashedPassword, $admin['id']]);
                        
                        if ($result) {
                            $success = 'Password changed successfully.';
                            logSecurityEvent('password_change', "Admin password changed for user ID: {$admin['id']}", $admin['id']);
                        } else {
                            $error = 'Failed to change password. Please try again.';
                        }
                    }
                } catch (Exception $e) {
                    $error = 'An error occurred while changing your password.';
                    error_log("Password change error: " . $e->getMessage());
                }
            }
        }
    }
}

// Get updated admin data
try {
    $stmt = $pdo->prepare("
        SELECT id, name, email, phone, address, created_at, updated_at
        FROM flutter2_users 
        WHERE id = ?
    ");
    $stmt->execute([$admin['id']]);
    $admin_data = $stmt->fetch();
} catch (Exception $e) {
    $error = 'Failed to load profile data.';
    error_log("Profile load error: " . $e->getMessage());
    $admin_data = $admin;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - Admin Panel</title>
    
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
                        <i class="fas fa-user-cog me-2"></i>
                        Admin Profile
                    </h1>
                    <p class="text-muted mb-0 mt-2">Manage your account information and security settings</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <span class="badge bg-success">
                        <i class="fas fa-user-shield me-1"></i>
                        Admin Account
                    </span>
                </div>
            </div>
        </div>
        
        <!-- Alerts -->
        <?php if ($error): ?>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i>
                <?php echo htmlspecialchars($error); ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <?php endif; ?>
        
        <?php if ($success): ?>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <?php echo htmlspecialchars($success); ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <?php endif; ?>
        
        <div class="row">
            <!-- Profile Information -->
            <div class="col-lg-8">
                <div class="card mb-4">
                    <div class="card-header bg-transparent border-0">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-user me-2"></i>
                            Profile Information
                        </h5>
                    </div>
                    <div class="card-body">
                        <form method="POST" action="" novalidate>
                            <input type="hidden" name="update_profile" value="1">
                            <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="name" class="form-label fw-semibold">Full Name</label>
                                    <input type="text" class="form-control" id="name" name="name" 
                                           value="<?php echo htmlspecialchars($admin_data['name'] ?? ''); ?>" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="email" class="form-label fw-semibold">Email Address</label>
                                    <input type="email" class="form-control" id="email" name="email" 
                                           value="<?php echo htmlspecialchars($admin_data['email'] ?? ''); ?>" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="phone" class="form-label fw-semibold">Phone Number</label>
                                    <input type="tel" class="form-control" id="phone" name="phone" 
                                           value="<?php echo htmlspecialchars($admin_data['phone'] ?? ''); ?>">
                                    <div class="form-text">Optional - for contact purposes</div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="address" class="form-label fw-semibold">Address</label>
                                    <input type="text" class="form-control" id="address" name="address" 
                                           value="<?php echo htmlspecialchars($admin_data['address'] ?? ''); ?>">
                                    <div class="form-text">Optional - for administrative purposes</div>
                                </div>
                            </div>
                            
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save me-2"></i>
                                    Update Profile
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <!-- Account Security -->
            <div class="col-lg-4">
                <div class="card mb-4">
                    <div class="card-header bg-transparent border-0">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-shield-alt me-2"></i>
                            Account Security
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-4">
                            <h6 class="fw-semibold">Login Information</h6>
                            <div class="small text-muted">
                                <div class="mb-2">
                                    <i class="fas fa-user me-2"></i>
                                    <strong>Role:</strong> <?php echo htmlspecialchars($admin['role'] ?? ''); ?>
                                </div>
                                <div class="mb-2">
                                    <i class="fas fa-clock me-2"></i>
                                    <strong>Last Login:</strong> <?php echo date('M j, Y H:i', $admin['login_time'] ?? time()); ?>
                                </div>
                                <div class="mb-2">
                                    <i class="fas fa-calendar me-2"></i>
                                    <strong>Member Since:</strong> <?php echo date('M j, Y', strtotime($admin_data['created_at'] ?? date('Y-m-d'))); ?>
                                </div>
                            </div>
                        </div>
                        
                        <hr>
                        
                        <div>
                            <h6 class="fw-semibold">Change Password</h6>
                            <p class="small text-muted mb-3">For your account security, use a strong password</p>
                            
                            <form method="POST" action="" novalidate>
                                <input type="hidden" name="change_password" value="1">
                                <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                                
                                <div class="mb-2">
                                    <input type="password" class="form-control form-control-sm" name="current_password" 
                                           placeholder="Current password" required>
                                </div>
                                <div class="mb-2">
                                    <input type="password" class="form-control form-control-sm" name="new_password" 
                                           placeholder="New password" required>
                                </div>
                                <div class="mb-3">
                                    <input type="password" class="form-control form-control-sm" name="confirm_password" 
                                           placeholder="Confirm new password" required>
                                </div>
                                <button type="submit" class="btn btn-outline-primary btn-sm w-100">
                                    <i class="fas fa-key me-1"></i>
                                    Change Password
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Security Tips -->
                <div class="card">
                    <div class="card-header bg-transparent border-0">
                        <h6 class="card-title mb-0">
                            <i class="fas fa-info-circle me-2"></i>
                            Security Tips
                        </h6>
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled small">
                            <li class="mb-2">
                                <i class="fas fa-shield-alt text-success me-2"></i>
                                Use strong, unique passwords
                            </li>
                            <li class="mb-2">
                                <i class="fas fa-eye-slash text-success me-2"></i>
                                Never share your login credentials
                            </li>
                            <li class="mb-2">
                                <i class="fas fa-sign-out-alt text-success me-2"></i>
                                Always log out from public devices
                            </li>
                            <li class="mb-0">
                                <i class="fas fa-bell text-success me-2"></i>
                                Enable 2FA when available
                            </li>
                        </ul>
                    </div>
                </div>
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
        
        // Password strength indicator (basic)
        document.querySelectorAll('input[name="new_password"]').forEach(function(input) {
            input.addEventListener('input', function() {
                const password = this.value;
                const strength = getPasswordStrength(password);
                
                // Simple visual feedback
                this.style.borderColor = strength.color;
            });
        });
        
        function getPasswordStrength(password) {
            let score = 0;
            const checks = [
                password.length >= 8,
                /[a-z]/.test(password),
                /[A-Z]/.test(password),
                /[0-9]/.test(password),
                /[^a-zA-Z0-9]/.test(password)
            ];
            
            score = checks.filter(Boolean).length;
            
            if (score <= 2) return { color: '#dc3545', text: 'Weak' };
            if (score <= 3) return { color: '#ffc107', text: 'Fair' };
            if (score <= 4) return { color: '#fd7e14', text: 'Good' };
            return { color: '#28a745', text: 'Strong' };
        }
    </script>
</body>
</html>