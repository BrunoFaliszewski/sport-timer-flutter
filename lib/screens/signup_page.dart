import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/authentication.dart';
import '../firebase/validator.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({ Key? key }) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text("Sport Timer"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _registerFormKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameTextController,
                  validator: (value) => Validator.validateName(
                    name: value,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Name",
                  ),
                ),
                TextFormField(
                  controller: _emailTextController,
                  validator: (value) => Validator.validateEmail(
                    email: value,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Email",
                  ),
                ),
                TextFormField(
                  controller: _passwordTextController,
                  validator: (value) => Validator.validatePassword(
                    password: value,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Password",
                  ),
                ),
                if (_isProcessing) const CircularProgressIndicator() else Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isProcessing = true;
                          });

                          if (_registerFormKey.currentState!.validate()) {
                            final User? user = await Authentication.registerUsingEmailPassword(
                              name : _nameTextController.text,
                              email : _emailTextController.text,
                              password : _passwordTextController.text,
                            );

                            setState(() {
                              _isProcessing = false;
                            });

                            if (user != null) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => HomePage(user: user),
                                ),
                                ModalRoute.withName('/'),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}