import 'package:flutter/material.dart';

class VialWidget extends StatefulWidget {
  final double radius;
  final bool isSelected;
  final Function() onTap;

  VialWidget({required this.radius, required this.isSelected, required this.onTap});

  @override
  State<StatefulWidget> createState() => _VialWidgetState();

}

class _VialWidgetState extends State<VialWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
          child: Container(
            height: widget.radius,
            width: widget.radius,
            decoration: (widget.isSelected) 
              ? BoxDecoration(
                  color: Colors.grey[850],
                  border: Border.all(color: Colors.orangeAccent, width: 8),                  
                  shape: BoxShape.circle
                )
              : BoxDecoration(
                  color: Colors.grey[600],
                  shape: BoxShape.circle
                )
          ),
          onTap: () {
            widget.onTap();
          },
        );
  }

}