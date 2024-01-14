import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/auth/firebase_auth/firebase_auth_services.dart';
import 'package:kajur_app/screens/auth/login.dart';
import 'package:kajur_app/screens/home.dart';

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
      key: UniqueKey(),
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: DesignSystem.backgroundColor,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
              icon: Icon(
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
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Daftar",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.blackColor,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.blackColor,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: _usernameController,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: DesignSystem.blackColor),
                        decoration: InputDecoration(
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
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.blackColor,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: _emailController,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: DesignSystem.blackColor),
                        decoration: InputDecoration(
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
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.blackColor,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: DesignSystem.blackColor),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: DesignSystem.greyColor,
                            fontWeight: FontWeight.normal,
                          ),
                          helperText:
                              'Minimal 8 karakter, termasuk huruf dan angka',
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
                    ],
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
                                  color: DesignSystem.whiteColor,
                                ),
                              )
                            : Text(
                                "Daftar akun",
                                style: TextStyle(
                                  color: DesignSystem.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Sudah punya akun?",
                  //       style: TextStyle(color: DesignSystem.blackColor),
                  //     ),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.pop(context);
                  //       },
                  //       child: Text(
                  //         "Login",
                  //         style: TextStyle(
                  //           color: Colors.blue,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _signUpWithGoogle();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: DesignSystem.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: DesignSystem.greyColor),
                      ),
                    ),
                    child: Container(
                      child: Center(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signUpWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

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
            await user.updateProfile(displayName: user.displayName);
            showToast(message: "Berhasil daftar akun dengan Google");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } catch (e) {
            showToast(message: "Error setting username: $e");
          }
        } else {
          print("Ada kesalahan nih");
        }
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
