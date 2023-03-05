import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_bubble.dart';
import 'chat_input.dart';
import '../../services/database.dart';
import '../../provider/current_data.dart';
import '../../modal/theme_data.dart';

class Message extends StatefulWidget {
  final chatId;
  final opProfile;
  final opuid;
  Message(
    this.chatId,
    this.opProfile,
    this.opuid,
  );

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  int type;

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<UserData>(context, listen: false);

    return Column(
      children: [
        // when a new message is sent the streambuilder rebuild and show that message
        StreamBuilder(
          stream: Database().getMessage(widget.chatId),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Spacer();
            }
            final datafile = snapshot.data.docs;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: ListView.builder(
                  reverse: true,
                  itemCount: datafile.length,
                  itemBuilder: (context, index) => ChatBubble(
                    datafile[index]['text'],
                    datafile[index]['userid'] == p.profile.uid,
                    datafile[index]['read'],
                    widget.opProfile,
                    datafile[index]['timestamp'],
                    datafile[index]['type'],
                  ),
                ),
              ),
            );
          },
        ),
        ChatInput(p.profile.uid, widget.chatId, widget.opuid),
      ],
    );
  }
}
