import 'package:flutter/material.dart';
import 'dart:io';

import '../services/database.dart';
import '../modal/theme_data.dart';
import '../widgets/upload_image.dart';
import '../modal/user_modal.dart';

class EditProfile extends StatefulWidget {
  final UserProfile profile;
  EditProfile(this.profile);
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _key = GlobalKey<FormState>();
  String name;
  String message;

  // user submit changes update database
  void saveForm() {
    final bool check = _key.currentState.validate();
    if (!check) {
      return;
    }
    _key.currentState.save();
    UserProfile tmp = UserProfile(
        email: widget.profile.email,
        friends: widget.profile.friends,
        name: name,
        profile: widget.profile.profile,
        uid: widget.profile.uid,
        profileMessage: message);
    Database(uid: tmp.uid).updateUserData(tmp);
    Navigator.of(context).pop(tmp);
  }

  void getImage(File image) async {
    Database(uid: widget.profile.uid).uploadImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveForm,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Container(
            padding: const EdgeInsets.only(bottom: defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  child:
                      UploadImage(getImage, init_image: widget.profile.profile),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        label: Opacity(
                            opacity: 0.6,
                            child:
                                Text('name', style: TextStyle(fontSize: 15)))),
                    textAlign: TextAlign.center,
                    initialValue: widget.profile.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                    onSaved: (newValue) {
                      name = newValue;
                    },
                    validator: (value) {
                      if (value.length < 4) {
                        return 'Username must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        label: Opacity(
                      opacity: 0.6,
                      child: Text('Profile_message',
                          style: TextStyle(fontSize: 10)),
                    )),
                    initialValue: widget.profile.profileMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                    onSaved: (newValue) {
                      message = newValue;
                    },
                  ),
                ),
                const Divider(thickness: 1.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
