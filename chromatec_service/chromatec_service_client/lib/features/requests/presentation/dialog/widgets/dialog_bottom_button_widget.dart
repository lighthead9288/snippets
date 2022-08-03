import 'package:chromatec_service/features/requests/presentation/dialog/state/dialog_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DialogBottomButtonWidget extends StatelessWidget {
  final DialogButtonProvider provider;
  final void Function() onPressed;  
  
  DialogBottomButtonWidget({@required this.provider, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    switch (provider.state) {
        case DialogButtonState.None:
          return Container();
        case DialogButtonState.Enabled:
          return _getDownwardArrowButton();
        case DialogButtonState.Updated:
          return Stack(
                  children: [
                    _getDownwardArrowButton(),
                    Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.amber),
                        ))
                  ],
                );
        default:
          return Container();
      }
  }

  Widget _getDownwardArrowButton() {
    return FloatingActionButton(
      onPressed: () => onPressed(),
      child: Icon(Icons.keyboard_arrow_down),
      mini: true,
      backgroundColor: Colors.grey[200],
    );
  }

}