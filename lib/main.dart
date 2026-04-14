import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'card_details_page.dart';
import 'profile_page.dart';
import 'add_money_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qpnlargbiqjyftkqxkvx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwbmxhcmdiaXFqeWZ0a3F4a3Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5NDAwOTcsImV4cCI6MjA5MTUxNjA5N30.JLcR32tTozFa67gBSItr--ssBWsYQjkkGoKuMaeShbI',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, title: 'NeoBank',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true, scaffoldBackgroundColor: Colors.grey[100]),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  Widget _getPage(int index) {
    if (index == 4) return const ProfilePage();
    return [const DashboardScreen(), const Center(child: Text("Map Page")), const Center(child: Text("Transfer Page")), const Center(child: Text("Settings Page"))][index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, selectedItemColor: Colors.blueAccent, unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Transfer"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(), const SizedBox(height: 25),
            _buildBalanceCard(), const SizedBox(height: 30),
            _buildSectionHeader("Your Cards", "+ New Card"), const SizedBox(height: 15),
            _buildCardsList(), const SizedBox(height: 30),
            _buildSectionHeader("Transactions", "See All"), const SizedBox(height: 15),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('users_list').stream(primaryKey: ['id']).limit(1),
      builder: (context, snapshot) {
        String name = (snapshot.hasData && snapshot.data!.isNotEmpty) ? (snapshot.data!.first['name'] ?? "User") : "User";
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Good morning, $name", style: const TextStyle(fontSize: 14, color: Colors.grey)), const SizedBox(height: 4),
                const Text("Welcome to NeoBank", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('cards').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        double totalBalance = snapshot.hasData ? snapshot.data!.fold(0, (sum, card) => sum + (card['amount'] ?? 0).toDouble()) : 0;
        return Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 10))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  GestureDetector(onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible), child: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 10),
              Text(_isBalanceVisible ? "\$${totalBalance.toStringAsFixed(2)}" : "****.**", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E1E2C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyPage())),
                  child: const Text("Add Money", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), TextButton(onPressed: () {}, child: Text(actionText, style: const TextStyle(color: Colors.blueAccent)))],
    );
  }

  Widget _buildCardsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('cards').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
        if (snapshot.data!.isEmpty) return const SizedBox(height: 180, child: Center(child: Text("No cards found.")));
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final card = snapshot.data![index];
              final bgAsset = 'assets/images/card${((int.tryParse(card['id'].toString()) ?? 1) % 10) + 1}.jpg';
              return Container(
                width: 280, margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: AssetImage(bgAsset), fit: BoxFit.cover), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 6))]),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.black.withOpacity(0.25)), padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Icon(Icons.credit_card, color: Colors.white, size: 30), Text(card['expiry'] ?? "MM/YY", style: const TextStyle(color: Colors.white70))]),
                      Text(card['card_number'] ?? "**** **** **** ****", style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(card['card_holder']?.toUpperCase() ?? "CARD HOLDER", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CardDetailsPage(card: card))), child: const Text('Details'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('transactions').stream(primaryKey: ['id']).order('id', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text("No recent transactions."));
        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final txn = snapshot.data![index];
            String createdAt = txn['created_at']?.toString() ?? "";
            if (createdAt.contains('T')) createdAt = "${createdAt.split('T')[0]} ${createdAt.split('T')[1].substring(0, 5)}";
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(backgroundColor: Colors.blue[50], radius: 22, child: const Icon(Icons.storefront, color: Colors.blueAccent)),
                title: Text(txn['organization'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(createdAt, style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 4),
                      Text("Card: ${txn['card_number'] ?? "****"}  •  Trx: ${txn['trx_id'] ?? "N/A"}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                trailing: Text("\$${(double.tryParse(txn['amount'].toString()) ?? 0.0).abs().toStringAsFixed(2)}-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              ),
            );
          },
        );
      },
    );
  }
}