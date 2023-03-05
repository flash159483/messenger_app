import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_profile.dart';
import '../provider/current_data.dart';
import '../modal/theme_data.dart';
import '../services/database.dart';
import '../screens/chat_screen.dart';

class ProfilePage extends StatelessWidget {
  bool isMe;
  final data;
  final add;
  ProfilePage({this.isMe, this.data, this.add = false});
  @override
  Widget build(BuildContext context) {
    final p = isMe ? Provider.of<UserData>(context).profile : data;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultPadding),
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: p.profile == null
                ? const AssetImage('assets/icons/defaulticon.png')
                : NetworkImage(p.profile),
          ),
        ),
        Text(p.name,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        p.profileMessage != null
            ? Opacity(
                opacity: 0.6,
                child: Text(p.profileMessage,
                    style: const TextStyle(fontSize: 20)))
            : const SizedBox(
                height: 30,
              ),
        const Divider(thickness: 1.5),
        if (!add)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: isMe
                ? Column(
                    children: [
                      // for editing the current user profi;e
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) => EditProfile(p),
                          ))
                              .then((value) async {
                            Provider.of<UserData>(context, listen: false)
                                .updateData(value);
                            await Future.delayed(Duration(seconds: 1));
                          });
                        },
                      ),
                      const Text('Edit profile')
                    ],
                  )
                // when inside of friend profile
                : Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            final chatId = await Database(
                                    uid: Provider.of<UserData>(context,
                                            listen: false)
                                        .profile
                                        .uid)
                                .getChatbyFriends(p.uid);
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(chatId, data.uid),
                            ));
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded)),
                      const Text('Start chatting'),
                    ],
                  ),
          ),
        // when adding friend
        if (add)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: Column(
                children: [
                  Consumer<UserData>(
                    builder: (context, value, child) {
                      return IconButton(
                        onPressed: () {
                          Database(uid: value.profile.uid).addFriend(p.uid);
                          Navigator.of(context).pop();
                        },
                        icon: child,
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                  const Text('add Friend'),
                ],
              ))
      ],
    );
  }
}
