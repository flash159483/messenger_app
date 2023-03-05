import 'package:flutter/material.dart';
import 'package:messenger_app/screens/search_friend.dart';
import 'package:provider/provider.dart';

import 'package:messenger_app/provider/navigation_provider.dart';
import '../services/database.dart';
import '../widgets/screen_component/bottom_navigation.dart';
import 'chat_list.dart';
import 'friend_list.dart';
import 'profile_screen.dart';
import '../provider/current_data.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final p = Provider.of<UserData>(context);
    final pages = [
      FriendList(),
      ChatList(),
      ProfilePage(
        isMe: true,
      )
    ];
    final titles = ['FriendList', 'ChatList', 'ProfilePage'];
    return FutureBuilder(
      future: p.getUserData(),
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : Scaffold(
              appBar: AppBar(
                actions: [
                  Consumer<NaviagationProvider>(
                      builder: (context, value, child) {
                    if (value.index == 0) {
                      return IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SearchFriend(),
                          ));
                        },
                      );
                    }
                    return Container();
                  }),
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () => Database().exit(context),
                  )
                ],
                title: Consumer<NaviagationProvider>(
                  builder: (context, value, child) => Text(titles[value.index]),
                ),
              ),
              bottomNavigationBar: BottomNavigation(),
              body: Consumer<NaviagationProvider>(
                builder: (context, value, child) => pages[value.index],
              ),
            ),
    );
  }
}
