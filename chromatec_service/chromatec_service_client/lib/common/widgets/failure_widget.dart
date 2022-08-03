import 'package:flutter/widgets.dart';

class FailureWidget extends StatelessWidget {
  final String text;

  FailureWidget({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }

}