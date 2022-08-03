import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class AndroidAddListButton implements IAddListButton {
  @override
  Widget render(void onTap()) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 27),
      child: FloatingActionButton(
        onPressed: () async {
          await onTap();                   
        },
        child: const Icon(Icons.add)
      )
    );
  }

}