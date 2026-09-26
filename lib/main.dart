import 'package:flutter/material.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/products_screen.dart';
import 'screens/billing_screen.dart';

void main() {
  runApp(const BusinessPilotApp());
}

class BusinessPilotApp extends StatelessWidget {
  const BusinessPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BusinessPilot',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.business_center_rounded,
                size: 90,
              ),
              const SizedBox(height: 24),
              const Text(
                'BusinessPilot',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'One app to manage your business',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 45),

              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BusinessTypeScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusinessTypeScreen extends StatelessWidget {
  const BusinessTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final businesses = [
      ('Retail Shop', Icons.store),
      ('Grocery', Icons.shopping_cart),
      ('Shopping Mall', Icons.business),
      ('Clothing', Icons.checkroom),
      ('Electronics', Icons.devices),
      ('Restaurant', Icons.restaurant),
      ('Salon', Icons.content_cut),
      ('Clinic', Icons.local_hospital),
      ('Gym', Icons.fitness_center),
      ('Tutor', Icons.school),
      ('Freelancer', Icons.laptop),
      ('Service Business', Icons.handyman),
      ('Other Business', Icons.business_center),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Business Type'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          final business = businesses[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(business.$2),
              ),
              title: Text(
                business.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BusinessDashboard(
                      businessType: business.$1,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.lock_outline,
              size: 70,
            ),
            const SizedBox(height: 30),

            const TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email or phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BusinessTypeScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text('Forgot Password?'),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text('Create New Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessDashboard extends StatelessWidget {
  final String businessType;

  const BusinessDashboard({
    super.key,
    required this.businessType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(businessType),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _dashboardCard(
            context,
            'Products',
            Icons.inventory_2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductsScreen(),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            'Billing',
            Icons.receipt_long,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BillingScreen(),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            'Customers',
            Icons.people,
          ),
          _dashboardCard(
            context,
            'Inventory',
            Icons.warehouse,
          ),
          _dashboardCard(
            context,
            'Payments',
            Icons.payments,
          ),
          _dashboardCard(
            context,
            'Reports',
            Icons.analytics,
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title module selected'),
                ),
              );
            },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
