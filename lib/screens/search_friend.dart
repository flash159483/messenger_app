import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/login_field.dart';
import '../modal/theme_data.dart';
import '../services/database.dart';
import '../provider/current_data.dart';
import 'friend_profile.dart';
import '../services/database.dart';

class SearchFriend extends StatefulWidget {
  @override
  State<SearchFriend> createState() => _SearchFriendState();
}

class _SearchFriendState extends State<SearchFriend> {
  final _control = TextEditingController();
  String search;
  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<UserData>(context, listen: false);
    return Scaffold(
        appBar: AppBar(title: const Text('search friend')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2, vertical: defaultPadding),
              // search result changes for each character entered
              child: TextField(
                controller: _control,
                decoration: textInputDecoration.copyWith(
                    label: const Text('Name'),
                    prefixIcon: const Icon(Icons.search)),
                onChanged: (value) {
                  setState(() {
                    search = value.trim();
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future:
                    Database(uid: p.profile.uid).searchbyName(search, context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return search == null
                      ? Container()
                      : ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              Database(uid: snapshot.data[index]['uid'])
                                  .getUserData()
                                  .then(
                                    (value) => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FriendProfile(value, add: true)),
                                    ),
                                  );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding,
                                  vertical: defaultPadding),
                              // Custom ListTile
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    backgroundImage: snapshot.data[index]
                                                ['profile'] ==
                                            null
                                        ? const AssetImage(
                                            'assets/icons/defaulticon.png')
                                        : NetworkImage(
                                            snapshot.data[index]['profile']),
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
                                          snapshot.data[index]['name'],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        if (snapshot.data[index]
                                                ['profile_message'] !=
                                            null)
                                          Opacity(
                                            opacity: 0.64,
                                            child: Text(
                                              snapshot.data[index]
                                                  ['profile_message'],
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
                          ),
                        );
                },
              ),
            )
          ],
        ));
  }
}
