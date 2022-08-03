import 'package:flutter/material.dart';

class ButterflyWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ButterflyWidgetState();
}

class _ButterflyWidgetState extends State<ButterflyWidget> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: Image.asset('assets/logo_2.jpg', height: 100, width: 100)
      )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}