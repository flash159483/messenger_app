import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messenger_app/provider/current_data.dart';
import 'package:provider/provider.dart';

import 'package:messenger_app/screens/main_page.dart';
import 'package:messenger_app/theme.dart';
import 'screens/authentication/auth_screen.dart';
import 'screens/authentication/register_screen.dart';
import 'screens/chat_list.dart';
import 'provider/navigation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => NaviagationProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserData(),
          )
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: lightThemeData(context),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MainPage();
              }
              return AuthScreen();
            },
          ),
          routes: {
            Register_Screen.RouteName: (context) => const Register_Screen(),
            ChatList.RouteName: (context) => ChatList(),
          },
        ));
  }
}
