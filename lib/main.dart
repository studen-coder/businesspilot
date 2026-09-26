import 'package:flutter/material.dart';

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
                      builder: (context) => const BusinessTypeScreen(),
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
                onPressed: () {},
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
            child: ListTile(
              leading: Icon(business.$2),
              title: Text(business.$1),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${business.$1} selected'),
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
