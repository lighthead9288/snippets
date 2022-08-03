import 'package:flutter/material.dart';

class LinesPainter extends CustomPainter {
  final int lines;
  final bool frequentDivisions;

  LinesPainter({required this.lines, this.frequentDivisions = true});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    var width = size.width;
    var startHeigth = 0.0;
    var lineLength = 5;
    var divisions = frequentDivisions ? 10 : 3;
    for (var i = 0; i <= lines.floor(); i += (lines / divisions).floor()) {
      var startingPoint = Offset(width / lines * i, startHeigth);
      var endingPoint = Offset(width / lines * i, startHeigth + lineLength);
      canvas.drawLine(startingPoint, endingPoint, paint);

      final textPainter = TextPainter(
          text: TextSpan(
              text: _getTimeView(i),
              style: const TextStyle(fontSize: 15, color: Colors.black)),
          textDirection: TextDirection.ltr);
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(
          canvas, Offset(width / lines * i + 5, startHeigth + lineLength));
    }
  }

  String _getTimeView(int time) {
    var hours = time ~/ 60;
    var minutes = time - hours * 60;
    var hoursString = (hours >= 10) ? hours.toString() : "0$hours";
    var minutesString = (minutes >= 10) ? minutes.toString() : "0$minutes";
    var secondsString = "00";
    return "$hoursString:$minutesString:$secondsString";
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}