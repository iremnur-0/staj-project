import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  User? currentUser;
  List<PieChartSectionData> incomeData = [];
  List<PieChartSectionData> expenseData = [];
  List<BarChartGroupData> monthlyIncomeData = [];
  List<BarChartGroupData> monthlyExpenseData = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _fetchIncomeData(currentUser!.uid);
      _fetchExpenseData(currentUser!.uid);
      _fetchMonthlyData(currentUser!.uid);
    }
  }

  Future<void> _fetchIncomeData(String userId) async {
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
          titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
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
          titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
        );
      }).toList();

      setState(() {
        expenseData = newData;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _fetchMonthlyData(String userId) async {
    try {
      List<BarChartGroupData> incomeBars = [];
      List<BarChartGroupData> expenseBars = [];

      var incomeSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('income')
          .orderBy('timestamp', descending: true)
          .get();

      var expenseSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .orderBy('timestamp', descending: true)
          .get();

      Map<String, double> monthlyIncomeMap = {};
      Map<String, double> monthlyExpenseMap = {};

      for (var doc in incomeSnapshot.docs) {
        var data = doc.data();
        DateTime date = (data['timestamp'] as Timestamp).toDate();
        String monthYear = DateFormat('MMM yyyy').format(date);
        if (!monthlyIncomeMap.containsKey(monthYear)) {
          monthlyIncomeMap[monthYear] = 0.0;
        }
        monthlyIncomeMap[monthYear] =
            monthlyIncomeMap[monthYear]! + data['amount'];
      }

      for (var doc in expenseSnapshot.docs) {
        var data = doc.data();
        DateTime date = (data['timestamp'] as Timestamp).toDate();
        String monthYear = DateFormat('MMM yyyy').format(date);
        if (!monthlyExpenseMap.containsKey(monthYear)) {
          monthlyExpenseMap[monthYear] = 0.0;
        }
        monthlyExpenseMap[monthYear] =
            monthlyExpenseMap[monthYear]! + data['amount'];
      }

      Future<void> resetMonthlyData(String userId) async {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('income')
              .where('timestamp', isLessThan: endOfMonth)
              .get()
              .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('expenses')
              .where('timestamp', isLessThan: endOfMonth)
              .get()
              .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

          print('Veriler başarıyla sıfırlandı.');
        } catch (e) {
          print('Veri sıfırlama hatası: $e');
        }
      }

      monthlyIncomeMap.forEach((key, value) {
        incomeBars.add(BarChartGroupData(
          x: DateTime.parse(
                  "2024-${DateFormat('MM').format(DateTime.now())}-01")
              .month,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.blue,
              width: 15,
            ),
          ],
        ));
      });

      monthlyExpenseMap.forEach((key, value) {
        expenseBars.add(BarChartGroupData(
          x: DateTime.parse(
                  "2024-${DateFormat('MM').format(DateTime.now())}-01")
              .month,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.red,
              width: 15,
            ),
          ],
        ));
      });

      setState(() {
        monthlyIncomeData = incomeBars;
        monthlyExpenseData = expenseBars;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Raporlar'),
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Kullanıcı bulunamadı',
                  style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthlyIncomeChart(),
                    const SizedBox(height: 20),
                    _buildMonthlyExpenseChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMonthlyIncomeChart() {
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
            'Aylık Gelirler',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barGroups: monthlyIncomeData,
                titlesData: const FlTitlesData(show: true),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                alignment: BarChartAlignment.spaceAround,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyExpenseChart() {
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
            'Aylık Giderler',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                barGroups: monthlyExpenseData,
                titlesData: const FlTitlesData(show: true),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                alignment: BarChartAlignment.spaceAround,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
