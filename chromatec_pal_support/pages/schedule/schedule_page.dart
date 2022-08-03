import 'dart:io';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:chromatec_pal_support/models/headspace_method_batch.dart';
import 'package:chromatec_pal_support/models/pal_method.dart';
import 'package:chromatec_pal_support/pages/schedule/lines_painter.dart';
import 'package:chromatec_pal_support/pages/schedule/stages_painter.dart';
import 'package:chromatec_pal_support/widgets/android/android_controls.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_controls.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final PalHeadspaceMethod headspaceMethod;

  const SchedulePage({Key? key, required this.headspaceMethod}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late double _deviceHeight;
  late double _deviceWidth;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  int _methodsCount = 2;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var methodsBatch = HeadspaceMethodsBatch(methods: _getMethods());
    var widgetsFactory = (Platform.isWindows) ? WindowsControlsFactory(): AndroidControlsFactory();
    return Scaffold(
      appBar: widgetsFactory.createScheduleUtilAppBar().render(widget.headspaceMethod.methodName),
      endDrawer: Drawer(
        child: _getMenuItems(widget.headspaceMethod),
      ),
      body: SizedBox(
        width: _deviceWidth,
        child: AdaptiveScrollbar(
          controller: _verticalScrollController,
          child: AdaptiveScrollbar(
            controller: _horizontalScrollController,
            position: ScrollbarPosition.bottom,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _verticalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _deviceHeight * 0.1,
                        width: _deviceWidth,
                        child: CustomPaint(
                          painter: LinesPainter(
                              lines: methodsBatch.commonTime.ceil(),
                              frequentDivisions: (_deviceWidth > 700)),
                          child: Container(),
                        ),
                      ),
                      SizedBox(
                          height: _deviceHeight * 0.9,
                          width: _deviceWidth,
                          child: CustomPaint(
                            painter: StagesPainter(
                                lines: methodsBatch.commonTime.ceil(),
                                methodsBatch: methodsBatch),
                            child: Container(),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getMenuItems(PalHeadspaceMethod headspaceMethod) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Text('Analyses count'),
            ),
            Slider(
              value: _methodsCount.toDouble(),
              label: _methodsCount.toString(),
              min: 1,
              max: 10,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  _methodsCount = value.toInt();
                });
              }
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.orange[400]
                  ),
                  const Text('Cycle time, min'),
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.setupParamsGroup.analysisTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.setupParamsGroup.analysisTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.indigo[300]
                  ),
                  const Text('Sync before incubation end time, min')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.setupParamsGroup.syncBeforeIncubationEndTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.setupParamsGroup.syncBeforeIncubationEndTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.red[900]
                  ),
                  const Text('Incubation time, min')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.incubateSampleParamsGroup.incubationTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.incubateSampleParamsGroup.incubationTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.red[900]
                  ),
                  const Text('Agitator On time, s')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.incubateSampleParamsGroup.agitatorOnTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.incubateSampleParamsGroup.agitatorOnTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.red[900]
                  ),
                  const Text('Agitator Off time, s')
                ] 
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.incubateSampleParamsGroup.agitatorOffTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.incubateSampleParamsGroup.agitatorOffTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.greenAccent
                  ),
                  const Text('Sample post aspirate delay, s')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.loadSampleParamsGroup.samplePostAspirateDelay.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.loadSampleParamsGroup.samplePostAspirateDelay = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.greenAccent
                  ),
                  const Text('Delay after filling strokes, s')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.loadSampleParamsGroup.delayAfterFillingStrokes.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.loadSampleParamsGroup.delayAfterFillingStrokes = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.greenAccent
                  ),
                  const Text('Pre injection dwell time, s')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.injectSampleParamsGroup.preInjectionDwellTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.injectSampleParamsGroup.preInjectionDwellTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.greenAccent
                  ),
                  const Text('Post injection dwell time, s')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.injectSampleParamsGroup.postInjectionDwellTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.injectSampleParamsGroup.postInjectionDwellTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.greenAccent
                  ),
                  const Text('Pre injection purge time, s')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.prePurgeSyringeParamsGroup.preInjectionPurgeTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.prePurgeSyringeParamsGroup.preInjectionPurgeTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.yellow[600]
                  ),
                  const Text('Post injection purge time, s')
                ]
              ),
            ),
            TextFormField(
              initialValue: headspaceMethod.postPurgeSyringeParamsGroup.postInjectionPurgeTime.toString(),
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.postPurgeSyringeParamsGroup.postInjectionPurgeTime = double.parse(value);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.greenAccent
                  ),
                  const Text('Filling strokes count')
                ]
              ),
            ),
            Slider(
              value: widget.headspaceMethod.loadSampleParamsGroup.fillingStrokesCount.toDouble(),
              label: widget.headspaceMethod.loadSampleParamsGroup.fillingStrokesCount.toString(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  widget.headspaceMethod.loadSampleParamsGroup.fillingStrokesCount = value.toInt();
                });
              }
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.greenAccent
                  ),
                  Container(
                    width: 15,
                    height: 15,
                    margin: const EdgeInsets.only(right: 5),
                    color: Colors.yellow[600]
                  ),
                  const Text('Continious purge'),
                  Switch(
                    value: widget.headspaceMethod.postPurgeSyringeParamsGroup.continiousPurge,
                    onChanged: (value) {
                      setState(() {
                        widget.headspaceMethod.postPurgeSyringeParamsGroup.continiousPurge = value;
                      });
                    }
                  )
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PalHeadspaceMethod> _getMethods() {
    List<PalHeadspaceMethod> results = [];
    for (int i = 0; i < _methodsCount; i++) {
      results.add(widget.headspaceMethod);
    }
    return results;
  }
}