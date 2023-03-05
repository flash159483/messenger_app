import 'package:flutter/material.dart';

import '../widgets/chat_component/message.dart';
import '../services/database.dart';

class ChatScreen extends StatelessWidget {
  final chatId;
  final opProfile;
  ChatScreen(this.chatId, this.opProfile);

  @override
  Widget build(BuildContext context) {
    // Scaffold of chat screen
    return FutureBuilder(
      future: Database(uid: opProfile).getUserData(),
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Scaffold(
              body: Center(
              child: CircularProgressIndicator(),
            ))
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                  appBar: AppBar(
                      title: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: snapshot.data.profile == null
                            ? const AssetImage('assets/icons/defaulticon.png')
                            : NetworkImage(snapshot.data.profile),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(snapshot.data.name),
                    ],
                  )),
                  body: Message(
                      chatId, snapshot.data.profile, snapshot.data.uid)),
            ),
    );
  }
}
