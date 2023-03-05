import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messenger_app/widgets/chat_component/picture.dart';

import '../../modal/theme_data.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final opProfile;
  final read;
  final time;
  final int type;
  ChatBubble(
      this.text, this.isMe, this.read, this.opProfile, this.time, this.type);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: defaultPadding),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isMe && !read)
                // when the opponent user has not read the message
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text('1'),
                    SizedBox(
                      width: defaultPadding / 2,
                    )
                  ],
                ),
              // only the profile picture of the opposite user is shonw
              if (!isMe) ...[
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: opProfile == null
                      ? const AssetImage('assets/icons/defaulticon.png')
                      : NetworkImage(opProfile),
                ),
                const SizedBox(
                  width: defaultPadding / 2,
                )
              ],
              // the container for text type message
              if (type == messageType.text.index)
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding * 0.7,
                    vertical: defaultPadding / 2,
                  ),
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(isMe ? 1 : 0.8),
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(text,
                      style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyText1.color)),
                ),
              // container for picture type message
              if (type == messageType.picture.index)
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Picture(text),
                    ));
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    child: Image.network(text, fit: BoxFit.cover),
                  ),
                ),
              // when the current use have not read the message
              Column(
                children: [if (!isMe && !read) const Text('1')],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Opacity(
                opacity: 0.7,
                child: Text(DateFormat('MM/dd hh:mm').format(time.toDate()),
                    style: const TextStyle(fontSize: 10))),
          ),
        ],
      ),
    );
  }
}
