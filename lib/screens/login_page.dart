import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sport_timer/firebase/validator.dart';

import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found for that email.'),
          )
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong password provided.'),
          )
        );
      }
    }

    return user;
  }

  Future<User?> signInWithGoogle() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The account already exists with a different credential.'))
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error occurred while accessing credentials. Try again.'))
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred using Google Sign-In. Try again.'))
        );
      }
    }

    return user;
  }

  Future<FirebaseApp> initializeFirebase() async {
    final FirebaseApp firebaseApp = await Firebase.initializeApp();

    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(user: user)
        )
      );
    }

    return firebaseApp;
  }

  Route _routeToHomePageScreen(User user) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomePage(user: user),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sport Timer"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: initializeFirebase(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                width: 300,
                                child: Card(
                                  child: TextFormField(
                                    controller: _emailTextController,
                                    focusNode: _focusEmail,
                                    validator: (value) => Validator.validateEmail(email: value),
                                    decoration: const InputDecoration(
                                      hintText: "Email",
                                    )
                                  )
                                )
                              ),
                              SizedBox(
                                width: 300,
                                child: Card(
                                  child: TextFormField(
                                    controller: _passwordTextController,
                                    focusNode: _focusPassword,
                                    obscureText: true,
                                    validator: (value) => Validator.validatePassword(password: value),
                                    decoration: const InputDecoration(
                                      hintText: "Password",
                                    )
                                  )
                                )
                              ),
                              SizedBox(
                                width: 300,
                                child: SignInButton(
                                  Buttons.Google,
                                  onPressed: () async {
                                    final User? user = await signInWithGoogle();
                                    if (user != null) {
                                      Navigator.of(context).pushReplacement(_routeToHomePageScreen(user));
                                    }
                                  }
                                )
                              ),
                              SizedBox(
                                width: 300,
                                child: Row(
                                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          _focusEmail.unfocus();
                                          _focusPassword.unfocus();

                                          if (_formKey.currentState!.validate()) {
                                            final User? user = await signInUsingEmailPassword(
                                              email : _emailTextController.text,
                                              password : _passwordTextController.text,
                                            );

                                            if (user != null) {
                                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage(user: user)));
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      )
                                    )
                                  ]
                                )
                              ),
                              SizedBox(
                                width: 300,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignupPage()));
                                        },
                                        child: const Text("Sign Up")
                                      )
                                    )
                                  ]
                                )
                              )
                            ]
                          )
                        )
                      ]
                    );
                  }
                  return const CircularProgressIndicator();
                }
              )
            ]
          )
        )
      )
    );
  }
}
