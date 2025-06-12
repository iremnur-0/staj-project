import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late String _fontUrl;
  bool _fontLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadFontUrl();

    Future.delayed(Duration.zero, () {
      _animationController.forward();
    });
  }

  Future<void> _loadFontUrl() async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref('uploads/fonts/PlayfairDisplaySC-Regular.ttf');
      _fontUrl = await ref.getDownloadURL();
      setState(() {
        _fontLoaded = true;
      });
    } catch (e) {
      print('Font yüklenirken hata oluştu: $e');
    }
  }

  Future<ByteData> _loadFontFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return ByteData.sublistView(response.bodyBytes);
    } else {
      throw Exception('Font yüklenirken hata oluştu: ${response.statusCode}');
    }
  }

  Future<void> _loadCustomFont() async {
    if (_fontLoaded) {
      try {
        final fontData = await _loadFontFromUrl(_fontUrl);
        final fontLoader = FontLoader('PlayfairDisplay')
          ..addFont(Future.value(fontData));
        await fontLoader.load();
      } catch (e) {
        print('Font yüklenirken hata oluştu: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          String email = userData['email'];

          Navigator.pushNamed(context, '/dashboard');
        } else {
          _showErrorDialog('Kullanıcı bilgileri bulunamadı.');
        }
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'Kullanıcı bulunamadı.';
            break;
          case 'wrong-password':
            message = 'Yanlış şifre.';
            break;
          case 'invalid-email':
            message = 'Geçersiz e-posta adresi.';
            break;
          default:
            message = 'Giriş başarısız: ${e.message}';
            break;
        }
        _showErrorDialog(message);
      } catch (e) {
        _showErrorDialog('Giriş başarısız: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hata'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PlayfairDisplay',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'PlayfairDisplay',
                            ),
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontFamily: 'PlayfairDisplay-Bold',
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5)),
                              ),
                              border: const UnderlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'E-mail alanı boş olamaz';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Geçerli bir e-mail adresi girin';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'PlayfairDisplay',
                            ),
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontFamily: 'PlayfairDisplay-Bold',
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5)),
                              ),
                              border: const UnderlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre alanı boş olamaz';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.purple, Colors.lightBlueAccent],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 41, vertical: 15),
                              alignment: Alignment.center,
                              child: const Text(
                                'GİRİŞ YAP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'PlayfairDisplay-Bold',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/sign_up');
                          },
                          child: const Text(
                            'Hesabınız yok mu? Kayıt Olun',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'PlayfairDisplay-Regular',
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
