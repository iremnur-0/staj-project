import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:my_new_project/pages/income_page.dart';
import 'package:my_new_project/pages/expenses_page.dart';
import 'package:my_new_project/pages/settings_page.dart';
import 'package:my_new_project/pages/reports_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double toplamBakiye = 0.0;
  User? currentUser;
  List<PieChartSectionData> incomeData = [];
  List<PieChartSectionData> expenseData = [];
  List<Map<String, dynamic>> recentTransactions = [];
  List<Map<String, dynamic>> goals = [];

  late String _fontUrl;
  bool _fontLoaded = false;

  final List<String> incomeCategories = [
    'Maaş',
    'Ek Gelir',
    'Yatırım Gelirleri',
    'Kira Gelirleri',
    'Prim ve Bonuslar',
    'Yardım ve Destek',
    'Hediye ve Ödüller',
    'Diğer'
  ];

  final List<String> expenseCategories = [
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

  @override
  void initState() {
    super.initState();
    _loadFontUrl();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _fetchBalance(currentUser!.uid);
      _fetchRecentTransactions(currentUser!.uid);
      _fetchGoals(currentUser!.uid);
    }
  }

  Future<void> _loadFontUrl() async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref('uploads/fonts/PlayfairDisplaySC-Regular.ttf');
      _fontUrl = await ref.getDownloadURL();
      await _loadCustomFont();
      setState(() {
        _fontLoaded = true;
      });
    } catch (e) {
      debugPrint('Font yüklenirken hata oluştu: $e');
    }
  }

  Future<void> _loadCustomFont() async {
    try {
      final fontData = await _loadFontFromUrl(_fontUrl);
      final fontLoader = FontLoader('PlayfairDisplay')
        ..addFont(Future.value(fontData));
      await fontLoader.load();
    } catch (e) {
      debugPrint('Font yüklenirken hata oluştu: $e');
    }
  }

  Future<ByteData> _loadFontFromUrl(String url) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return ByteData.sublistView(response.bodyBytes);
      } else {
        throw Exception('Font yüklenirken hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Font URL yüklenirken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> _fetchBalance(String userId) async {
    try {
      double gelirToplam = 0.0;
      double giderToplam = 0.0;

      var incomeSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('income')
          .get();

      for (var doc in incomeSnapshot.docs) {
        var data = doc.data();
        gelirToplam += data['amount'];
      }

      var expenseSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .get();

      for (var doc in expenseSnapshot.docs) {
        var data = doc.data();
        giderToplam += data['amount'];
      }

      setState(() {
        toplamBakiye = gelirToplam - giderToplam;
      });

      await _fetchIncomeData(userId);
      await _fetchExpenseData(userId);
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _fetchIncomeData(String userId) async {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    Map<String, double> categoryTotals = {};
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('income')
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data();
        String category = data['category'] ?? 'Diğer';
        double amount = data['amount'];

        if (categoryTotals.containsKey(category)) {
          categoryTotals[category] = categoryTotals[category]! + amount;
        } else {
          categoryTotals[category] = amount;
        }
      }

      List<PieChartSectionData> newData = categoryTotals.entries.map((entry) {
        return PieChartSectionData(
          value: entry.value,
          color: Colors.orange[
                  (categoryTotals.keys.toList().indexOf(entry.key) + 1) *
                      100] ??
              Colors.orange[200],
          title: entry.key,
          radius: 50,
          titleStyle: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontFamily: 'Playfair Display',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        );
      }).toList();

      setState(() {
        incomeData = newData;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _fetchExpenseData(String userId) async {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    Map<String, double> categoryTotals = {};
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data();
        String category = data['category'] ?? 'Diğer';
        double amount = data['amount'];

        if (categoryTotals.containsKey(category)) {
          categoryTotals[category] = categoryTotals[category]! + amount;
        } else {
          categoryTotals[category] = amount;
        }
      }

      List<PieChartSectionData> newData = categoryTotals.entries.map((entry) {
        return PieChartSectionData(
          value: entry.value,
          color: Colors.red[
                  (categoryTotals.keys.toList().indexOf(entry.key) + 1) *
                      100] ??
              Colors.red[200],
          title: entry.key,
          radius: 50,
          titleStyle: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontFamily: 'Playfair Display',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        );
      }).toList();

      setState(() {
        expenseData = newData;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _updateGoal(
      String userId, String goalId, double additionalAmount) async {
    try {
      var goalDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId);

      var docSnapshot = await goalDoc.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data()!;
        double currentAmount = data['amount'] ?? 0.0;
        double targetAmount = data['targetAmount'] ?? 0.0;

        if (currentAmount + additionalAmount <= targetAmount) {
          await goalDoc.update({
            'amount': currentAmount + additionalAmount,
          });
        } else {
          await goalDoc.update({
            'amount': targetAmount,
          });
        }

        await _fetchGoals(userId);
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _addTransaction(String userId, String type, double amount,
      String description, String category) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(type)
        .add({
      'amount': amount,
      'description': description,
      'category': category,
      'timestamp': Timestamp.now(),
    });

    await _fetchBalance(userId);
    await _fetchRecentTransactions(userId);
  }

  Future<void> _showAddTransactionDialog(
      BuildContext context, String type) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedCategory;
    if (_fontLoaded) {
      _loadCustomFont();
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            type == 'income' ? 'Gelir Ekle' : 'Gider Ekle',
            style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Miktar',
                    labelStyle: TextStyle(fontFamily: 'Playfair Display'),
                    // Font eklenmiş hali
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    labelStyle: TextStyle(fontFamily: 'Playfair Display'),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: const Text(
                    'Kategori seçin',
                    style: TextStyle(fontFamily: 'Playfair Display'),
                  ),
                  items:
                      (type == 'income' ? incomeCategories : expenseCategories)
                          .map((category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                      fontFamily: 'Playfair Display'),
                                ),
                              ))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: TextStyle(fontFamily: 'Playfair Display'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'İptal',
                style: TextStyle(fontFamily: 'Playfair Display'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Ekle',
                style: TextStyle(fontFamily: 'Playfair Display'),
              ),
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                final description = descriptionController.text;
                final category = selectedCategory ?? '';

                if (currentUser != null && category.isNotEmpty) {
                  await _addTransaction(
                    currentUser!.uid,
                    type,
                    amount,
                    description,
                    category,
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addGoal(String userId, double amount, double targetAmount,
      String description) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('goals')
        .add({
      'amount': amount,
      'targetAmount': targetAmount,
      'description': description,
      'timestamp': Timestamp.now(),
    });

    await _fetchGoals(userId);
  }

  Future<void> _showAddGoalDialog(BuildContext context) async {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    final amountController = TextEditingController();
    final targetAmountController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hedef Ekle',
            style: TextStyle(
                fontFamily: 'Playfair Display',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Mevcut Miktar',
                    labelStyle: TextStyle(fontFamily: 'Playfair Display'),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: targetAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Hedef Miktar',
                    labelStyle: TextStyle(fontFamily: 'Playfair Display'),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    labelStyle: TextStyle(fontFamily: 'Playfair Display'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'İptal',
                style: TextStyle(fontFamily: 'Playfair Display'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Ekle',
                style: TextStyle(fontFamily: 'Playfair Display'),
              ),
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                final targetAmount =
                    double.tryParse(targetAmountController.text) ?? 0.0;
                final description = descriptionController.text;

                if (currentUser != null) {
                  await _addGoal(
                    currentUser!.uid,
                    amount,
                    targetAmount,
                    description,
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),
        ],
        title: const Text(
          'Ana Sayfa',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontStyle: FontStyle.italic,
            color: Color(0xFF0D1B2A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: currentUser == null
          ? const Center(
              child: Text(
                'Kullanıcı bulunamadı',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 20),
                    _buildIncomeExpenseChart('Gelirler', incomeData, 'income'),
                    const SizedBox(height: 20),
                    _buildIncomeExpenseChart(
                        'Giderler', expenseData, 'expenses'),
                    const SizedBox(height: 20),
                    _buildRecentTransactions(),
                    const SizedBox(height: 20),
                    _buildGoals(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Toplam Bakiyeniz',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Text(
            '₺${toplamBakiye.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(
      String title, List<PieChartSectionData> data, String type) {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    return GestureDetector(
      onTap: () {
        if (type == 'income') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IncomeScreen()),
          );
        } else if (type == 'expenses') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseScreen()),
          );
        }
      },
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair Display',
              ),
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: data,
                  centerSpaceRadius: 40,
                  sectionsSpace: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showAddTransactionDialog(context, type);
              },
              child: Text(
                'Yeni ${title.toLowerCase()} ekle',
                style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son İşlemler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair Display',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: recentTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'Henüz işlem bulunmuyor.',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Playfair Display',
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: recentTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = recentTransactions[index];
                      final timestamp =
                          (transaction['timestamp'] as Timestamp).toDate();
                      final formattedDate =
                          DateFormat.yMMMd().format(timestamp);
                      final amount = transaction['amount'] as double;
                      final description = transaction['description'] as String;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        title: Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
                          ),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
                          ),
                        ),
                        trailing: Text(
                          '₺${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
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

  Widget _buildGoals() {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Hedefler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair Display',
            ),
          ),
          const SizedBox(height: 8),
          goals.isEmpty
              ? const Center(
                  child: Text(
                    'Henüz hedef bulunmuyor.',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    var goal = goals[index];
                    bool isAchieved = goal['isAchieved'] ?? false;
                    return ListTile(
                      leading: Icon(
                        Icons.star,
                        color: isAchieved ? Colors.red : Colors.yellow,
                      ),
                      title: Text(
                        goal['description'],
                        style: TextStyle(
                          color: isAchieved ? Colors.green : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair Display',
                        ),
                      ),
                      subtitle: Text(
                        'Mevcut: ${NumberFormat.currency(symbol: '₺').format(goal['amount'])} / '
                        'Hedef: ${NumberFormat.currency(symbol: '₺').format(goal['targetAmount'])}',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _showDeleteGoalDialog(context, goal['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showUpdateGoalDialog(context, goal['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _showAddGoalDialog(context),
            child: const Text('Yeni Hedef Ekle'),
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'Playfair Display',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_fontLoaded) {
      _loadCustomFont();
    }
    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return ListTile(
          title: Text(
            goal['title'],
            style: TextStyle(
              fontFamily: 'Playfair Display',
            ),
          ),
          subtitle: Text(
            'Target: ${goal['target']}',
            style: TextStyle(
              fontFamily: 'Playfair Display',
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchRecentTransactions(String userId) async {
    List<Map<String, dynamic>> transactions = [];

    var incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('income')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    for (var doc in incomeSnapshot.docs) {
      var data = doc.data();
      transactions.add({
        'amount': data['amount'],
        'description': data['description'],
        'timestamp': data['timestamp'],
        'type': 'income',
      });
    }

    var expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    for (var doc in expenseSnapshot.docs) {
      var data = doc.data();
      transactions.add({
        'amount': data['amount'],
        'description': data['description'],
        'timestamp': data['timestamp'],
        'type': 'expense',
      });
    }

    transactions.sort((a, b) =>
        (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    setState(() {
      recentTransactions = transactions;
    });
  }

  Future<void> _fetchGoals(String userId) async {
    try {
      var goalCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('goals');

      var snapshot = await goalCollection.get();
      var goals = snapshot.docs.map((doc) {
        var data = doc.data();
        return {
          'id': doc.id,
          'description': data['description'] ?? 'Açıklama Yok',
          'amount': data['amount'] ?? 0.0,
          'targetAmount': data['targetAmount'] ?? 0.0,
        };
      }).toList();

      setState(() {
        this.goals = goals;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _deleteGoal(String userId, String goalId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId)
          .delete();

      await _fetchGoals(userId);
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _showUpdateGoalDialog(
      BuildContext context, String goalId) async {
    final amountController = TextEditingController();

    if (_fontLoaded) {
      _loadCustomFont();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hedef Güncelle',
            style: TextStyle(
              fontFamily: 'Playfair Display',
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                      labelText: 'Eklemek İstediğiniz Miktar',
                      labelStyle: TextStyle(
                        fontFamily: 'Playfair Display',
                      )),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'İptal',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Güncelle',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                ),
              ),
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;

                if (currentUser != null) {
                  await _updateGoal(
                    currentUser!.uid,
                    goalId,
                    amount,
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateGoalAchieved(String goalId, bool achieved) {
    setState(() {
      var goal = goals.firstWhere((g) => g['id'] == goalId);
      goal['isAchieved'] = achieved;
    });
  }

  Future<void> _showDeleteGoalDialog(
      BuildContext context, String goalId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hedef Sil',
            style: TextStyle(
              fontFamily: 'Playfair Display',
            ),
          ),
          content: const Text(
            'Bu hedefi silmek istediğinizden emin misiniz?',
            style: TextStyle(
              fontFamily: 'Playfair Display',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'İptal',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Sil',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                ),
              ),
              onPressed: () async {
                if (currentUser != null) {
                  await _deleteGoal(currentUser!.uid, goalId);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
