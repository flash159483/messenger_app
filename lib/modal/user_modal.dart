import 'package:flutter/material.dart';

class UserProfile {
  String email;
  List<dynamic> friends;
  String name;
  String profile;
  String uid;
  String profileMessage;

  UserProfile({
    @required this.email,
    @required this.friends,
    @required this.name,
    @required this.profile,
    @required this.uid,
    @required this.profileMessage,
  });
}
