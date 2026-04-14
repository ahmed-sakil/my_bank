import 'package:flutter/material.dart';

class CardDetailsPage extends StatelessWidget {
  final Map<String, dynamic> card;
  const CardDetailsPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final int cardId = int.tryParse(card['id'].toString()) ?? 1;
    final int bgIndex = (cardId % 10) + 1;
    final String bgAsset = 'assets/images/card$bgIndex.jpg';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(bgAsset),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.05), 
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.credit_card, color: Colors.white, size: 36),
                          Text(card['expiry'] ?? "MM/YY", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                      Text(
                        card['card_number'] ?? "**** **** **** ****",
                        style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 3),
                      ),
                      Text(
                        card['card_holder']?.toUpperCase() ?? "CARD HOLDER",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                'Card Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.tag, 'Card ID', card['id']?.toString() ?? 'N/A'),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.person_outline, 'Card Holder', card['card_holder'] ?? 'N/A'),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.calendar_today, 'Expiry Date', card['expiry'] ?? 'N/A'),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.account_balance_wallet, 'Current Balance', "\$${card['amount'] ?? 0.0}"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}