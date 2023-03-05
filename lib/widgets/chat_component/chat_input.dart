import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../../modal/theme_data.dart';
import '../../services/database.dart';
import '../../provider/current_data.dart';

class ChatInput extends StatefulWidget {
  final uid;
  final chatId;
  final opuid;
  ChatInput(this.uid, this.chatId, this.opuid);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  File _imageFile;
  bool showimage = false;
  bool waiting = false;
  bool isEmojiVisible = false;

  Icon _emojiIcon = Icon(Icons.sentiment_satisfied_alt_outlined,
      color: Colors.black.withOpacity(0.65));

  final focusNode = FocusNode();

  // add the listener to the chat input so that when the user
  // tap outside the chat input the keyboard will disappear
  @override
  void initState() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isEmojiVisible = false;
          _emojiIcon = Icon(Icons.sentiment_satisfied_alt_outlined,
              color: Colors.black.withOpacity(0.65));
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode.removeListener(() {});
    super.dispose();
  }

  void emojiSelected(Emoji emoji) => setState(() {
        _controller.text = _controller.text + emoji.name;
      });

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<UserData>(context, listen: false).profile;
    return WillPopScope(
      child: Column(
        children: [
          // show the preview of the picture the user want to send
          if (showimage)
            Stack(
              children: [
                Container(
                  height: 200,
                  color: Colors.black45,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Image.file(_imageFile)]),
                ),
                Positioned(
                  right: 5,
                  child: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        showimage = !showimage;
                        _imageFile = null;
                        isEmojiVisible = false;
                      });
                    },
                  ),
                )
              ],
            ),
          // show outline of the chat input box
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 1.5, vertical: defaultPadding / 2),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 32,
                      color: const Color(0xFF087949).withOpacity(0.2))
                ]),
            child: SafeArea(
              child: Row(
                children: [
                  // mic function not implemented yet
                  IconButton(
                    icon:
                        Icon(Icons.mic, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: defaultPadding * 0.5),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding * 0.65),
                      decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(40)),
                      child: Row(
                        children: [
                          const SizedBox(width: defaultPadding / 4),
                          Expanded(
                            // message input field
                            child: TextField(
                              focusNode: focusNode,
                              controller: _controller,
                              onSubmitted: (value) {
                                _controller.clear();
                                FocusScope.of(context).unfocus();
                                Database(uid: widget.uid).sendMessage(
                                    widget.chatId,
                                    value.trim(),
                                    messageType.text);
                              },
                              onTap: () {
                                setState(() => isEmojiVisible = false);
                                Database(uid: widget.uid)
                                    .showRead(widget.chatId, widget.opuid);
                              },
                              decoration: InputDecoration(
                                hintText: "Type message",
                                border: InputBorder.none,
                                prefixIcon: IconButton(
                                  icon: _emojiIcon,
                                  onPressed: () async {
                                    focusNode.unfocus();
                                    focusNode.canRequestFocus = false;
                                    setState(() {
                                      isEmojiVisible = !isEmojiVisible;
                                      if (isEmojiVisible) {
                                        _emojiIcon = Icon(Icons.keyboard,
                                            color:
                                                Colors.black.withOpacity(0.65));
                                      } else {
                                        _emojiIcon = Icon(
                                            Icons
                                                .sentiment_satisfied_alt_outlined,
                                            color:
                                                Colors.black.withOpacity(0.65));
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          // get the picture from the gallery
                          IconButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedImage = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80,
                                  maxWidth: 500);
                              if (pickedImage != null) {
                                setState(() {
                                  _imageFile = File(pickedImage.path);
                                  showimage = true;
                                });
                              }
                            },
                            icon: const Icon(Icons.attach_file),
                          ),
                          // taking a picture using camera
                          // Icon of the camera is changed during preview mode
                          showimage
                              ? waiting
                                  ? const CircularProgressIndicator()
                                  : IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: () async {
                                        setState(() {
                                          waiting = true;
                                        });
                                        final url = await Database(uid: p.uid)
                                            .sendImage(_imageFile);
                                        Database(uid: p.uid).sendMessage(
                                            widget.chatId,
                                            url,
                                            messageType.picture);
                                        setState(() {
                                          showimage = false;
                                          _imageFile = null;
                                          waiting = false;
                                        });
                                      },
                                    )
                              : IconButton(
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final pickedImage = await picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 80,
                                        maxWidth: 500);
                                    if (pickedImage != null) {
                                      setState(() {
                                        _imageFile = File(pickedImage.path);
                                        showimage = true;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt_outlined))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isEmojiVisible
              ? SizedBox(
                  height: 300,
                  child: EmojiPicker(
                    config: const Config(
                      columns: 7,
                    ),
                    textEditingController: _controller,
                  ),
                )
              : Container(),
        ],
      ),
      onWillPop: () {
        if (isEmojiVisible) {
          setState(() {
            isEmojiVisible = false;
          });
        } else {
          Navigator.of(context).pop();
        }
        return Future.value(false);
      },
    );
  }
}
