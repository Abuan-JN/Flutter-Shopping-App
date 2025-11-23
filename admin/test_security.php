<?php
/**
 * Security Test File
 * Test various security features of the admin dashboard
 */

require_once 'config/auth.php';
require_once 'config/security.php';

// Test database connection
function testDatabaseConnection() {
    try {
        require_once 'config/database.php';
        $pdo = getCentralizedDBConnection();
        
        $stmt = $pdo->query("SELECT 1 as test");
        $result = $stmt->fetch();
        
        if ($result && $result['test'] == 1) {
            return ['success' => true, 'message' => 'Database connection successful'];
        } else {
            return ['success' => false, 'message' => 'Database query failed'];
        }
    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Database connection failed: ' . $e->getMessage()];
    }
}

// Test password hashing
function testPasswordHashing() {
    $password = 'TestPassword123!';
    
    // Test hash generation
    $hashed = hashPassword($password);
    if (empty($hashed)) {
        return ['success' => false, 'message' => 'Password hash generation failed'];
    }
    
    // Test verification
    if (verifyPassword($password, $hashed)) {
        return ['success' => true, 'message' => 'Password hashing and verification working correctly'];
    } else {
        return ['success' => false, 'message' => 'Password verification failed'];
    }
}

// Test CSRF token generation
function testCSRFToken() {
    session_start();
    
    $token = generateCSRFToken();
    if (empty($token)) {
        return ['success' => false, 'message' => 'CSRF token generation failed'];
    }
    
    if (validateCSRFToken($token)) {
        return ['success' => true, 'message' => 'CSRF token generation and validation working correctly'];
    } else {
        return ['success' => false, 'message' => 'CSRF token validation failed'];
    }
}

// Test input sanitization
function testInputSanitization() {
    $maliciousInput = '<script>alert("XSS")</script>';
    $sanitized = sanitizeInput($maliciousInput);
    
    if ($sanitized !== $maliciousInput && strpos($sanitized, '<script>') === false) {
        return ['success' => true, 'message' => 'Input sanitization working correctly'];
    } else {
        return ['success' => false, 'message' => 'Input sanitization failed'];
    }
}

// Test email validation
function testEmailValidation() {
    $validEmail = 'test@example.com';
    $invalidEmail = 'invalid-email';
    
    if (validateEmail($validEmail) && !validateEmail($invalidEmail)) {
        return ['success' => true, 'message' => 'Email validation working correctly'];
    } else {
        return ['success' => false, 'message' => 'Email validation failed'];
    }
}

// Test password strength validation
function testPasswordValidation() {
    $strongPassword = 'StrongPass123!';
    $weakPassword = '123';
    
    $strongResult = validatePassword($strongPassword);
    $weakResult = validatePassword($weakPassword);
    
    if ($strongResult['valid'] && !$weakResult['valid']) {
        return ['success' => true, 'message' => 'Password strength validation working correctly'];
    } else {
        return ['success' => false, 'message' => 'Password strength validation failed'];
    }
}

// Run all tests
$tests = [
    'Database Connection' => testDatabaseConnection(),
    'Password Hashing' => testPasswordHashing(),
    'CSRF Protection' => testCSRFToken(),
    'Input Sanitization' => testInputSanitization(),
    'Email Validation' => testEmailValidation(),
    'Password Validation' => testPasswordValidation()
];

$totalTests = count($tests);
$passedTests = 0;

foreach ($tests as $testName => $result) {
    if ($result['success']) {
        $passedTests++;
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Test Results - Admin Panel</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-primary text-white text-center">
                        <h2>
                            <i class="fas fa-shield-alt me-2"></i>
                            Security Test Results
                        </h2>
                        <p class="mb-0">Testing admin dashboard security features</p>
                    </div>
                    
                    <div class="card-body">
                        <div class="mb-4">
                            <h5>Test Summary</h5>
                            <div class="alert alert-<?php echo $passedTests === $totalTests ? 'success' : 'warning'; ?>">
                                <strong><?php echo $passedTests; ?> out of <?php echo $totalTests; ?> tests passed</strong>
                                <?php if ($passedTests === $totalTests): ?>
                                    All security features are working correctly!
                                <?php else: ?>
                                    Some security features need attention.
                                <?php endif; ?>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <h5>Detailed Results</h5>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Test</th>
                                            <th>Status</th>
                                            <th>Details</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($tests as $testName => $result): ?>
                                        <tr>
                                            <td><?php echo htmlspecialchars($testName); ?></td>
                                            <td>
                                                <span class="badge bg-<?php echo $result['success'] ? 'success' : 'danger'; ?>">
                                                    <i class="fas fa-<?php echo $result['success'] ? 'check-circle' : 'exclamation-triangle'; ?> me-1"></i>
                                                    <?php echo $result['success'] ? 'PASS' : 'FAIL'; ?>
                                                </span>
                                            </td>
                                            <td><?php echo htmlspecialchars($result['message']); ?></td>
                                        </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <h5>Security Features Implemented</h5>
                            <div class="row">
                                <div class="col-md-6">
                                    <ul class="list-group">
                                        <li class="list-group-item">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            Secure password hashing (bcrypt)
                                        </li>
                                        <li class="list-group-item">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            CSRF protection
                                        </li>
                                        <li class="list-group-item">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            Input sanitization and validation
                                        </li>
                                        <li class="list-group-item">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            Session management with security
                                        </li>
                                    </ul>
                                </div>
                                <div class="col-md-6">
                                    <ul class="list-group">
                                        <li class="list-group-item">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            Rate limiting protection
                                        </li>
                                        <li class="list-group-item">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            SQL injection prevention (PDO)
                                        </li>
                                        <li class="list-group-item">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            Activity logging
                                        </li>
                                        <li class="list-group-item">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            Admin authentication
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        
                        <div class="text-center">
                            <a href="index.php" class="btn btn-primary me-2">
                                <i class="fas fa-tachometer-alt me-1"></i>
                                Go to Dashboard
                            </a>
                            <a href="login.php" class="btn btn-outline-primary">
                                <i class="fas fa-sign-in-alt me-1"></i>
                                Test Login
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>