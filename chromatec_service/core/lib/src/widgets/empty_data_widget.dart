import 'package:flutter/widgets.dart';

class EmptyDataWidget extends StatelessWidget {
  final String text;

  EmptyDataWidget({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }

}