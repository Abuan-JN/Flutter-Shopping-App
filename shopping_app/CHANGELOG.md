# Changelog

All notable changes to the Flutter Shopping App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-11-22

### 🚀 Major Release: Complete Architecture Refactoring

#### 📋 Overview
This is a **BREAKING CHANGE** release that completely separates the admin functionality from the customer mobile application. The app now consists of two distinct systems:
- **Customer Mobile App**: Dedicated Flutter mobile application for customers
- **Web-based Admin Interface**: Complete web-based admin dashboard for management

#### 🔄 Changed
- **Complete Architectural Separation**: Split monolithic app into customer mobile + web admin
- **Removed Admin Mobile Interface**: All admin screens and functionality removed from Flutter app
- **New Customer Login System**: Implemented customer authentication (email/password)
- **New Registration System**: Added customer registration functionality
- **Automatic Authentication**: App now automatically navigates to login or products based on auth state

#### ➕ Added
- **Web Admin Interface** (`shopping_app_admin/`):
  - Complete responsive web-based admin dashboard
  - Product management (CRUD operations)
  - Order management with status updates
  - Category management
  - User management
  - Real-time dashboard with statistics
  - Modern UI with Material Design principles

- **Customer Mobile Enhancements**:
  - `LoginScreen` with email/password authentication
  - `RegisterScreen` with comprehensive form validation
  - `AuthWrapper` for automatic navigation
  - Improved error handling and user feedback
  - Enhanced form validation with Philippine-specific formatting

#### 🔧 Removed
- **Admin Mobile Components**:
  - `AdminLoginScreen` - removed entirely
  - `AdminDashboardScreen` - removed entirely
  - Admin-specific routes (`/dashboard`, `/admin/orders`)
  - Admin conditional logic in `OrderHistoryScreen`
  - Admin product management (`AddEditProductScreen`, product editing/deletion)
  - Admin authentication state (`isAdminLoggedIn`, `adminToken`)

- **API Endpoints**:
  - Admin-specific product management endpoints
  - Admin authentication methods
  - Admin-only data filtering

#### 🛠️ Technical Changes
- **Authentication System**: 
  - Replaced admin username/password with customer email/password
  - Updated `AuthProvider` with customer-focused methods
  - Implemented automatic login state detection
  - Added customer registration functionality

- **Navigation Structure**:
  - Simplified navigation removing admin routes
  - Added automatic authentication-based routing
  - Clean separation between customer and admin flows

- **State Management**:
  - Removed admin-specific state variables
  - Simplified provider to focus on customer authentication
  - Enhanced error handling and loading states

#### 📱 Customer Mobile App Improvements
- **User Experience**:
  - Streamlined onboarding with login/registration
  - Automatic navigation based on authentication state
  - Improved error messages and validation
  - Better loading states and user feedback

- **Code Quality**:
  - Removed all admin-related conditional logic
  - Simplified widget trees
  - Enhanced form validation
  - Better separation of concerns

#### 🌐 Web Admin Interface Features
- **Dashboard**: Real-time statistics for orders, products, users, and revenue
- **Product Management**: Full CRUD operations with image handling
- **Order Management**: View, filter, and update order statuses
- **Category Management**: Create, edit, and delete product categories
- **User Management**: View and manage customer accounts
- **Responsive Design**: Works on desktop, tablet, and mobile browsers
- **Modern UI**: Material Design with intuitive navigation

#### 🔄 Migration Guide

##### For Developers
1. **Admin Functionality**: All admin tasks now performed through web interface at `shopping_app_admin/index.html`
2. **Authentication**: Customer login now uses email instead of username
3. **Navigation**: App automatically handles login/products navigation
4. **API Calls**: Admin endpoints now require web-based authentication

##### For Users
1. **Customers**: Use the mobile app for shopping, login with email/password
2. **Admins**: Use the web interface for management tasks
3. **Registration**: New customers can register directly through mobile app

#### 🧪 Testing
- Customer mobile app tested without admin functionality
- Web admin interface tested for all management features
- API endpoints verified for proper separation
- Authentication flows tested for both systems

#### 📝 Notes
This is a **breaking change** that requires:
- Database migration for customer authentication
- Separate deployment of web admin interface
- User communication about new login procedures
- Admin training on web-based management system

---

## [1.0.0] - 2025-10-15

### 🚀 Initial Release

#### ✨ Features
- Complete Flutter shopping app with admin functionality
- Product browsing and category filtering
- Shopping cart with real-time updates
- Order placement and history tracking
- Admin dashboard for product and order management
- Full CRUD operations for products and orders
- PHP backend with MySQL database
- Complete API integration

#### 🏗️ Architecture
- Flutter mobile application with Provider state management
- PHP RESTful API with CORS support
- MySQL database with comprehensive schema
- Admin and customer interfaces in single app

#### 📱 Mobile App Features
- Product listing with categories
- Product details with quantity selector
- Shopping cart management
- Checkout process with form validation
- Order history with status tracking
- Admin dashboard and product management

#### 🔧 Technical Implementation
- Provider pattern for state management
- HTTP client with error handling
- Form validation and user feedback
- Responsive design for various screen sizes
- Comprehensive error handling and loading states