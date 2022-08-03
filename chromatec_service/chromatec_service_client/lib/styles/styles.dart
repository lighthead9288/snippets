import 'package:flutter/material.dart';

class ButtonStyles {

  static ButtonStyle blackOutlinedButtonStyle() {
    return ButtonStyle(
          side: MaterialStateProperty.all(BorderSide(color: Colors.black87)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))));
  }

  static ButtonStyle lightBlueOutlinedButtonStyle() {
    return ButtonStyle(
          side: MaterialStateProperty.all(BorderSide(color: Colors.blue[200])),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))));
  }
}

class ButtonTextStyles {

  static TextStyle blackOutlinedButtonTextStyle() {
    return TextStyle(
                                        color: Colors.black87, 
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500);
  }

  static TextStyle lightBlueOutlinedButtonTextStyle() {
    return TextStyle(
                                        color: Colors.blue[200], 
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500);
  }
}