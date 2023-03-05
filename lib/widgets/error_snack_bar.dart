import 'package:flutter/material.dart';

//snackbar to show the error that occured
void ErrorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {},
      textColor: Colors.white,
    ),
  ));
}
