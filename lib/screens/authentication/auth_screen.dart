import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../widgets/login_field.dart';
import 'register_screen.dart';
import '../../services/auth_service.dart';
import '../../widgets/error_snack_bar.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _email = '';
  String _password = '';
  bool _loading = false;
  bool visible = true;
  final _passfocus = FocusNode();

  final _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passfocus.dispose();
    super.dispose();
  }

  void _saveForm() async {
    FocusScope.of(context).unfocus();
    if (!_formkey.currentState.validate()) {
      return;
    }
    _formkey.currentState.save();
    setState(() {
      _loading = true;
    });
    await AuthService().loginUser(_email, _password).then((value) {
      if (value != true) {
        ErrorSnackBar(context, value);
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/chaticon.png', height: 300),
            Text(
              'Welcome to First messenging app of the series!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formkey,
              child: Column(children: [
                // user email address
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email,
                        color: Theme.of(context).primaryColor),
                  ),
                  validator: (value) {
                    return RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)
                        ? null
                        : 'Please enter a valid email address';
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_passfocus);
                  },
                  onSaved: (val) {
                    _email = val.trim();
                  },
                ),
                const SizedBox(height: 15),
                // user password
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  focusNode: _passfocus,
                  obscureText: visible,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Password',
                    prefixIcon:
                        Icon(Icons.lock, color: Theme.of(context).primaryColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        setState(() {
                          visible = !visible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _password = newValue.trim();
                  },
                ),
                const SizedBox(height: 15),
                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          onPressed: _saveForm,
                          child: const Text('Sign in'),
                        ),
                      ),
                const SizedBox(height: 10),
                // register account
                Text.rich(
                  TextSpan(
                      text: "don't have an account? ",
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Register here!',
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context)
                                    .pushNamed(Register_Screen.RouteName);
                              })
                      ]),
                ),
              ]),
            )
          ],
        ),
      ),
    ));
  }
}
