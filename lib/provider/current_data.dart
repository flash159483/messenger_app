import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../modal/user_modal.dart';
import '../services/database.dart';

class UserData with ChangeNotifier {
  UserProfile _profile;

  UserProfile get profile {
    return _profile;
  }

  // get the current login user data and store in the provider
  Future getUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    UserProfile userData = UserProfile(
        email: snapshot.data()['email'],
        friends: snapshot.data()['friends'],
        name: snapshot.data()['name'],
        profile: snapshot.data()['profile'],
        uid: FirebaseAuth.instance.currentUser.uid,
        profileMessage: snapshot.data()['profile_message']);
    _profile = userData;
  }

  Future<void> updateData(var p) async {
    _profile = p;
    await Future.delayed(Duration(seconds: 2));
    notifyListeners();
  }
}
