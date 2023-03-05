import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/database.dart';
import '../provider/current_data.dart';
import '../modal/theme_data.dart';
import 'chat_screen.dart';

class ChatList extends StatefulWidget {
  static const RouteName = './chat_list';

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // get all the chat that the user have created
  Future<List<Map<String, dynamic>>> getChatList() async {
    List<Map<String, dynamic>> tmp = [];
    final p = Provider.of<UserData>(context);
    final chats = await Database(uid: p.profile.uid).getAllChat();
    await Future.wait(chats.entries.map((entry) async {
      final key = entry.key;
      final value = entry.value;
      final opData = await Database(uid: key).getUserData();
      final chatData = await Database().getChatbyId(value);
      tmp.add({
        'name': opData.name,
        'profile': opData.profile,
        'timestamp': chatData['timestamp'],
        'lastmessage': chatData['lastmessage'],
        'chatId': entry.value,
        'opId': entry.key,
      });
    }));
    tmp.sort(
      (a, b) => b['timestamp'].compareTo(a['timestamp']),
    );
    return tmp;
  }

  // return the time passed since the last message sent in this chat
  String lastMessage(var timestamp) {
    DateTime date = timestamp.toDate();
    final d = DateTime.now().difference(date).inDays;
    final h = DateTime.now().difference(date).inHours % 24;
    final m = DateTime.now().difference(date).inMinutes % 60;

    if (d != 0) {
      return '${d}d ago';
    } else if (h != 0) {
      return '${h}h ago';
    } else {
      return '${m}m ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding * 0.75),
        child: FutureBuilder(
            future: getChatList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: defaultPadding / 2),
                  child: InkWell(
                    onTap: () {
                      Database().showRead(
                        snapshot.data[index]['chatId'],
                        snapshot.data[index]['opId'],
                      );
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            snapshot.data[index]['chatId'],
                            snapshot.data[index]['opId']),
                      ));
                    },
                    // custom ListTile
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage: snapshot.data[index]['profile'] ==
                                  null
                              ? const AssetImage('assets/icons/defaulticon.png')
                              : NetworkImage(snapshot.data[index]['profile']),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[index]['name'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                if (snapshot.data[index]['lastmessage'] != null)
                                  Opacity(
                                    opacity: 0.7,
                                    child: Text(
                                      snapshot.data[index]['lastmessage']
                                              .startsWith('http')
                                          ? 'Image'
                                          : snapshot.data[index]['lastmessage'],
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (snapshot.data[index]['lastmessage'] != null)
                          Opacity(
                              opacity: 0.7,
                              child: Text(lastMessage(
                                  snapshot.data[index]['timestamp']))),
                      ],
                    ),
                  ),
                ),
              );
            }),
      )),
    );
  }
}
