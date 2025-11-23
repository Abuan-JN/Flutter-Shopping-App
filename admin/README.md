# Admin Dashboard - Secure PHP Administration Panel

A comprehensive, secure, and responsive admin dashboard built with PHP, featuring robust security measures, modern design, and complete administrative functionality for managing a shopping application.

## Features

### Security Features
- **Secure Authentication**: bcrypt password hashing with salt
- **CSRF Protection**: Token-based protection against cross-site request forgery
- **Session Management**: Secure session handling with timeout and regeneration
- **Input Validation**: Comprehensive input sanitization and validation
- **SQL Injection Prevention**: PDO prepared statements throughout
- **Rate Limiting**: Protection against brute force attacks
- **Activity Logging**: Comprehensive security event logging
- **XSS Protection**: Output encoding and input sanitization

### Admin Interface
- **Modern Design**: Bootstrap 5 with custom styling
- **Responsive Layout**: Mobile-friendly design
- **Dashboard Overview**: Statistics and recent activity
- **User Management**: Complete user administration
- **Order Management**: Order processing and status updates
- **Product Management**: Product catalog viewing
- **Activity Monitoring**: Security event logs
- **Profile Management**: Admin account settings

### Technical Features
- **PHP 8+ Compatible**: Modern PHP practices
- **PDO Database**: Secure database connections
- **Modular Architecture**: Organized code structure
- **Error Handling**: Comprehensive error management
- **Security Headers**: HTTP security headers
- **Mobile Responsive**: Works on all devices

## Installation

### Prerequisites
- PHP 8.0 or higher
- MySQL 5.7 or higher
- Web server (Apache/Nginx)
- Bootstrap 5 (CDN)

### Setup Instructions

1. **Database Setup**
   ```sql
   -- Run the main database setup
   SOURCE database_setup.sql;
   
   -- Run security logs setup
   SOURCE admin/config/create_security_logs.sql;
   ```

2. **File Structure**
   ```
   admin/
   ├── config/
   │   ├── database.php
   │   ├── security.php
   │   ├── auth.php
   ├── includes/
   │   └── sidebar.php
   ├── login.php
   ├── logout.php
   ├── index.php
   ├── users.php
   ├── orders.php
   ├── products.php
   ├── activity.php
   ├── profile.php
   ├── test_security.php
   └── README.md
   ```

3. **Configuration**
   Edit `admin/config/database.php` and update database credentials:
   ```php
   define('DB_HOST', 'your_host');
   define('DB_NAME', 'shopping_app');
   define('DB_USER', 'your_username');
   define('DB_PASS', 'your_password');
   ```

4. **Admin Account**
   An admin user is pre-created in the database:
   - Email: `admin@example.com`
   - Password: `password` (change immediately after first login)

## Usage

### Accessing the Admin Panel
1. Navigate to `admin/login.php` in your browser
2. Enter admin credentials
3. You'll be redirected to the dashboard

### Dashboard Features
- **Statistics Overview**: View key metrics and recent activity
- **Quick Actions**: Access all management features
- **Responsive Design**: Works on desktop, tablet, and mobile

### User Management
- View all customer accounts
- Search and filter users
- Activate/deactivate accounts
- View user order history

### Order Management
- View all orders with status
- Update order statuses
- View detailed order information
- Filter orders by status or customer

### Product Management
- View product catalog
- Search products by name or category
- View product details and stock levels
- Filter by category or status

### Activity Monitoring
- View security event logs
- Filter by event type, user, or date
- Detailed event information
- Export capabilities (can be added)

### Profile Management
- Update admin profile information
- Change password with strength validation
- View login history
- Security tips and best practices

## Security Implementation

### Authentication System
The authentication system includes:
- Secure password hashing using bcrypt
- Session management with timeout
- CSRF token validation
- Rate limiting for login attempts
- Comprehensive logging

### Input Validation
All user inputs are validated:
- Email format validation
- Password strength requirements
- XSS prevention through sanitization
- SQL injection prevention with prepared statements

### Session Security
- Secure session configuration
- Session timeout after 2 hours
- Session ID regeneration
- HTTP-only cookies
- Secure cookie flags

### CSRF Protection
- Unique tokens for each form
- Token validation on all POST requests
- Token expiration (1 hour)
- Automatic token regeneration

## File Structure Overview

### Configuration Files
- `config/database.php`: Database connection setup
- `config/security.php`: Security functions and validation
- `config/auth.php`: Authentication and session management

### Core Pages
- `login.php`: Secure login form
- `logout.php`: Logout handler
- `index.php`: Main dashboard
- `users.php`: User management
- `orders.php`: Order management
- `products.php`: Product catalog
- `activity.php`: Security logs
- `profile.php`: Admin profile

### Includes
- `includes/sidebar.php`: Navigation menu

### Testing
- `test_security.php`: Security feature testing

## Database Schema

The admin dashboard uses the existing shopping app database with additional security logging:

### Tables Used
- `flutter2_users`: User accounts (customers and admins)
- `flutter2_orders`: Customer orders
- `flutter2_products`: Product catalog
- `flutter2_categories`: Product categories
- `security_logs`: Security event logging

### Security Logs Structure
```sql
CREATE TABLE security_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  event_type VARCHAR(50),
  description TEXT,
  user_id INT,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES flutter2_users(id)
);
```

## Security Best Practices

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

### Session Management
- 2-hour inactivity timeout
- Secure session cookies
- Session ID regeneration
- Automatic cleanup

### Input Handling
- All inputs sanitized
- XSS prevention
- SQL injection prevention
- CSRF protection

### Logging
- All security events logged
- Failed login attempts
- Admin actions tracked
- IP address and user agent recorded

## Troubleshooting

### Common Issues

1. **Login fails with "Invalid request"**
   - Clear browser cookies and try again
   - Check if session is working properly

2. **Database connection errors**
   - Verify database credentials in `config/database.php`
   - Ensure MySQL server is running
   - Check database permissions

3. **CSRF token errors**
   - Check if sessions are enabled
   - Verify PHP session configuration
   - Clear browser cache and cookies

4. **Permission errors**
   - Ensure proper file permissions
   - Check web server configuration
   - Verify PHP safe mode settings

### Debug Mode
For development, you can enable debug mode by adding this to your PHP files:
```php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
```

## Future Enhancements

Potential improvements that could be added:
- Two-factor authentication (2FA)
- Admin role-based permissions
- Data export functionality
- Real-time notifications
- Advanced reporting
- Bulk operations
- API integration
- Caching for performance

## Security Considerations

### Production Deployment
- Change default admin password
- Enable HTTPS/SSL
- Configure proper file permissions
- Set up a web application firewall (WAF)
- Regular security updates
- Monitor logs for suspicious activity

### Additional Security Measures
- Consider implementing 2FA
- Regular security audits
- Input validation on all endpoints
- Rate limiting on API endpoints
- Regular backups
- Database encryption for sensitive data

## Support

For issues, questions, or contributions:
1. Check the troubleshooting section
2. Review error logs
3. Test security features using `test_security.php`
4. Verify database connectivity
5. Ensure all dependencies are installed

## License

This admin dashboard is part of the Flutter Shopping App project and follows the same licensing terms.

---

**Note**: This admin dashboard provides comprehensive security and functionality for managing a shopping application. Always follow security best practices and keep the system updated with the latest security patches.