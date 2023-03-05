import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/modal/theme_data.dart';
import 'package:messenger_app/provider/current_data.dart';
import 'package:messenger_app/screens/authentication/auth_screen.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../modal/user_modal.dart';

class Database {
  final String uid;
  Database({this.uid});

  final userCollection = FirebaseFirestore.instance.collection('users');
  final chatsCollection = FirebaseFirestore.instance.collection('chats');
  final infoCollection = FirebaseFirestore.instance.collection('users_info');

  // when registering user the data the user entered is uploaded to firebase
  Future saveData(String name, String email, File image) async {
    final firebaseRef = FirebaseStorage.instance;

    if (image != null) {
      try {
        TaskSnapshot snapshot = await firebaseRef
            .ref()
            .child('profile')
            .child('$uid.jpg')
            .putFile(image);
        if (snapshot != null) {
          final url = await snapshot.ref.getDownloadURL();
          await userCollection.doc(uid).set({
            'name': name,
            'email': email,
            'friends': [],
            'profile': url,
            'uid': uid,
            'profile_message': null,
          });
        }
      } on FirebaseException catch (error) {
        return error.message;
      }
    } else {
      await userCollection.doc(uid).set({
        'name': name,
        'email': email,
        'friends': [],
        'profile': null,
        'uid': uid,
        'profile_message': null,
      });
    }
    infoCollection.doc(uid).set({'opponents': {}});
  }

  // updating profile to the profile that the user want to change
  Future uploadImage(File image) async {
    final firebaseRef = FirebaseStorage.instance;
    try {
      TaskSnapshot snapshot = await firebaseRef
          .ref()
          .child('profile')
          .child('$uid.jpg')
          .putFile(image);
      if (snapshot != null) {
        final url = await snapshot.ref.getDownloadURL();
        await userCollection.doc(uid).update({'profile': url});
      }
    } catch (error) {
      throw error;
    }
  }

  // In chat screen when user is sending a picture to opponent user
  Future sendImage(File image) async {
    final firebaseRef = FirebaseStorage.instance;
    try {
      TaskSnapshot snapshot = await firebaseRef
          .ref()
          .child('chat')
          .child('${DateTime.now()}.jpg')
          .putFile(image);
      if (snapshot != null) {
        final url = await snapshot.ref.getDownloadURL();
        return url;
      }
    } catch (error) {
      throw error;
    }
  }

  // this will return the user data when the uid is provided
  Future getUserData() async {
    final snapshot = await userCollection.doc(uid).get();
    UserProfile userData = UserProfile(
        email: snapshot.data()['email'],
        friends: snapshot.data()['friends'],
        name: snapshot.data()['name'],
        profile: snapshot.data()['profile'],
        uid: uid,
        profileMessage: snapshot.data()['profile_message']);
    return userData;
  }

  // update user data when the user edit their profile
  Future updateUserData(UserProfile newData) async {
    await userCollection.doc(uid).update({
      'name': newData.name,
      'email': newData.email,
      'friends': newData.friends,
      'profile': newData.profile,
      'uid': newData.uid,
      'profile_message': newData.profileMessage,
    });
  }

  // when adding new friend
  Future addFriend(String opId) async {
    await userCollection.doc(uid).update({
      'friends': FieldValue.arrayUnion([opId])
    });
  }

  // return the friendlist
  Stream friends(friend) {
    return userCollection.doc(uid).snapshots();
  }

  // when the user want to open the chat in friend profile
  // If there are no chat created before this create chat for both users
  Future<String> getChatbyFriends(String op) async {
    final snapshot = await infoCollection.doc(uid).get();
    String chatId = snapshot.data()['opponents'][op];
    if (chatId == null) {
      final newId = await chatsCollection.doc().id;
      await chatsCollection.doc(newId).set({'timestamp': Timestamp.now()});
      infoCollection.doc(uid).set({
        'opponents': {op: newId}
      }, SetOptions(merge: true));
      infoCollection.doc(op).set({
        'opponents': {uid: newId}
      }, SetOptions(merge: true));
      chatId = newId;
    }
    return chatId;
  }

  // For getting the stream of friendList
  Stream getFriendList() {
    return userCollection.doc(uid).snapshots();
  }

  // getting the chat data
  Future getChatbyId(String chatid) async {
    final snapshot = await chatsCollection.doc(chatid).get();
    return snapshot.data();
  }

  // for updating all the chats of that user
  Future<Map<String, dynamic>> getAllChat() async {
    final snapshot = await infoCollection.doc(uid).get();
    return snapshot.data()['opponents'];
  }

  // send the message
  Future sendMessage(String chatId, String text, messageType type) async {
    if (text.isEmpty) {
      return;
    }
    await chatsCollection.doc(chatId).collection('messages').add({
      'text': text,
      'timestamp': Timestamp.now(),
      'userid': uid,
      'type': type.index,
      'read': false,
    });
    await chatsCollection
        .doc(chatId)
        .update({'lastmessage': text, 'timestamp': Timestamp.now()});
  }

  // stream of message of that chat
  Stream getMessage(String chatId) {
    return chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // when user enter the chat or want to send a message all of previous chat
  // send by the opponent is changed to read
  Future showRead(String chatId, String opId) async {
    final snapshot = await chatsCollection
        .doc(chatId)
        .collection('messages')
        .where('userid', isEqualTo: opId)
        .get();
    final documents = snapshot.docs;
    for (DocumentSnapshot d in documents) {
      final tmp = d.data() as Map<String, dynamic>;

      await d.reference.update({'read': true});
    }
  }

  // searching the friend by name
  Future<List> searchbyName(String s, BuildContext context) async {
    final friend =
        Provider.of<UserData>(context, listen: false).profile.friends;
    final snapshot = await userCollection
        .where('name', isGreaterThan: s)
        .where('name', isLessThan: s + 'z')
        .get();
    List<Map> result = [];
    for (DocumentSnapshot d in snapshot.docs) {
      final tmp = d.data() as Map<String, dynamic>;
      if (tmp['uid'] != uid && !friend.contains(tmp['uid'])) {
        result.add(tmp);
      }
    }
    return result;
  }

  // logout
  void exit(BuildContext context) {
    FirebaseAuth.instance.signOut();
  }
}
