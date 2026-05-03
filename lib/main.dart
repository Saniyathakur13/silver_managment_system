import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Jewellery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ============= SPLASH SCREEN =============
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Color(0xFF6C5CE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.diamond, size: 50, color: Colors.blue),
              ),
              const SizedBox(height: 24),
              const Text(
                'Silver Jewellery',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                'Management System',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ============= LOGIN SCREEN =============
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_isLoginMode) {
      final result = await ApiService.login(_emailController.text, _passwordController.text);

      setState(() => _isLoading = false);

      if (result['success'] == true && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Login failed')),
        );
      }
    } else {
      final result = await ApiService.register(
        _emailController.text,
        _passwordController.text,
        _emailController.text.split('@')[0],
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please login.'), backgroundColor: Colors.green),
        );
        setState(() => _isLoginMode = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Color(0xFF6C5CE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.diamond, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Silver Jewellery',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isLoginMode ? 'Welcome Back!' : 'Create Account',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoginMode ? 'Sign in to continue' : 'Register to get started',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(_isLoginMode ? 'Login' : 'Register', style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLoginMode ? "Don't have an account? " : "Already have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLoginMode = !_isLoginMode;
                                  _emailController.clear();
                                  _passwordController.clear();
                                });
                              },
                              child: Text(
                                _isLoginMode ? 'Register' : 'Login',
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============= DASHBOARD SCREEN =============
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userEmail = 'User';
  double _silverRate = 75.0;
  int _totalProducts = 5;
  int _totalCustomers = 3;
  double _todaySales = 45000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email') ?? 'User';
      _silverRate = prefs.getDouble('silver_rate') ?? 75.0;
    });
  }
  Future<void> _loadStats() async {
    final stats = await ApiService.getDashboardStats();
    setState(() {
      _todaySales = stats['today_sales'] ?? 0;
      _totalProducts = stats['total_products'] ?? 0;
      _totalCustomers = stats['total_customers'] ?? 0;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Color(0xFF6C5CE7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,', style: TextStyle(color: Colors.white70)),
                        Text(_userEmail, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Ready to manage?', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton('Billing', Icons.receipt, Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BillingScreen()));
                }),
                _actionButton('Silver Rate', Icons.monetization_on, Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SilverRateScreen()));
                }),
                _actionButton('Products', Icons.inventory, Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductScreen()));
                }),
                _actionButton('Customers', Icons.people, Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerScreen()));
                }),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
              ),
              child: Column(
                children: [
                  const Text('Today\'s Stats', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _statRow('Sales', '₹${_todaySales.toStringAsFixed(0)}'),
                  _statRow('Silver Rate', '₹${_silverRate.toStringAsFixed(2)}/gm'),
                  _statRow('Products', '$_totalProducts'),
                  _statRow('Customers', '$_totalCustomers'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ============= SILVER RATE SCREEN =============
class SilverRateScreen extends StatefulWidget {
  const SilverRateScreen({super.key});

  @override
  State<SilverRateScreen> createState() => _SilverRateScreenState();
}

class _SilverRateScreenState extends State<SilverRateScreen> {
  double _silverRate = 75.0;
  final TextEditingController _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSilverRate();
  }

  Future<void> _loadSilverRate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _silverRate = prefs.getDouble('silver_rate') ?? 75.0;
      _rateController.text = _silverRate.toString();
    });
  }

  Future<void> _updateRate() async {
    final newRate = double.tryParse(_rateController.text);
    if (newRate == null || newRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid rate')),
      );
      return;
    }

    setState(() => _silverRate = newRate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('silver_rate', newRate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Silver rate updated to ₹${newRate.toStringAsFixed(2)}/gm'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Silver Rate'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blue, Color(0xFF6C5CE7)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Current Rate', style: TextStyle(color: Colors.white70)),
                  Text('₹${_silverRate.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const Text('per gram', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Rate (₹/gm)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _updateRate,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Update Rate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= PRODUCT SCREEN (FIXED) =============
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> _products = [
    {'id': '1', 'name': 'Silver Ring', 'category': 'Ring', 'price': 750, 'stock': 25, 'weight': 10, 'purity': '925'},
    {'id': '2', 'name': 'Silver Chain', 'category': 'Chain', 'price': 1500, 'stock': 15, 'weight': 20, 'purity': '925'},
    {'id': '3', 'name': 'Silver Earrings', 'category': 'Earring', 'price': 600, 'stock': 30, 'weight': 8, 'purity': '925'},
    {'id': '4', 'name': 'Silver Bracelet', 'category': 'Bracelet', 'price': 900, 'stock': 20, 'weight': 12, 'purity': '925'},
    {'id': '5', 'name': 'Silver Pendant', 'category': 'Pendant', 'price': 450, 'stock': 40, 'weight': 5, 'purity': '925'},
  ];

  bool _showAddForm = false;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _weightController = TextEditingController();

  void _addProduct() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() {
      _products.add({
        'id': DateTime.now().toString(),
        'name': _nameController.text,
        'category': _categoryController.text.isEmpty ? 'General' : _categoryController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0,
        'purity': '925',
      });
      _showAddForm = false;
    });

    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    _categoryController.clear();
    _weightController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully!')),
    );
  }

  void _deleteProduct(String id) {
    setState(() {
      _products.removeWhere((p) => p['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _showAddForm = !_showAddForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showAddForm)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  const Text('Add Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name*',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price*',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stock',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (g)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _showAddForm = false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addProduct,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.diamond, color: Colors.blue),
                    ),
                    title: Text(product['name']),
                    subtitle: Text('${product['category']} • Stock: ${product['stock']} • ${product['weight']}g'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹${product['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: () => _deleteProduct(product['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============= CUSTOMER SCREEN =============
class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Map<String, dynamic>> _customers = [
    {'id': '1', 'name': 'Rajesh Sharma', 'phone': '9876543210', 'email': 'rajesh@example.com', 'due': 0, 'credit': 50000},
    {'id': '2', 'name': 'Priya Patel', 'phone': '9876543211', 'email': 'priya@example.com', 'due': 15000, 'credit': 100000},
    {'id': '3', 'name': 'Amit Kumar', 'phone': '9876543212', 'email': 'amit@example.com', 'due': 5000, 'credit': 25000},
  ];

  bool _showAddForm = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _creditController = TextEditingController();

  void _addCustomer() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() {
      _customers.add({
        'id': DateTime.now().toString(),
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'due': 0,
        'credit': double.tryParse(_creditController.text) ?? 0,
      });
      _showAddForm = false;
    });

    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _creditController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer added successfully!')),
    );
  }

  void _recordPayment(Map<String, dynamic> customer) {
    final paymentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment - ${customer['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Outstanding: ₹${customer['due']}'),
            const SizedBox(height: 16),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(paymentController.text) ?? 0;
              if (amount > 0 && amount <= customer['due']) {
                setState(() {
                  customer['due'] -= amount;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment of ₹$amount recorded!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid amount!')),
                );
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(String id) {
    setState(() {
      _customers.removeWhere((c) => c['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _showAddForm = !_showAddForm),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_showAddForm)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple),
                ),
                child: Column(
                  children: [
                    const Text('Add Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name*',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone*',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _creditController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Credit Limit',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _showAddForm = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addCustomer,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                            child: const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, color: Colors.purple),
                    ),
                    title: Text(customer['name']),
                    subtitle: Text('${customer['phone']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (customer['due'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('₹${customer['due']}', style: const TextStyle(color: Colors.red, fontSize: 11)),
                          ),
                        if (customer['due'] > 0)
                          IconButton(
                            icon: const Icon(Icons.payment, size: 18, color: Colors.green),
                            onPressed: () => _recordPayment(customer),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: () => _deleteCustomer(customer['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============= BILLING SCREEN =============
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final List<Map<String, dynamic>> _cart = [];
  double _discount = 0;
  double _silverRate = 75.0;
  Map<String, dynamic>? _selectedCustomer;

  final List<Map<String, dynamic>> _products = [
    {'id': '1', 'name': 'Silver Ring', 'price': 750, 'category': 'Ring'},
    {'id': '2', 'name': 'Silver Chain', 'price': 1500, 'category': 'Chain'},
    {'id': '3', 'name': 'Silver Earrings', 'price': 600, 'category': 'Earring'},
    {'id': '4', 'name': 'Silver Bracelet', 'price': 900, 'category': 'Bracelet'},
    {'id': '5', 'name': 'Silver Pendant', 'price': 450, 'category': 'Pendant'},
  ];

  final List<Map<String, dynamic>> _customers = [
    {'id': '1', 'name': 'Rajesh Sharma', 'phone': '9876543210', 'due': 0},
    {'id': '2', 'name': 'Priya Patel', 'phone': '9876543211', 'due': 15000},
    {'id': '3', 'name': 'Walk-in Customer', 'phone': '', 'due': 0},
  ];

  @override
  void initState() {
    super.initState();
    _loadSilverRate();
    _selectedCustomer = _customers.last; // Default to walk-in
  }

  Future<void> _loadSilverRate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _silverRate = prefs.getDouble('silver_rate') ?? 75.0;
    });
  }

  double get _subtotal => _cart.fold(0, (sum, item) => sum + (item['total'] as double));
  double get _gst => (_subtotal - _discount) * 0.03;
  double get _total => _subtotal - _discount + _gst;

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cart.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
        'total': product['price'],
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} added to cart')),
    );
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final item = _cart[index];
      int newQuantity = (item['quantity'] as int) + delta;
      if (newQuantity > 0) {
        item['quantity'] = newQuantity;
        item['total'] = item['price'] * newQuantity;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _selectCustomer() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          children: [
            const Text('Select Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(customer['name']),
                    subtitle: Text(customer['phone']),
                    trailing: customer['due'] > 0
                        ? Text('Due: ₹${customer['due']}', style: const TextStyle(color: Colors.red))
                        : null,
                    onTap: () {
                      setState(() => _selectedCustomer = customer);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Customer: ${customer['name']} selected')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkout() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${_selectedCustomer?['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Divider(),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._cart.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${item['name']} x${item['quantity']} = ₹${item['total']}'),
              )),
              const Divider(),
              _summaryLine('Subtotal', _subtotal),
              _summaryLine('Discount', -_discount),
              _summaryLine('GST (3%)', _gst),
              const Divider(),
              _summaryLine('Total', _total, isTotal: true),
              const SizedBox(height: 8),
              Text('Silver Rate: ₹${_silverRate.toStringAsFixed(2)}/gm', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cart.clear();
                _discount = 0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bill generated successfully!')),
              );
            },
            child: const Text('Print Bill'),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('₹${value.abs().toStringAsFixed(2)}', style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _selectCustomer,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Customer: ${_selectedCustomer?['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Silver: ₹${_silverRate.toStringAsFixed(2)}/gm'),
              ],
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return GestureDetector(
                  onTap: () => _addToCart(product),
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.diamond, size: 28, color: Colors.blue),
                        const SizedBox(height: 6),
                        Text(product['name'], style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
                        Text('₹${product['price']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _cart.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Cart Empty', style: TextStyle(fontSize: 14)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                    title: Text(item['name']),
                    subtitle: Text('₹${item['price']} each'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () => _updateQuantity(index, -1),
                        ),
                        Text(item['quantity'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () => _updateQuantity(index, 1),
                        ),
                        const SizedBox(width: 8),
                        Text('₹${item['total']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Colors.red),
                          onPressed: () => _removeFromCart(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, -2))],
            ),
            child: Column(
              children: [
                _summaryLine('Subtotal', _subtotal),
                _summaryLine('Discount', -_discount),
                _summaryLine('GST (3%)', _gst),
                const Divider(),
                _summaryLine('Total', _total, isTotal: true),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Discount (₹)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _checkout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Pay & Bill'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}