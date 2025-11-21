# 🚀 Project Roadmap: Flutter Shopping App with PHP Backend

This roadmap divides the requirements from the `README.md` into sequential batches. Start with the backend foundation, move to the mobile app architecture, and finish with the UI and transaction logic.

---

## **Batch 1: Database & Backend Foundation**
**Goal:** Set up the hosting environment and create the core data structure.

- [x] * **1.1 Database Setup (MySQL)**
    * Log in to your AwardSpace hosting panel: `http://abuanplmunflutter.sportsontheweb.net`.
    * Create a MySQL database.
    * Execute SQL scripts to create the required tables: `users`, `products`, `categories`, `cart`, `orders`, and `order_items`.
- [x] * **1.2 Database Connection**
    * Create a `db_connect.php` file to handle database credentials and connection logic.
- [x] * **1.3 Core Data APIs (CRUD)**
    * Create "Read" endpoints: `/api/get_products.php` and `/api/get_categories.php`.
    * Create "Write" endpoints for product management: `/api/add_product.php`, `/api/update_product.php`, and `/api/delete_product.php`.
    * Create category management endpoint: `/api/add_category.php`.
- [x] * **1.4 Testing**
    * Verify endpoints in the browser (e.g., visit `.../api/get_products.php`) to ensure they return valid JSON.

---

## **Batch 2: Advanced Backend Logic**
**Goal:** Handle authentication and transactional logic on the server side.

- [x] * **2.1 Authentication API**
    * Create `/api/login.php` to handle Admin login requests.
- [x] * **2.2 Cart Management APIs**
    * Create endpoints to manage the shopping cart: `/api/add_to_cart.php`, `/api/get_cart.php`, and `/api/remove_cart_item.php`.
- [x] * **2.3 Order Processing APIs**
    * Create `/api/create_order.php` to finalize transactions.
    * Create `/api/get_orders.php` to view order history.

---

## **Batch 3: Flutter Project Setup & Data Layer**
**Goal:** Initialize the mobile app and establish communication with the server.

- [x] * **3.1 Project Initialization**
    * Run `flutter create shopping_app`.
    * Add dependencies to `pubspec.yaml`: `http` (required) and `provider` (optional).
- [x] * **3.2 Configuration**
    * Create a file to store the `ApiConfig` class with the static base URL: `http://abuanplmunflutter.sportsontheweb.net/api/`.
- [x] * **3.3 Data Models**
    * Create Dart classes to parse JSON responses into objects (e.g., `Product`, `Category`, `CartItem`, `Order`).
- [x] * **3.4 API Service**
    * Create a service class to handle HTTP GET/POST requests using `Uri.parse("${ApiConfig.baseUrl}...")`.
    * Implement functions to parse JSON and handle server errors.

---

## **Batch 4: Admin Features (Flutter Side)**
**Goal:** Build the mobile interface for store management.

- [x] * **4.1 Admin Login**
    * Create a login screen using `TextFormField` that calls the login API.
- [x] * **4.2 Product Management UI**
    * Build "Admin-only views" for Adding, Updating, and Deleting products.
    * Implement forms to input product details (Name, Description, Price, Image).
- [x] * **4.3 Category Management**
    * Create a UI to list current categories and add new ones.

---

## **Batch 5: Customer Features (Storefront)**
**Goal:** Build the browsing and shopping experience for users.

- [x] * **5.1 Product Listing**
    * Implement `GridView.builder` or `ListView.builder` to display products.
    * Use `FutureBuilder` to load data asynchronously from the API.
- [x] * **5.2 Navigation & Details**
    * Create a Product Details page showing the image, price, and description.
    * Implement a "Add to Cart" button on the details page.
- [x] * **5.3 Filtering**
    * Implement category filtering using `DropdownButton` or filter chips.

---

## **Batch 6: Cart, Checkout & Polish**
**Goal:** Finalize the transaction loop and enhance the user experience.

- [ ] * **6.1 Cart UI**
    * Create a screen to view cart items and remove them using the API.
- [ ] * **6.2 Checkout Flow**
    * Implement a submit button that calls `/api/create_order.php`.
- [ ] * **6.3 Order History**
    * Create a view to display past orders for customers and all orders for admins.
- [ ] * **6.4 Enhancements**
    * Add input validation, loading states, and error handling.
    * (Optional) Implement persistent cart storage using SQLite + API sync.

---