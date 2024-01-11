import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/auth/firebase_auth/firebase_auth_services.dart';
import 'package:kajur_app/screens/auth/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Daftar",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.whiteColor,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: DesignSystem.whiteColor),
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintStyle: TextStyle(color: DesignSystem.greyColor),
                ),
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: DesignSystem.whiteColor),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintStyle: TextStyle(color: DesignSystem.greyColor),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: DesignSystem.whiteColor),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintStyle: TextStyle(color: DesignSystem.greyColor),
                  helperText: 'Minimal 8 karakter, termasuk huruf dan angka',
                  helperStyle: TextStyle(
                    color: DesignSystem.greyColor,
                    fontStyle: FontStyle.italic,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      splashColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          // Mengubah visibilitas teks password
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      child: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: DesignSystem.greyColor,
                      ),
                    ),
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: !_passwordVisible,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  _signUp();
                },
                child: Container(
                  child: Center(
                    child: isSigningUp
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Daftar akun",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun?",
                    style: TextStyle(color: DesignSystem.whiteColor),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Pemeriksaan apakah semua form terisi
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showToast(message: "Semua form harus diisi");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Pemeriksaan apakah password memenuhi persyaratan
    if (!_isPasswordValid(password)) {
      showToast(
        message: "Password minimal 8 karakter, termasuk huruf dan angka",
      );
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    bool isUsernameAvailable = await _auth.isUsernameAvailable(username);

    if (!isUsernameAvailable) {
      showToast(message: "Username sudah dipakai, pilih yang lain ya");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    User? user =
        await _auth.signUpWithEmailAndPassword(email, password, username);

    setState(() {
      isSigningUp = false;
    });

    if (user != null) {
      try {
        await user.updateProfile(displayName: username);
        showToast(message: "Berhasil daftar akun");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        showToast(message: "Error setting username: $e");
      }
    } else {
      print("Ada kesalahan nih");
    }
  }

  bool _isPasswordValid(String password) {
    // Pemeriksaan persyaratan password (minimal 8 karakter, termasuk huruf dan angka)
    if (password.length < 8 ||
        !password.contains(RegExp(r'[a-zA-Z]')) ||
        !password.contains(RegExp(r'[0-9]'))) {
      return false;
    }
    return true;
  }
}
