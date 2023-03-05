import 'package:flutter/material.dart';

import '../modal/theme_data.dart';
import 'profile_screen.dart';

class FriendProfile extends StatelessWidget {
  final p;
  final add;
  FriendProfile(this.p, {this.add});

  @override
  Widget build(BuildContext context) {
    //friend profile show different button
    return Scaffold(
        appBar: AppBar(title: Text(p.name)),
        body: ProfilePage(
          isMe: false,
          data: p,
          add: add,
        ));
  }
}
