import 'package:core/src/widgets/butterfly.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: ButterflyWidget()
    );
  }
}