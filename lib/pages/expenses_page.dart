import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  User? currentUser;
  List<String> categories = [
    'Kira ve Konut',
    'Faturalar',
    'Gıda ve Alışveriş',
    'Ulaşım',
    'Sağlık',
    'Eğlence ve Hobi',
    'Kıyafet ve Moda',
    'Eğitim ve Kişisel Gelişim',
    'Borç Ödemeleri',
    'Ev Eşyaları ve Mobilya',
    'Sigorta ve Vergiler',
    'Diğer'
  ];
  String? selectedCategory;
  List<Map<String, dynamic>> expenseItems = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchExpenseItems();
  }

  Future<void> _fetchExpenseItems() async {
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('expenses')
          .get();

      setState(() {
        expenseItems = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: Text('Giderler'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
          selectedCategory == null ? _buildCategoryGrid() : _buildExpenseList(),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
          boxShadow: [
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
      Colors.red[100]!,
      Colors.pink[100]!,
      Colors.pink[200]!,
      Colors.red[200]!,
      Colors.red[300]!,
      Colors.pink[300]!,
      Colors.pink[400]!,
      Colors.pink[500]!,
      Colors.pink[600]!,
      Colors.pink[700]!,
      Colors.pink[800]!,
      Colors.pink[900]!,
    ];
    return colors[index % colors.length];
  }

  Widget _buildExpenseList() {
    final itemsInCategory = expenseItems
        .where((item) => item['category'] == selectedCategory)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: itemsInCategory.length,
      itemBuilder: (context, index) {
        final item = itemsInCategory[index];
        return _buildExpenseItemCard(item);
      },
    );
  }

  Widget _buildExpenseItemCard(Map<String, dynamic> item) {
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
