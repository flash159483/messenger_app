import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:io';

import '../../widgets/upload_image.dart';
import '../../widgets/login_field.dart';
import '../../services/auth_service.dart';
import '../chat_list.dart';
import '../../widgets/error_snack_bar.dart';

class Register_Screen extends StatefulWidget {
  const Register_Screen({Key key}) : super(key: key);

  static const RouteName = './register_screen';

  @override
  State<Register_Screen> createState() => _Register_ScreenState();
}

class _Register_ScreenState extends State<Register_Screen> {
  final _formkey = GlobalKey<FormState>();
  final FocusNode _mailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  String _name = "";
  String _email = "";
  String _password = "";
  File _image;
  bool _loading = false;
  bool _visible = true;

  @override
  void dispose() {
    _mailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _saveImage(File I) {
    _image = I;
  }

  // when the user submit information
  void _saveForm() async {
    FocusScope.of(context).unfocus();
    if (!_formkey.currentState.validate()) {
      return;
    }
    _formkey.currentState.save();
    setState(() {
      _loading = true;
    });
    final result =
        await AuthService().registerUser(_name, _email, _password, _image).then(
      (value) {
        if (value == true) {
          Navigator.of(context).pop();
        } else {
          ErrorSnackBar(context, value);
          setState(() {
            _loading = false;
          });
        }
      },
    );
    setState(() {
      _loading = false;
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
            Text('Regsiter now!',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 60),
            UploadImage(_saveImage),
            SizedBox(
              width: double.infinity,
              child: Form(
                key: _formkey,
                child: Column(children: [
                  const SizedBox(height: 15),
                  // name of user
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Fullname',
                      prefixIcon: Icon(Icons.people,
                          color: Theme.of(context).primaryColor),
                    ),
                    validator: (value) {
                      if (value.length < 4) {
                        return 'Username must be at least 4 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_mailFocus);
                    },
                    onSaved: (newValue) {
                      _name = newValue.trimRight().trimLeft();
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // user email
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email,
                          color: Theme.of(context).primaryColor),
                    ),
                    focusNode: _mailFocus,
                    validator: (value) {
                      return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)
                          ? null
                          : 'Please enter a valid email address';
                    },
                    onSaved: (val) {
                      _email = val.trim();
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_passFocus);
                    },
                  ),
                  const SizedBox(height: 15),
                  // user password
                  TextFormField(
                    focusNode: _passFocus,
                    decoration: textInputDecoration.copyWith(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock,
                            color: Theme.of(context).primaryColor),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              _visible = !_visible;
                            });
                          },
                        )),
                    obscureText: _visible,
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
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: _saveForm,
                              child: const Text('Register')),
                        ),
                  const SizedBox(height: 10),
                  // when the user have an account
                  Text.rich(
                    TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Login here!',
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pop();
                                })
                        ]),
                  ),
                ]),
              ),
            )
          ],
        ),
      )),
    );
  }
}
