import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/auth/login.dart';
import 'package:kajur_app/screens/home/home.dart';

class EmailVerifPage extends StatefulWidget {
  const EmailVerifPage({super.key});

  @override
  _EmailVerifPageState createState() => _EmailVerifPageState();
}

class _EmailVerifPageState extends State<EmailVerifPage> {
  late Timer _timer;
  int _seconds = 120; // 2 menit
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _timer = Timer.periodic(
        const Duration(seconds: 3), (_) => _checkEmailVerification());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      if (mounted) {
        setState(() {
          if (_seconds == 0) {
            timer.cancel();
          } else {
            _seconds--;
          }
        });
      }
    });
  }

  void _restartTimer() {
    setState(() {
      _seconds = 120; // Set ulang waktu mundur ke 2 menit
      _isResending = false; // Set ulang variabel mengirim ulang
      _startTimer(); // Mulai kembali timer
    });
  }

  void _checkEmailVerification() async {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null && user.emailVerified) {
        // Email telah diverifikasi, panggil reload() untuk memperbarui status autentikasi
        await user.reload();
        // Tunggu proses reload selesai
        user = FirebaseAuth.instance.currentUser;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // Jika email masih belum diverifikasi, lakukan penanganan sesuai kebutuhan
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (_seconds ~/ 60).toString().padLeft(2, '0');
    String secondsStr = (_seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verifikasi email kamu',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: Text(
                'Kami telah mengirimkan email verifikasi ke email Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 100),
            Text(
              '$minutesStr:$secondsStr',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Visibility(
              visible: _seconds == 0 && !_isResending,
              child: TextButton(
                onPressed: () async {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    try {
                      setState(() {
                        _isResending = true;
                      });
                      await currentUser.sendEmailVerification();
                      showToast(
                          message: 'Email verifikasi telah dikirim ulang.');
                      _restartTimer();
                    } catch (e) {
                      showToast(
                          message: 'Gagal mengirim ulang email verifikasi: $e');
                      setState(() {
                        _isResending = false;
                      });
                    }
                  } else {
                    showToast(message: 'Pengguna belum masuk.');
                  }
                },
                child: const Text('Kirim Ulang'),
              ),
            ),
            Visibility(
              visible: _seconds == 0 && _isResending,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
            const SizedBox(
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
