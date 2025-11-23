# Database Integration Guide

This document explains how the admin dashboard and API share the same database configuration and structure using a centralized approach.

## Database Structure Integration

### Main Database Setup
The main database structure is defined in `database_setup.sql` which includes:
- User management tables (`flutter2_users`)
- Product catalog tables (`flutter2_products`, `flutter2_categories`)
- Order management tables (`flutter2_orders`, `flutter2_order_items`)
- Shopping cart tables (`flutter2_cart`)
- **Security logging tables** (`security_logs`, `recent_security_events`)

### Security Logs Integration
The security logs table has been integrated directly into the main `database_setup.sql` file to ensure:
- Single source of truth for database schema
- Consistent table relationships
- Proper foreign key constraints
- Unified index management

## Centralized Configuration

### Primary Database Configuration (`api/db_connect.php`)
The **centralized database configuration** is now located in `api/db_connect.php`, serving as the single source of truth for all database connections:

```php
<?php
/**
 * Centralized Database Connection Configuration
 * This file serves as the single source of truth for database connections
 * Used by both admin dashboard and API endpoints
 */

// Database configuration - Update these values for your environment
define('DB_HOST', 'fdb1034.awardspace.net');
define('DB_NAME', '4669819_data');
define('DB_USER', '4669819_data');
define('DB_PASS', 'Dcejit9gwGbDJO');

// ... connection setup and utility functions
?>
```

This file contains:
- Database connection settings (host, name, user, password)
- Global `$pdo` connection object
- Utility functions (`executeQuery`, `fetchData`, `modifyData`)
- `getDBConnection()` function for alternative connection management
- Error handling for both admin and API contexts

### Admin Database Integration (`admin/config/database.php`)
```php
<?php
/**
 * Database configuration and connection
 * Secure PDO connection for admin dashboard
 * Uses centralized database configuration from API
 */

// Include centralized database connection from API
require_once '../api/db_connect.php';

/**
 * Get database connection using centralized API connection
 * This function uses the global $pdo from api/db_connect.php
 *
 * @return PDO Database connection object from centralized config
 */
function getCentralizedDBConnection() {
    global $pdo;
    
    // Test connection
    try {
        $pdo->query("SELECT 1");
        return $pdo;
    } catch (PDOException $e) {
        // Connection lost, recreate it
        return getDBConnection();
    }
}
?>
```

All admin pages now use `getCentralizedDBConnection()` to ensure they use the same database connection as the API.

## Setup Instructions

### Option 1: Fresh Installation
1. Run the complete `database_setup.sql` file on your MySQL server
2. This will create all tables including the security logs
3. Update `api/db_connect.php` with your database credentials
4. Both admin and API will automatically use the same database

### Option 2: Add Security Logs to Existing Database
If you already have the main database set up, run:
```sql
-- Run the security logs only SQL
SOURCE admin/config/security_logs_only.sql;
```

### Configuration Updates
To change database credentials:
1. Edit `api/db_connect.php` and update the `DB_HOST`, `DB_NAME`, `DB_USER`, and `DB_PASS` constants
2. **No other files need to be updated** - all admin pages automatically use the centralized configuration
3. Restart your web server if using persistent connections

## Database Schema Overview

### Core Tables
- `flutter2_users`: User accounts (customers and admins)
- `flutter2_products`: Product catalog
- `flutter2_categories`: Product categories
- `flutter2_orders`: Customer orders
- `flutter2_order_items`: Order line items
- `flutter2_cart`: Shopping cart items
- `security_logs`: Security event logging

### Views
- `product_inventory_view`: Product stock status
- `order_summary_view`: Order overview
- `sales_analytics_view`: Sales statistics
- `recent_security_events`: Recent security events with user info

### Indexes
All tables have appropriate indexes for:
- Primary keys
- Foreign keys
- Frequently queried columns
- Performance optimization

## Security Features

### Security Logging
The `security_logs` table tracks:
- Login attempts (successful and failed)
- Password changes
- Profile updates
- User management actions
- Suspicious activity
- Rate limiting events

### Data Relationships
- Security logs reference `flutter2_users.id`
- Cascading deletes ensure data integrity
- Proper foreign key constraints prevent orphaned records

## Connection Security

### Admin Dashboard
- Uses PDO with prepared statements
- Connection pooling enabled
- Error suppression in production
- Secure session management

### API
- Same database credentials as admin
- Prepared statement support
- Error handling with JSON responses
- CORS configuration

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Verify database credentials in `api/db_connect.php`
   - Check database server accessibility
   - Ensure MySQL user has proper permissions

2. **Table Not Found**
   - Run `database_setup.sql` if not already done
   - Or run `security_logs_only.sql` for just security tables
   - Verify database name matches configuration in `api/db_connect.php`

3. **Foreign Key Errors**
   - Ensure `flutter2_users` table exists before `security_logs`
   - Check that user IDs exist before logging security events
   - Verify database engine supports foreign keys (InnoDB required)

4. **Admin Pages Not Connecting**
   - Ensure `admin/config/database.php` includes the centralized config
   - Check that `getCentralizedDBConnection()` function is being used
   - Verify the path to `api/db_connect.php` is correct

### Performance Optimization
- Indexes are created for optimal query performance
- Views provide pre-joined data for complex queries
- Prepared statements prevent SQL injection
- Connection reuse reduces overhead

## Security Considerations

### Database Security
- Use strong database passwords
- Limit database user permissions
- Enable SSL/TLS for remote connections
- Regular security updates
- Backup and recovery procedures

### Application Security
- Both admin and API use the same secure connection
- Prepared statements prevent SQL injection
- Input validation and sanitization
- Session security measures
- CSRF protection

## Migration Notes

### From Previous Versions
If upgrading from a version without security logs:
1. Backup existing database
2. Run `security_logs_only.sql`
3. Update application code if needed
4. Test all functionality

### Configuration Changes
The centralized configuration allows easy updates:
1. Change credentials in one file (`api/db_connect.php`)
2. Both admin and API automatically use new settings
3. No need to maintain separate configuration files
4. All admin pages automatically inherit the updated connection

### Benefits of Centralized Configuration
- **Single Point of Maintenance**: Update database credentials in one location
- **Consistency**: Ensures all components use identical database settings
- **Reduced Errors**: Eliminates configuration drift between admin and API
- **Easy Scaling**: Simplified deployment across different environments
- **Better Security**: Centralized credential management

## Support

For database-related issues:
1. Check connection credentials
2. Verify table structure matches documentation
3. Review error logs
4. Test with simple queries first
5. Ensure proper MySQL version compatibility

---

This integration ensures both the admin dashboard and API use the same secure, well-structured database while maintaining separation of concerns in the application architecture.