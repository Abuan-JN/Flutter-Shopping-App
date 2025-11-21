# **Fully Functional Flutter Shopping App With Hosted PHP + MySQL Backend**

### **Base API URL:** `http://abuanplmunflutter.sportsontheweb.net`

---

## **📌 Overview**

Create a complete, fully functional **Flutter Shopping Application** connected to a **cloud-hosted PHP + MySQL backend** deployed at:

```
http://abuanplmunflutter.sportsontheweb.net
```

The backend must expose multiple API endpoints (via PHP), and the Flutter app must consume these endpoints using the `http` package.

The system should have:

* Web-based Admin Panel (PHP)
* Flutter Shopping Client (Mobile App)
* Full CRUD capabilities on products, categories, and orders
* JSON-based communication between Flutter and server

---

## **📌 Backend Requirements (PHP + MySQL)**

### **1. Hosting & Database**

* Use AwardSpace hosting: `http://abuanplmunflutter.sportsontheweb.net`
* Set up a MySQL database with the following tables:

  * `users` (admin login)
  * `products`
  * `categories`
  * `cart`
  * `orders`
  * `order_items`

### **2. PHP API Files**

Create separate PHP files and upload them to:

```
http://abuanplmunflutter.sportsontheweb.net/api/
```

The API endpoints should include:

| Function         | Endpoint                    |
| ---------------- | --------------------------- |
| Fetch products   | `/api/get_products.php`     |
| Add product      | `/api/add_product.php`      |
| Update product   | `/api/update_product.php`   |
| Delete product   | `/api/delete_product.php`   |
| Fetch categories | `/api/get_categories.php`   |
| Add category     | `/api/add_category.php`     |
| Admin login      | `/api/login.php`            |
| Add to cart      | `/api/add_to_cart.php`      |
| Get cart items   | `/api/get_cart.php`         |
| Remove cart item | `/api/remove_cart_item.php` |
| Create order     | `/api/create_order.php`     |
| View orders      | `/api/get_orders.php`       |

Each file must:

* Connect to the database
* Execute SQL queries
* Return structured JSON responses like:

  ```json
  {
    "success": true,
    "message": "Operation successful",
    "data": []
  }
  ```

### **3. Endpoint Testing**

Test each endpoint by visiting it through a browser, for example:

```
http://abuanplmunflutter.sportsontheweb.net/api/get_products.php
```

Confirm that it outputs valid JSON.

---

## **📌 Flutter Requirements**

### **1. Project Setup**

Use the following dependencies:

```yaml
dependencies:
  http: ^1.0.0
  provider: ^6.0.0     # optional for state management
```

Create a Dart file to store base URLs:

```dart
class ApiConfig {
  static const String baseUrl =
      "http://abuanplmunflutter.sportsontheweb.net/api/";
}
```

Example usage:

```dart
final response = await http.get(Uri.parse("${ApiConfig.baseUrl}get_products.php"));
final data = jsonDecode(response.body);
```

### **2. Client-Side Features**

The Flutter app must include:

#### **Customer Features**

* Product listing (with images, price, description)
* Category filtering
* Product details page
* Add-to-cart button
* View/edit cart
* Checkout & submit order
* Order history

#### **Admin Features (via API)**

* Admin login screen (Flutter calls the API)
* Admin-only views for:

  * Adding products
  * Updating products
  * Deleting products
  * Managing categories
  * Viewing orders

### **3. UI Components**

Use Flutter widgets such as:

* `ListView.builder`
* `GridView.builder`
* `FutureBuilder`
* `DataTable`
* `TextFormField` for forms
* `DropdownButton` for categories

### **4. Communication**

Flutter must:

* Send GET or POST requests to the API
* Parse JSON into models
* Display results dynamically
* Handle server errors gracefully

### **5. Running the App**

Run the application normally:

```
flutter run
```

---

## **📌 System Enhancements**

Include the following improvements to make it full-scale:

* Category filter chips or drop-down menus
* Persistent cart storage (SQLite + API sync)
* Rich product details with gallery support
* Admin dashboard UI (Flutter or PHP web interface)
* Input validation (client + server)
* Elegant loading/error states
* Authentication token handling for admin accounts

---

## **📌 Important Notes**

* **Admin Panel** is hosted on the server with PHP (not inside Flutter).
* **Client App** (Flutter) communicates only through the API at:

  ```
  http://abuanplmunflutter.sportsontheweb.net/api/
  ```
* Ensure all PHP files return clean, valid JSON.
* Ensure CORS compatibility if necessary.

---
