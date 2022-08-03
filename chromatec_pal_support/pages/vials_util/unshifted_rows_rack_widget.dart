import 'package:chromatec_pal_support/models/passive_modules.dart';
import 'package:flutter/material.dart';

class UnshiftedRowsRackWidget extends StatefulWidget {
  final UnshiftedRowsRack rack;
  final double height;
  final double width;
  final Function(VialCoordinates vial) onVialClick;
  VialCoordinates? selectedVial;

  UnshiftedRowsRackWidget(
      {required this.rack, required this.height, required this.width, required this.onVialClick, this.selectedVial});

  @override
  State<StatefulWidget> createState() => _UnshiftedRowsRackWidgetState();
}

class _UnshiftedRowsRackWidgetState extends State<UnshiftedRowsRackWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.brown[100], 
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: _getRows(widget.rack, widget.height),
        mainAxisAlignment: MainAxisAlignment.spaceAround
      ),
    );
  }

  List<Widget> _getRows(UnshiftedRowsRack rack, double rackHeight) {
    List<Widget> result = [];
    for(int i = 0; i < rack.rows; i++) {
      result.add(Row(children: _getCells(rack, rackHeight, i), mainAxisAlignment: MainAxisAlignment.spaceAround));
    }
    return result;
  }

  List<Widget> _getCells(UnshiftedRowsRack rack, double rackHeight, int rowNumber) {
    List<Widget> result = [];
    var radius = _getVialRadiusByType(rack, rackHeight);
    for(int columnNumber = 0; columnNumber < rack.columns; columnNumber++) {
      bool isVialSelected = _isVialSelected(widget.selectedVial, rack, rowNumber, columnNumber);
      result.add(
        InkWell(
          child: Container(
            height: radius,
            width: radius,
            decoration: (isVialSelected) 
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
            widget.onVialClick(VialCoordinates(rack: rack, rowNumber: rowNumber, columnNumber: columnNumber));
          },
        )
      );
    }
    return result;
  }


  double _getVialRadiusByType(UnshiftedRowsRack rack, double rackHeight) {
    switch (rack.type) {
      case "VT54":
        return rackHeight * 0.15;
      case "VT15":
        return rackHeight * 0.3;
      default: 
        return 0;
    }
  }

  bool _isVialSelected(VialCoordinates? vial, UnshiftedRowsRack rack, int rowNumber, int columnNumber) {
    return ((vial != null) && (vial.rack.name == rack.name) && (vial.rowNumber == rowNumber) && (vial.columnNumber == columnNumber));
  }
}