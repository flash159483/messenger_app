import 'package:flutter/material.dart';

class Picture extends StatelessWidget {
  String url;
  Picture(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Center(child: Image.network(url)),
    );
  }
}
