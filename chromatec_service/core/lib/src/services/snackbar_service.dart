import 'package:flutter/material.dart';

class SnackBarService {
  static SnackBarService instance = SnackBarService();
  BuildContext _context;

  set buildContext(BuildContext context) {
    _context = context;
  }

  void showSnackBarError(String message) {    
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2), 
        content: Text(
          message, 
          style: TextStyle(
            color: Colors.white,
            fontSize: 15
          )
        ),
        backgroundColor: Colors.red,
      )
    );
  }

  void showSnackBarSuccess(String message) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2), 
        content: Text(
          message, 
          style: TextStyle(
            color: Colors.white,
            fontSize: 15
          )
        ),
        backgroundColor: Colors.green,
      )
    );
  }

  void showSnackBarInfo(String message, {int duration = 2}) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(                
        duration: Duration(seconds: duration), 
        content: Text(
          message, 
          style: TextStyle(
            color: Colors.white,
            fontSize: 15
          )
        ),
        backgroundColor: Colors.blue[400].withOpacity(0.7),
      )
    );
  }
}