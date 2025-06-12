import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  User? currentUser;
  List<String> categories = [
    'Maaş',
    'Ek Gelir',
    'Yatırım Gelirleri',
    'Kira Gelirleri',
    'Prim ve Bonuslar',
    'Yardım ve Destek',
    'Hediye ve Ödüller',
    'Diğer',
  ];
  String? selectedCategory;
  List<Map<String, dynamic>> incomeItems = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchIncomeItems();
  }

  Future<void> _fetchIncomeItems() async {
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('income')
          .get();

      setState(() {
        incomeItems = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Gelirler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (selectedCategory != null) {
              setState(() {
                selectedCategory = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body:
          selectedCategory == null ? _buildCategoryGrid() : _buildIncomeList(),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(categories[index], index);
        },
      ),
    );
  }

  Widget _buildCategoryCard(String category, int index) {
    Color cardColor = _getCategoryColor(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            category,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    List<Color> colors = [
      Colors.orange[100]!,
      Colors.orange[200]!,
      Colors.orange[300]!,
      Colors.orange[400]!,
      Colors.orange[500]!,
      Colors.orange[600]!,
      Colors.orange[700]!,
      Colors.orange[800]!,
      Colors.orange[900]!,
    ];
    return colors[index % colors.length];
  }

  Widget _buildIncomeList() {
    final itemsInCategory = incomeItems
        .where((item) => item['category'] == selectedCategory)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: itemsInCategory.length,
      itemBuilder: (context, index) {
        final item = itemsInCategory[index];
        return _buildIncomeItemCard(item);
      },
    );
  }

  Widget _buildIncomeItemCard(Map<String, dynamic> item) {
    DateTime? dateTime = (item['timestamp'] as Timestamp?)?.toDate();

    String formattedDate = dateTime != null
        ? DateFormat('dd MMMM yyyy').format(dateTime)
        : 'Tarih Yok';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(item['description'] ?? 'Açıklama Yok'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item['amount']} ${item['currency'] ?? 'TR'}'),
            Text('Ekleniş Tarihi: $formattedDate'),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
