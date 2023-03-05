import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../services/database.dart';
import '../../provider/navigation_provider.dart';
import '../../provider/current_data.dart';

class BottomNavigation extends StatefulWidget {
  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  User user;
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<NaviagationProvider>(context);
    final u = Provider.of<UserData>(context);
    return BottomNavigationBar(
        currentIndex: p.index,
        onTap: (value) {
          p.updateCurPage(value);
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'People'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.messenger), label: 'chat'),
          BottomNavigationBarItem(
              icon: CircleAvatar(
                  backgroundColor: p.index == 2
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  radius: 14,
                  backgroundImage: u.profile.profile == null
                      ? const AssetImage('assets/icons/defaulticon.png')
                      : FadeInImage(
                          placeholder:
                              const AssetImage('assets/icons/defaulticon.png'),
                          image: NetworkImage(u.profile.profile),
                        ).image),
              label: 'Profile'),
        ]);
  }
}
