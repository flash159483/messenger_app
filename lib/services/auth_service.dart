import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'database.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future registerUser(
      String name, String email, String password, File image) async {
    try {
      final user = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user != null) {
        await Database(uid: user.uid).saveData(name, email, image);
        return true;
      }
    } on FirebaseAuthException catch (error) {
      String message = 'An error occured';
      if (error.message != null) {
        message = error.message;
      }
      return message;
    }
  }

  Future loginUser(String email, String password) async {
    try {
      User user = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password))
          .user;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (error) {
      return error.message;
    }
  }
}
