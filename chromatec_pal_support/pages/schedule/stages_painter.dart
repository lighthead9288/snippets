import 'package:chromatec_pal_support/models/headspace_method_batch.dart';
import 'package:flutter/material.dart';

class StagesPainter extends CustomPainter {
  final int lines;
  final HeadspaceMethodsBatch methodsBatch;

  StagesPainter({required this.lines, required this.methodsBatch});

  @override
  void paint(Canvas canvas, Size size) {
    var methodHeight = 10.0;
    for (var method in methodsBatch.methods) {
      var methodsPaint = Paint()
        ..strokeWidth = 5
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.square;
      paintAnalysis(canvas, size, method, methodHeight, methodsPaint);
      methodHeight += 70;
    }
  }

  void paintAnalysis(
      Canvas canvas,
      Size size,
      HeadspaceMethodOverlapData methodOverlapData,
      double methodHeight,
      Paint paint) {
    var width = size.width;

    // Paint temperature preparations
    var tempPrepStartTime = methodOverlapData.startingTime;
    var tempPrepEndTime =
        tempPrepStartTime + methodOverlapData.method.temperaturePreparations;
    var tempPrepStartingPoint =
        Offset(width / lines * tempPrepStartTime, methodHeight);
    var tempPrepEndingPoint = Offset(
        tempPrepStartingPoint.dx +
            width / lines * (tempPrepEndTime - tempPrepStartTime),
        tempPrepStartingPoint.dy + 40);
    paint.color = Colors.indigo[300]!;
    canvas.drawRect(
        Rect.fromPoints(tempPrepStartingPoint, tempPrepEndingPoint), paint);

    // Paint overlapping
    var waitOverlapEndTime =
        tempPrepEndTime + methodOverlapData.method.waitOverlap;
    var waitOverlapStartingPoint =
        Offset(width / lines * tempPrepEndTime, methodHeight + 10);
    var waitOverlapEndingPoint = Offset(
        waitOverlapStartingPoint.dx +
            width / lines * (waitOverlapEndTime - tempPrepEndTime),
        waitOverlapStartingPoint.dy + 20);
    paint.color = Colors.red[900]!;
    canvas.drawRect(
        Rect.fromPoints(waitOverlapStartingPoint, waitOverlapEndingPoint),
        paint);

    // Paint injection
    var injectionEndTime =
        waitOverlapEndTime + methodOverlapData.method.injection;
    var injectionStartingPoint =
        Offset(width / lines * waitOverlapEndTime, methodHeight);
    var injectionEndingPoint = Offset(
        injectionStartingPoint.dx +
            width / lines * (injectionEndTime - waitOverlapEndTime),
        injectionStartingPoint.dy + 40);
    paint.color = Colors.greenAccent;
    canvas.drawRect(
        Rect.fromPoints(injectionStartingPoint, injectionEndingPoint), paint);

    // Paint moving home
    var movingHomeEndTime =
        injectionEndTime + methodOverlapData.method.movingHome;
    var movingHomeStartingPoint =
        Offset(width / lines * injectionEndTime, methodHeight);
    var movingHomeEndingPoint = Offset(
        movingHomeStartingPoint.dx +
            width / lines * (movingHomeEndTime - injectionEndTime),
        movingHomeStartingPoint.dy + 40);
    paint.color = Colors.yellow[600]!;
    canvas.drawRect(
        Rect.fromPoints(movingHomeStartingPoint, movingHomeEndingPoint), paint);

    // Paint cycle time
    var cycleTimeEnd = injectionEndTime + methodOverlapData.method.cycleTime;
    var cycleTimeStartingPoint =
        Offset(width / lines * injectionEndTime, methodHeight + 10);
    var cycleTimeEndingPoint = Offset(
        cycleTimeStartingPoint.dx +
            width / lines * (cycleTimeEnd - injectionEndTime),
        cycleTimeStartingPoint.dy + 20);
    paint.color = Colors.orange[400]!;
    canvas.drawRect(
        Rect.fromPoints(cycleTimeStartingPoint, cycleTimeEndingPoint), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}