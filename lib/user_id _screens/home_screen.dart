import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;
  late String videoUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    loadCustomFont();
  }

  Future<void> _loadVideo() async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('uploads/videos/background.mp4');

      videoUrl = await storageRef.getDownloadURL();

      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {
            isLoading = false;
          });
          _controller.setLooping(true);
          _controller.play();
        });
    } catch (e) {
      print('Kaynaklar yüklenirken hata oluştu: $e');
    }
  }

  Future<String> _loadFontUrl() async {
    final fontRef = FirebaseStorage.instance
        .ref()
        .child('uploads/fonts/PlayfairDisplaySC-Bold.ttf');
    return await fontRef.getDownloadURL();
  }

  Future<ByteData> loadFontFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return ByteData.sublistView(response.bodyBytes);
  }

  Future<void> loadCustomFont() async {
    final fontUrl = await _loadFontUrl();
    final fontData = await loadFontFromUrl(fontUrl);
    final fontLoader = FontLoader('PlayfairDisplay-Bold')
      ..addFont(Future.value(fontData));
    await fontLoader.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!isLoading && _controller.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            Container(color: Colors.black),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  const Text(
                    'HOŞGELDİNİZ!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay-Bold',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
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
                            horizontal: 48, vertical: 15),
                        alignment: Alignment.center,
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'PlayfairDisplay-Bold',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sign_up');
                    },
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
                          'Kayıt Ol',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'PlayfairDisplay-Bold',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
