import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/validator.dart';
import 'home_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({ Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
          )
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The account already exists for that email.'),
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        )
      );
    }

    return user;
  }

  Route _routeToLoginPageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Sport Timer"),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _registerFormKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 300,
                    child: Card(
                      child: TextFormField(
                        controller: _nameTextController,
                        validator: (value) => Validator.validateName(name: value),
                        decoration: const InputDecoration(hintText: "Name")
                      )
                    )
                  ),
                  SizedBox(
                    width: 300,
                    child: Card(
                      child: TextFormField(
                        controller: _emailTextController,
                        validator: (value) => Validator.validateEmail(email: value),
                        decoration: const InputDecoration(hintText: "Email")
                      )
                    )
                  ),
                  SizedBox(
                    width: 300,
                    child: Card(
                      child: TextFormField(
                        controller: _passwordTextController,
                        validator: (value) => Validator.validatePassword(password: value),
                        decoration: const InputDecoration(hintText: "Password")
                      )
                    )
                  ),
                  SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_registerFormKey.currentState!.validate()) {
                                final User? user = await registerUsingEmailPassword(
                                  name : _nameTextController.text,
                                  email : _emailTextController.text,
                                  password : _passwordTextController.text,
                                );

                                if (user != null) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => HomePage(user: user)),
                                    ModalRoute.withName('/'),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(color: Colors.white),
                            )
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}