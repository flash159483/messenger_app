import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/current_data.dart';
import '../modal/theme_data.dart';
import 'friend_profile.dart';
import '../modal/user_modal.dart';
import '../services/database.dart';

class FriendList extends StatefulWidget {
  const FriendList({Key key}) : super(key: key);

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  @override
  Widget build(BuildContext context) {
    final p = Provider.of<UserData>(context);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: StreamBuilder<Object>(
          stream: Database(uid: p.profile.uid).friends(p.profile.friends),
          builder: (context, AsyncSnapshot futuresnapshot) {
            if (futuresnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (futuresnapshot.data == null) {
              return Container();
            }
            final doc = futuresnapshot.data['friends'];
            return Padding(
              padding: const EdgeInsets.only(top: defaultPadding / 2),
              child: ListView.builder(
                itemCount: doc.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<Object>(
                      future: Database(uid: doc[index]).getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }
                        UserProfile data = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding / 2,
                              horizontal: defaultPadding),
                          // See the profile of the friend
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => FriendProfile(
                                    UserProfile(
                                        name: data.name,
                                        profile: data.profile,
                                        profileMessage: data.profileMessage,
                                        uid: data.uid),
                                    add: false),
                              ));
                            },
                            // Custom ListTile
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  backgroundImage: data.profile == null
                                      ? const AssetImage(
                                          'assets/icons/defaulticon.png')
                                      : NetworkImage(data.profile),
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: defaultPadding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                      if (data.profileMessage != null)
                                        Opacity(
                                          opacity: 0.64,
                                          child: Text(
                                            data.profileMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            );
          }),
    );
  }
}
