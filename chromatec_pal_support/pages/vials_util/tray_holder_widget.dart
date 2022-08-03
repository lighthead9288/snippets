import 'package:chromatec_pal_support/models/passive_modules.dart';
import 'package:chromatec_pal_support/pages/vials_util/shifted_rows_rack_widget.dart';
import 'package:chromatec_pal_support/pages/vials_util/unshifted_rows_rack_widget.dart';
import 'package:flutter/material.dart';

class TrayHolderWidget extends StatefulWidget {
  final TrayHolder trayHolder;
  final Function(VialCoordinates vial) onVialClick;
  VialCoordinates? selectedVial;

  TrayHolderWidget({required this.trayHolder, required this.onVialClick, this.selectedVial});

  @override
  State<StatefulWidget> createState() => _TrayHolderWidgetState();
}

class _TrayHolderWidgetState extends State<TrayHolderWidget> {
  late double _deviceHeight;
  late double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var trayHolderHeight = _deviceHeight * 0.85;
    var trayHolderWidth = (_deviceWidth > 500) ? 500.0 : _deviceWidth * 0.9;
    var vialContainerHeight = (_deviceWidth > 500) ? 500.0 : _deviceWidth * 0.9;
    var trayHolder = widget.trayHolder;
    var racks = _getRacks(trayHolder);
    bool isSelectedVialHere = _isSelectedVialHere(racks, widget.selectedVial);
    return Container(
      margin: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            (isSelectedVialHere)
                ? Container(
                    alignment: Alignment.center,
                    width: vialContainerHeight,
                    height: _deviceHeight * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange)
                    ),
                    child: Text(widget.selectedVial!.getVialNumber(), style: const TextStyle(fontSize: 40),),
                  )
                : Container(),
            const SizedBox(height: 10),
            Container(
              width: trayHolderWidth,
              height: trayHolderHeight,
              decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: _racksUI(racks, trayHolderHeight, trayHolderWidth),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _racksUI(List<Rack?> racks, double trayHolderHeight,
      double trayHolderWidth) {
    bool isAnyRackOccupiesAll = racks.any((rack) => ((rack != null) && (rack.occupiesAll)));
    if (isAnyRackOccupiesAll) {
      var rack = racks.firstWhere((rack) => ((rack != null) && (rack.occupiesAll)));
      var rackHeight = trayHolderHeight * 0.95;
      var rackWidth = trayHolderWidth * 0.95;
      return [
        Container(
          margin: EdgeInsets.only(top: 10),
          width: rackWidth,
          height: rackHeight,
          color: Colors.grey[400],
          child: _getRackWidget(rack!, rackHeight, rackWidth),
        )
      ];
    } else {
      return racks.map((rack) {
        var traySlotWidth = trayHolderWidth * 0.95;
        var traySlotHeight = trayHolderHeight * 0.3;
        var rackHeight = traySlotHeight * 0.95;
        var rackWidth = traySlotWidth * 0.95;
        return (rack == null)
            ? Container(
                width: traySlotWidth,
                height: traySlotHeight,
                color: Colors.blueGrey[50]
              )
            : Container(
                margin: EdgeInsets.only(top: 10),
                width: traySlotWidth,
                height: traySlotHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black)
                ),
                child: Container(
                  width: rackWidth,
                  height: rackHeight,
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10)),
                  child: _getRackWidget(rack, rackHeight, rackWidth),
                ),
              );
      }).toList();
    }
  }

  Widget _getRackWidget(Rack rack, double rackHeight, double rackWidth) {
    if (rack is UnshiftedRowsRack) {
      return UnshiftedRowsRackWidget(
        rack: rack, 
        height: rackHeight, 
        width: rackWidth,
        onVialClick: (vial) {
          widget.onVialClick(vial);
        },
        selectedVial: widget.selectedVial,
      );
    } else if (rack is ShiftedRowsRack) {
      return ShiftedRowsRackWidget(
        rack: rack, 
        height: rackHeight, 
        width: rackWidth, 
        onVialClick: (vial) {
          widget.onVialClick(vial);
        },
        selectedVial: widget.selectedVial,
      );
    } else {
      return Container();
    }
  }

  bool _isSelectedVialHere(List<Rack?> racks, VialCoordinates? vial) {
    if (vial == null) {
      return false;
    }
    var selectedVialName = vial.rack.name;
    return racks.any((rack) => rack?.name == selectedVialName);
  }  

  List<Rack?> _getRacks(TrayHolder trayHolder) => [ trayHolder.slot1.rack, trayHolder.slot2.rack, trayHolder.slot3.rack ];
}