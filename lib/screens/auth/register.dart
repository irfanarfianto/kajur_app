import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/services/firebase_auth/firebase_auth_services.dart';
import 'package:kajur_app/screens/auth/login.dart';
import 'package:kajur_app/screens/home/home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUpWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        User? user = await _auth.signUpWithGoogle(credential);

        if (user != null) {
          try {
            // ignore: deprecated_member_use
            await user.updateProfile(displayName: user.displayName);
            showToast(message: "Berhasil daftar akun dengan Google");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } catch (e) {
            showToast(message: "Error setting username: $e");
          }
        } else {}
      } else {
        showToast(message: "Pendaftaran dengan Google dibatalkan.");
      }
    } catch (e) {
      showToast(
          message: "Gagal mendaftar dengan Google, terjadi kesalahan: $e");
    }
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
        // ignore: deprecated_member_use
        await user.updateProfile(displayName: username);
        showToast(message: "Berhasil daftar akun");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        showToast(message: "Error setting username: $e");
      }
    } else {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      appBar: AppBar(
          backgroundColor: DesignSystem.backgroundColor,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
              })),
      body: Center(
        child: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Daftar",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: DesignSystem.medium,
                      color: DesignSystem.blackColor,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: DesignSystem.bodyTextStyle,
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _usernameController,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: DesignSystem.blackColor),
                        decoration: const InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: DesignSystem.greyColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: DesignSystem.bodyTextStyle,
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _emailController,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: DesignSystem.blackColor),
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: DesignSystem.greyColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: DesignSystem.bodyTextStyle,
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: DesignSystem.blackColor),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            color: DesignSystem.greyColor,
                            fontWeight: FontWeight.normal,
                          ),
                          helperText:
                              'Minimal 8 karakter, termasuk huruf dan angka',
                          helperStyle: const TextStyle(
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
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _signUp();
                    },
                    child: Center(
                      child: isSigningUp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: DesignSystem.whiteColor,
                              ),
                            )
                          : const Text(
                              "Daftar akun",
                              style: TextStyle(
                                color: DesignSystem.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: DesignSystem.greyColor.withOpacity(.30),
                            height: 0.5,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Atau"),
                        ),
                        Expanded(
                          child: Divider(
                            color: DesignSystem.greyColor.withOpacity(.30),
                            height: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _signUpWithGoogle();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.whiteColor,
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.google,
                            color: DesignSystem.blackColor,
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Daftar dengan Google",
                            style: TextStyle(
                              color: DesignSystem.blackColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
