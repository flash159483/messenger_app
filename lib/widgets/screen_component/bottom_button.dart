import 'package:flutter/material.dart';
import 'package:messenger_app/modal/theme_data.dart';

class BottomButton extends StatelessWidget {
  final bool _clicked;
  final VoidCallback press;
  final String text;

  BottomButton(this._clicked, this.press, this.text);

  // Not in used
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.white),
      ),
      color: _clicked ? Colors.white : Colors.transparent,
      elevation: _clicked ? 4 : 0,
      onPressed: press,
      child: Text(
        text,
        style: TextStyle(
            color: _clicked ? contentColorlight : Colors.white, fontSize: 12),
      ),
    );
  }
}
