import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/services/auth/firebase_auth_services.dart';
import 'package:kajur_app/screens/auth/register_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  bool _passwordVisible = false;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      if (user.emailVerified) {
        print('sudah verifikasi email');
        Navigator.pushNamed(context, "/home");
      } else {
        // Email belum diverifikasi, tampilkan dialog peringatan
        print('belum verifikasi email');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Email Belum Diverifikasi",
                style: TextStyle(
                  color: Col.blackColor,
                  fontSize: 18,
                  fontWeight: Fw.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Silakan cek email dan verifikasi terlebih dahulu.",
                  ),
                  Text(email),
                ],
              ),
              backgroundColor: Col.secondaryColor,
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle unsuccessful login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      body: _isSigning
          ? Center(
              child: LoadingAnimationWidget.prograssiveDots(
                  color: Col.primaryColor, size: 50),
            )
          : Center(
              child: Scrollbar(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Col.blackColor),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: Typo.bodyTextStyle,
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: _emailController,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(color: Col.blackColor),
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                    color: Col.greyColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email harus diisi';
                                  } else if (!value.contains('@')) {
                                    return 'Masukkan email dengan benar';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Password', style: Typo.bodyTextStyle),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Col.blackColor),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: const TextStyle(
                                    color: Col.greyColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(100),
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                      child: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Col.greyColor.withOpacity(.50),
                                      ),
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: !_passwordVisible,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password harus diisi';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _signIn();
                              }
                            },
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Belum punya akun?",
                                  style: TextStyle(color: Col.blackColor)),
                              const SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const SignUpPage(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        var tween =
                                            Tween(begin: begin, end: end).chain(
                                          CurveTween(curve: curve),
                                        );

                                        var offsetAnimation =
                                            animation.drive(tween);

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Daftar",
                                  style: TextStyle(
                                    color: Col.primaryColor,
                                    fontWeight: Fw.medium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
