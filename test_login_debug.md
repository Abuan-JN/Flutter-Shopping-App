# Login Debug Test Instructions

## Running the Application with Debug Logging

To test the login flow and identify the root cause of the "Invalid response from server" error, follow these steps:

### 1. Start the Flutter Application
```bash
cd shopping_app
flutter run
```

### 2. Perform a Login Test
1. Open the login screen
2. Enter valid test credentials (use an email that exists in the database)
3. Click the Login button
4. Observe the debug logs in the terminal

### 3. Key Debug Information to Look For

#### API Configuration Debug:
- Base URL: `http://abuanplmunflutter.sportsontheweb.net/api/`
- Login endpoint: `login.php`
- Full login URL: `http://abuanplmunflutter.sportsontheweb.net/api/login.php`

#### Request Debug:
- Request headers (especially CORS-related headers)
- Request body content
- HTTP method (should be POST)

#### Response Debug:
- Response status code
- Response headers
- Response body content
- Whether the response is JSON or HTML

### 4. Common Issues and Solutions

#### Issue 1: URL Duplication
**Problem**: The login URL might be constructed incorrectly due to baseUrl duplication.
**Solution**: Fixed in `api_config.dart` by removing baseUrl from login endpoint.

#### Issue 2: CORS Headers
**Problem**: Missing or incorrect CORS headers causing request failures.
**Solution**: Enhanced CORS configuration in both client and server.

#### Issue 3: Database Connection
**Problem**: Server cannot connect to the database.
**Solution**: Check database credentials in `api/db_connect.php`.

#### Issue 4: JSON Parsing Error
**Problem**: Server returns HTML error page instead of JSON.
**Solution**: Check server error logs and ensure proper error handling.

### 5. Expected Debug Output

When you run the login test, you should see debug logs similar to:

```
=== LOGIN SCREEN DEBUG ===
Form validation passed
Email: test@example.com
Password length: 8
AuthProvider instance: Instance of 'AuthProvider'
Calling authProvider.login()...

=== AUTH PROVIDER LOGIN DEBUG ===
Starting login process with email: test@example.com

=== LOGIN DEBUG: Starting login process ===
Email: test@example.com
Password length: 8
Base URL: http://abuanplmunflutter.sportsontheweb.net/api/

=== API CONFIG DEBUG ===
Base URL: http://abuanplmunflutter.sportsontheweb.net/api/
Login endpoint: login.php
Full login URL: http://abuanplmunflutter.sportsontheweb.net/api/login.php

=== CORS CONFIG DEBUG ===
Base URL: http://abuanplmunflutter.sportsontheweb.net
Required headers: {Content-Type: application/json, Accept: application/json, ...}
Auth headers: {X-Requested-With: XMLHttpRequest, Origin: http://abuanplmunflutter.sportsontheweb.net}

=== REQUEST DEBUG ===
Request URL: http://abuanplmunflutter.sportsontheweb.net/api/login.php
Request method: POST
Request headers: {...}
Request body: {email: test@example.com, password: userpassword}

=== RESPONSE DEBUG ===
Response status code: 200
Response headers: {content-type: application/json, ...}
Response body: {"success":true,"message":"Login successful","data":{...}}

=== JSON RESPONSE DEBUG ===
Response success: true
Response message: Login successful
Response data: {...}
```

### 6. Troubleshooting Based on Logs

If you see any of these issues in the logs:

1. **Empty Response Body**: Check server connectivity and database connection
2. **HTML Response Instead of JSON**: Check server error pages and PHP errors
3. **CORS Errors**: Verify CORS headers in both client and server
4. **Network Timeout**: Check server availability and network connection
5. **404 Not Found**: Verify the login endpoint URL is correct
6. **500 Internal Server Error**: Check server error logs

### 7. Next Steps

After running the test, analyze the debug logs to identify where the communication is failing and implement the appropriate fix based on the specific error encountered.