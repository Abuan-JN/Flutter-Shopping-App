# **🛒 Flutter Shopping App — Complete System Generation Prompt (Mobile + PHP Admin Panel + REST API)**

### **FULL, DETAILED, AND PRODUCTION-READY VERSION**

---

## **🌐 Base URL for All API Endpoints**

All backend requests must use this domain:

```
https://abuanjnplmunflutter.infinityfreeapp.com
```

This is the root path for all PHP REST API files.

---

# **🎯 MAIN OBJECTIVE**

Generate a **full shopping ecosystem** with:

1. **Flutter Mobile Shopping App**
2. **Web-Based Admin Panel (PHP + HTML + CSS + JS)**
3. **PHP REST API Backend (JSON)**
4. **MySQL Database + SQL Schema**
5. **Full CRUD support for:**

   * Users
   * Categories
   * Products
   * Cart
   * Orders
   * Admin accounts

Every component must work together seamlessly.

---

# **🧱 SYSTEM ARCHITECTURE REQUIREMENTS**

---

# **1️⃣ WEB-BASED ADMIN PANEL (PHP)**

The admin panel must be built using:

* PHP (Core PHP, no frameworks required)
* HTML, CSS (Bootstrap recommended), JS
* Fully connected to the REST API
* All operations must communicate through JSON responses

---

## **🔐 Admin Authentication Module**

### **Admin Login Page**

Admin logs in using:

* Email or Username
* Password

**Rules:**

* Credentials validated using `admin_login.php`
* Return meaningful JSON messages for success/failure
* Invalid login → show error beside field
* Successful login → redirect to **Admin Dashboard**

---

## **📊 Admin Dashboard Requirements**

The dashboard must include:

* Total Users count
* Total Products count
* Total Categories count
* Total Orders count
* Sidebar navigation menu:

  * Dashboard
  * Categories
  * Products
  * Users
  * Orders
  * Logout

Dashboard UI must be:

* Clean
* Responsive (Bootstrap grid)
* Modern and visually professional

---

## **🛠 Admin Management Modules**

### **📁 Categories Management**

Admin can:

* Create category
* View all categories
* Update category name & description
* Delete category
* Each action must call API endpoints

---

### **📦 Products Management**

Admin can:

* Add new product
* Upload product image
* Assign category
* Set price, stock, description
* Update product details
* Delete product
* Filter product list by category

**Image Upload Requirements:**

* Uploaded images must be stored in `/uploads/`
* API returns the uploaded file URL

---

### **🧾 Orders Management**

Admin must be able to:

* View all orders

* Read order details per customer

* Update order status:

  ```
  Pending → Shipping → Delivering → Completed
  ```

* View customer info & items inside each order

---

### **👥 Customer (Users) Management**

Admin can:

* View entire user list
* Edit user basic info
* Enable/Disable user account (optional)
* Search users by name/username/email

---

# **2️⃣ PHP REST API (JSON-Based)**

All API endpoints must:

* Return JSON only
* Sanitize and validate all inputs
* Use **Prepared SQL Statements**
* Use correct HTTP methods (POST/GET)
* Return consistent response format:

```
{
   "success": true/false,
   "message": "text",
   "data": {...}
}
```

---

## **📂 API Folder Structure**

```
/api
   /auth
      register.php
      login.php
      admin_login.php
   /products
      create.php
      list.php
      update.php
      delete.php
   /categories
      create.php
      list.php
      update.php
      delete.php
   /cart
      add.php
      list.php
      update.php
      delete.php
   /orders
      place.php
      list_user_orders.php
      update_status.php
      confirm_delivery.php
   /users
      update_profile.php
      update_address.php
      get_profile.php
```

---

## **🚀 Required Functionality Per Module**

### **AUTH MODULE**

* Register
* Login (User)
* Login (Admin)

---

### **CATEGORY MODULE**

* Create category
* Edit category
* Delete category
* List category items

---

### **PRODUCTS MODULE**

* Create product with image upload
* Update product details
* Delete product
* List all products
* List by category

---

### **CART MODULE**

* Add item to cart
* Update quantity
* Remove item
* Clear cart
* Return total price

---

### **ORDERS MODULE**

* Place order
* Get user order history
* Update order status
* Confirm order received by user

---

### **USER MODULE**

* Update profile
* Update address
* Fetch user profile

---

# **3️⃣ FLUTTER SHOPPING APP (Mobile)**

Built using:

* Flutter 3.x
* State management (Provider, GetX, or Riverpod)
* Modern UI/UX
* Clean architecture preferred

---

## **🔐 Authentication Screens (Mobile)**

### **Registration Page**

**Fields:**

* Full Name
* Username
* Email
* Password (show/hide)
* Confirm Password (show/hide)

**Rules:**

* All required
* Email validated
* Passwords must match

---

### **Login Page**

**Fields:**

* Username or Email
* Password (show/hide)

On success → go to **User Dashboard**

---

# **🧭 Main Navigation**

Bottom Navigation Bar with 4 tabs:

1. **Products**
2. **Cart**
3. **Orders**
4. **Profile**

---

## **🛍 Products Screen**

* Fetch product list
* Display product image, name, price, short description
* Product details page optional but preferred
* User must select **quantity** before adding to cart
* Send data to API on confirmation

---

## **🛒 Cart Screen**

Shows:

* Cart items (image, price, qty)
* Update quantity
* Delete item
* Display total amount

### **Checkout Flow**

1. Show summary dialog
2. User selects fake payment method (GCash, COD, etc.)
3. User enters/chooses shipping address
4. Place Order via API
5. Order stored under `orders` & `order_items`

---

## **📦 Orders Screen**

* Displays all orders of the user
* Show delivery status:

  ```
  Pending
  Shipping
  Delivering
  Completed
  ```

### **Confirm Delivery Button**

When user receives order:

* Press “Confirm Received”
* Update via `confirm_delivery.php`

---

## **👤 Profile Screen**

User can:

* View profile info
* Edit name, email, username
* Edit address
* Save changes
* Logout (clear session)

---

# **4️⃣ DATABASE STRUCTURE**

System must include these tables:

```
users
admin_accounts
categories
products
carts
orders
order_items
addresses
```

### **SQL Schema Requirements**

* Proper relationships
* Foreign keys where possible
* Indexes for performance
* Auto-increment primary keys

---

# **📦 FINAL OUTPUT REQUIREMENTS**

Provide all deliverables:

✔ Full Flutter source code
✔ Full Admin Panel source code (PHP)
✔ Complete API folder
✔ SQL schema (full)
✔ Documentation explaining:

* Setup
* Deployment
* API usage
* Admin guide
* Mobile guide

✔ Code must be fully functional end-to-end

---