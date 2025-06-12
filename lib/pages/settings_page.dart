import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_project/user_id _screens/home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userProfile = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('info')
            .get();

        _firstNameController.text = userProfile['firstName'] ?? '';
        _lastNameController.text = userProfile['lastName'] ?? '';
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Kullanıcı verileri yüklenemedi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updatePassword() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(_passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifre güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifre güncellenemedi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('info')
            .set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil bilgileri güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil güncellenemedi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _clearData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        CollectionReference expensesCollection =
            _firestore.collection('users').doc(user.uid).collection('expenses');
        CollectionReference incomeCollection =
            _firestore.collection('users').doc(user.uid).collection('income');
        CollectionReference targetsCollection =
            _firestore.collection('users').doc(user.uid).collection('targets');

        await Future.wait([
          _deleteCollection(expensesCollection),
          _deleteCollection(incomeCollection),
          _deleteCollection(targetsCollection),
        ]);

        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gelir, gider ve hedef verileri temizlendi')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler temizlenemedi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteCollection(CollectionReference collection) async {
    QuerySnapshot querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    QuerySnapshot updatedSnapshot = await collection.get();
    if (updatedSnapshot.docs.isEmpty) {
      print('Tüm veriler başarıyla silindi.');
    } else {
      print('Bazı veriler silinemedi.');
    }
  }

  Future<void> _logOut() async {
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oturum kapatıldı')),
    );

    // HomeScreen sayfasına yönlendirme
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hesap silindi')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hesap silinemedi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const Text(
              'Profil Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'İsim'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Soyisim'),
            ),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Profil Bilgilerini Güncelle'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Şifre Değiştirme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Yeni Şifre'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _updatePassword,
              child: const Text('Şifre Güncelle'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text('Verileri Temizle'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _logOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text('Oturumu Kapat'),
            ),
            ElevatedButton(
              onPressed: _deleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text('Hesabı Sil'),
            ),
          ],
        ),
      ),
    );
  }
}
