// Admin Dashboard JavaScript
class AdminDashboard {
    constructor() {
        this.apiBaseURL = 'http://abuanplmunflutter.sportsontheweb.net/api/';
        this.token = localStorage.getItem('adminToken');
        this.currentUser = JSON.parse(localStorage.getItem('currentUser') || 'null');
        
        this.initializeEventListeners();
        this.checkAuth();
    }

    initializeEventListeners() {
        // Login form
        const loginForm = document.getElementById('login-form');
        if (loginForm) {
            loginForm.addEventListener('submit', (e) => this.handleLogin(e));
        }

        // Navigation
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach(item => {
            item.addEventListener('click', (e) => this.handleNavigation(e));
        });

        // Logout
        const logoutBtn = document.getElementById('logout-btn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => this.handleLogout());
        }

        // Product management
        const addProductBtn = document.getElementById('add-product-btn');
        if (addProductBtn) {
            addProductBtn.addEventListener('click', () => this.showProductModal());
        }

        // Modal close buttons
        const closeButtons = document.querySelectorAll('.close, #close-product-modal');
        closeButtons.forEach(btn => {
            btn.addEventListener('click', () => this.closeModal());
        });

        // Product form
        const productForm = document.getElementById('product-form');
        if (productForm) {
            productForm.addEventListener('submit', (e) => this.handleProductForm(e));
        }
    }

    async checkAuth() {
        if (!this.token) {
            this.showLoginScreen();
            return;
        }

        // Verify token is still valid
        try {
            const response = await fetch(`${this.apiBaseURL}verify_token.php`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.token}`
                }
            });

            if (!response.ok) {
                throw new Error('Token verification failed');
            }

            this.showDashboardScreen();
            this.loadDashboardData();
        } catch (error) {
            localStorage.removeItem('adminToken');
            localStorage.removeItem('currentUser');
            this.token = null;
            this.showLoginScreen();
        }
    }

    showLoginScreen() {
        document.getElementById('login-screen').classList.add('active');
        document.getElementById('dashboard-screen').classList.remove('active');
    }

    showDashboardScreen() {
        document.getElementById('login-screen').classList.remove('active');
        document.getElementById('dashboard-screen').classList.add('active');
    }

    async handleLogin(e) {
        e.preventDefault();
        
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        const errorDiv = document.getElementById('login-error');

        try {
            const response = await fetch(`${this.apiBaseURL}login.php`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    username: username,
                    password: password
                })
            });

            const result = await response.json();

            if (result.success) {
                this.token = result.data.token;
                this.currentUser = result.data.user;
                
                localStorage.setItem('adminToken', this.token);
                localStorage.setItem('currentUser', JSON.stringify(this.currentUser));
                
                this.showDashboardScreen();
                this.loadDashboardData();
            } else {
                this.showError(errorDiv, result.message || 'Login failed');
            }
        } catch (error) {
            this.showError(errorDiv, 'Login failed. Please try again.');
        }
    }

    handleLogout() {
        localStorage.removeItem('adminToken');
        localStorage.removeItem('currentUser');
        this.token = null;
        this.currentUser = null;
        this.showLoginScreen();
    }

    handleNavigation(e) {
        const targetScreen = e.target.closest('.nav-item').dataset.screen;
        
        // Update active nav item
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        e.target.closest('.nav-item').classList.add('active');

        // Show target content
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        document.getElementById(`${targetScreen}-content`).classList.add('active');

        // Load data for the section
        this.loadSectionData(targetScreen);
    }

    async loadSectionData(section) {
        switch(section) {
            case 'products':
                await this.loadProducts();
                break;
            case 'orders':
                await this.loadOrders();
                break;
            case 'categories':
                await this.loadCategories();
                break;
            case 'users':
                await this.loadUsers();
                break;
        }
    }

    async loadDashboardData() {
        try {
            // Load all dashboard stats
            const [ordersResponse, productsResponse, usersResponse] = await Promise.all([
                fetch(`${this.apiBaseURL}get_orders.php`, {
                    headers: { 'Authorization': `Bearer ${this.token}` }
                }),
                fetch(`${this.apiBaseURL}get_products.php`, {
                    headers: { 'Authorization': `Bearer ${this.token}` }
                }),
                fetch(`${this.apiBaseURL}get_users.php`, {
                    headers: { 'Authorization': `Bearer ${this.token}` }
                })
            ]);

            const ordersData = await ordersResponse.json();
            const productsData = await productsResponse.json();
            const usersData = await usersResponse.json();

            if (ordersData.success) {
                document.getElementById('total-orders').textContent = ordersData.data.length;
                document.getElementById('total-revenue').textContent = this.calculateRevenue(ordersData.data);
            }

            if (productsData.success) {
                document.getElementById('total-products').textContent = productsData.data.length;
            }

            if (usersData.success) {
                document.getElementById('total-users').textContent = usersData.data.length;
            }

        } catch (error) {
            console.error('Error loading dashboard data:', error);
        }
    }

    calculateRevenue(orders) {
        const total = orders.reduce((sum, order) => sum + parseFloat(order.total_amount), 0);
        return `₱${total.toFixed(2)}`;
    }

    async loadProducts() {
        try {
            const response = await fetch(`${this.apiBaseURL}get_products.php`, {
                headers: { 'Authorization': `Bearer ${this.token}` }
            });

            const result = await response.json();

            if (result.success) {
                this.renderProducts(result.data);
            }
        } catch (error) {
            console.error('Error loading products:', error);
        }
    }

    renderProducts(products) {
        const tbody = document.getElementById('products-tbody');
        tbody.innerHTML = '';

        products.forEach(product => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${product.id}</td>
                <td>${product.name}</td>
                <td>${product.category_name}</td>
                <td>₱${parseFloat(product.price).toFixed(2)}</td>
                <td>${product.stock_quantity}</td>
                <td>
                    <span class="status ${product.is_active ? 'completed' : 'cancelled'}">
                        ${product.is_active ? 'Active' : 'Inactive'}
                    </span>
                </td>
                <td>
                    <button class="btn btn-secondary" onclick="admin.editProduct(${product.id})">Edit</button>
                    <button class="btn btn-danger" onclick="admin.deleteProduct(${product.id})">Delete</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    async loadOrders() {
        try {
            const response = await fetch(`${this.apiBaseURL}get_orders.php`, {
                headers: { 'Authorization': `Bearer ${this.token}` }
            });

            const result = await response.json();

            if (result.success) {
                this.renderOrders(result.data);
            }
        } catch (error) {
            console.error('Error loading orders:', error);
        }
    }

    renderOrders(orders) {
        const tbody = document.getElementById('orders-tbody');
        tbody.innerHTML = '';

        orders.forEach(order => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>#${order.id}</td>
                <td>${order.customer_name}</td>
                <td>${order.created_at.split(' ')[0]}</td>
                <td>₱${parseFloat(order.total_amount).toFixed(2)}</td>
                <td>
                    <span class="status ${order.status.toLowerCase()}">
                        ${order.status}
                    </span>
                </td>
                <td>
                    <button class="btn btn-secondary" onclick="admin.viewOrderDetails(${order.id})">View</button>
                    <button class="btn btn-primary" onclick="admin.updateOrderStatus(${order.id})">Update Status</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    async loadCategories() {
        try {
            const response = await fetch(`${this.apiBaseURL}get_categories.php`, {
                headers: { 'Authorization': `Bearer ${this.token}` }
            });

            const result = await response.json();

            if (result.success) {
                this.renderCategories(result.data);
            }
        } catch (error) {
            console.error('Error loading categories:', error);
        }
    }

    renderCategories(categories) {
        const tbody = document.getElementById('categories-tbody');
        tbody.innerHTML = '';

        categories.forEach(category => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${category.id}</td>
                <td>${category.name}</td>
                <td>${category.description}</td>
                <td>
                    <button class="btn btn-secondary" onclick="admin.editCategory(${category.id})">Edit</button>
                    <button class="btn btn-danger" onclick="admin.deleteCategory(${category.id})">Delete</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    async loadUsers() {
        try {
            const response = await fetch(`${this.apiBaseURL}get_users.php`, {
                headers: { 'Authorization': `Bearer ${this.token}` }
            });

            const result = await response.json();

            if (result.success) {
                this.renderUsers(result.data);
            }
        } catch (error) {
            console.error('Error loading users:', error);
        }
    }

    renderUsers(users) {
        const tbody = document.getElementById('users-tbody');
        tbody.innerHTML = '';

        users.forEach(user => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${user.id}</td>
                <td>${user.username}</td>
                <td>${user.email}</td>
                <td>${user.phone || 'N/A'}</td>
                <td>
                    <button class="btn btn-secondary" onclick="admin.editUser(${user.id})">Edit</button>
                    <button class="btn btn-danger" onclick="admin.deleteUser(${user.id})">Delete</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    showProductModal(product = null) {
        const modal = document.getElementById('product-modal');
        const title = document.getElementById('product-modal-title');
        const form = document.getElementById('product-form');
        
        if (product) {
            title.textContent = 'Edit Product';
            // Populate form with product data
            document.getElementById('product-name').value = product.name;
            document.getElementById('product-description').value = product.description;
            document.getElementById('product-price').value = product.price;
            document.getElementById('product-stock').value = product.stock_quantity;
            document.getElementById('product-image').value = product.image_url;
        } else {
            title.textContent = 'Add Product';
            form.reset();
        }
        
        modal.style.display = 'block';
    }

    closeModal() {
        const modal = document.getElementById('product-modal');
        modal.style.display = 'none';
    }

    async handleProductForm(e) {
        e.preventDefault();
        
        const productData = {
            name: document.getElementById('product-name').value,
            description: document.getElementById('product-description').value,
            price: parseFloat(document.getElementById('product-price').value),
            category_id: parseInt(document.getElementById('product-category').value),
            stock: parseInt(document.getElementById('product-stock').value),
            image: document.getElementById('product-image').value
        };

        try {
            const response = await fetch(`${this.apiBaseURL}add_product.php`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.token}`
                },
                body: JSON.stringify(productData)
            });

            const result = await response.json();

            if (result.success) {
                this.closeModal();
                this.loadProducts();
                this.showNotification('Product saved successfully!', 'success');
            } else {
                this.showNotification(result.message || 'Failed to save product', 'error');
            }
        } catch (error) {
            this.showNotification('Error saving product', 'error');
        }
    }

    editProduct(productId) {
        // Implement product editing
        this.showNotification('Edit product functionality coming soon', 'info');
    }

    async deleteProduct(productId) {
        if (confirm('Are you sure you want to delete this product?')) {
            try {
                const response = await fetch(`${this.apiBaseURL}delete_product.php`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${this.token}`
                    },
                    body: JSON.stringify({ id: productId })
                });

                const result = await response.json();

                if (result.success) {
                    this.loadProducts();
                    this.showNotification('Product deleted successfully!', 'success');
                } else {
                    this.showNotification(result.message || 'Failed to delete product', 'error');
                }
            } catch (error) {
                this.showNotification('Error deleting product', 'error');
            }
        }
    }

    viewOrderDetails(orderId) {
        this.showNotification('View order details functionality coming soon', 'info');
    }

    updateOrderStatus(orderId) {
        this.showNotification('Update order status functionality coming soon', 'info');
    }

    showError(element, message) {
        element.textContent = message;
        element.style.display = 'block';
        
        setTimeout(() => {
            element.style.display = 'none';
        }, 5000);
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        // Remove after 3 seconds
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }
}

// Initialize the admin dashboard when DOM is loaded
let admin;
document.addEventListener('DOMContentLoaded', () => {
    admin = new AdminDashboard();
});

// Add notification styles
const style = document.createElement('style');
style.textContent = `
    .notification {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 5px;
        color: white;
        z-index: 1001;
        animation: slideIn 0.3s ease-in-out;
    }
    
    .notification-success {
        background-color: #27ae60;
    }
    
    .notification-error {
        background-color: #e74c3c;
    }
    
    .notification-info {
        background-color: #3498db;
    }
    
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
`;
document.head.appendChild(style);