import 'package:chromatec_pal_support/models/passive_modules.dart';
import 'package:chromatec_pal_support/pages/vials_util/vial_widget.dart';
import 'package:flutter/material.dart';

class ShiftedRowsRackWidget extends StatefulWidget {
  final ShiftedRowsRack rack;
  final double height;
  final double width;
  final Function(VialCoordinates vial) onVialClick;
  VialCoordinates? selectedVial;

  ShiftedRowsRackWidget(
      {required this.rack, required this.height, required this.width, required this.onVialClick, this.selectedVial});

  @override
  State<StatefulWidget> createState() => _ShiftedRowsRackWidgetState();
}

class _ShiftedRowsRackWidgetState extends State<ShiftedRowsRackWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.rack.occupiesAll ? Colors.grey[400]: Colors.brown[100], 
        borderRadius: BorderRadius.circular(10)
      ),
      child: (widget.rack.rackRowsShiftMode == RackShiftMode.RowRight) ? _getRowRight() : _getColumnUp(),
    );
  }

  Widget _getColumnUp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _getColumnUpColumns(widget.rack, widget.height),
    );
  }

  List<Widget> _getColumnUpColumns(ShiftedRowsRack rack, double rackHeight) {
    List<Widget> result = [];
    for(int i = 0; i < rack.columns; i++) {
      result.add(
        Container(
          margin: i.isEven ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 10),
          child: Column(
            children: _getColumnUpCells(rack, rackHeight, i), 
            mainAxisAlignment: MainAxisAlignment.spaceAround
          ),
        )
      );
    }
    return result;
  }

  List<Widget> _getColumnUpCells(ShiftedRowsRack rack, double rackHeight, int columnNumber) {
    List<Widget> result = [];
    var radius = _getVialRadiusByType(rack, rackHeight);
    for(int rowNumber = 0; rowNumber < rack.rows; rowNumber++) {
      bool isVialSelected = _isVialSelected(widget.selectedVial, rack, rowNumber, columnNumber);
      result.add(
        VialWidget(
          radius: radius, 
          isSelected: isVialSelected, 
          onTap: () =>  widget.onVialClick(VialCoordinates(rack: rack, rowNumber: rowNumber, columnNumber: columnNumber))
        )
      );      
    }
    return result;
  }

  Widget _getRowRight() {
    return Column(
      children: _getRowRightRows(widget.rack, widget.height),
      mainAxisAlignment: MainAxisAlignment.spaceAround
    );
  }

  List<Widget> _getRowRightRows(ShiftedRowsRack rack, double rackHeight) {
    List<Widget> result = [];
    for(int i = 0; i < rack.rows; i++) {
      result.add(
        Container(
          margin: i.isEven ? const EdgeInsets.only(left: 50) : const EdgeInsets.only(right: 50),
          child: Row(
            children: _getRowRightCells(rack, rackHeight, i), 
            mainAxisAlignment: MainAxisAlignment.spaceAround
          ),
        )
      );
    }
    return result;
  }

  List<Widget> _getRowRightCells(ShiftedRowsRack rack, double rackHeight, int rowNumber) {
    List<Widget> result = [];
    var radius = _getVialRadiusByType(rack, rackHeight);
    for(int columnNumber = 0; columnNumber < rack.columns; columnNumber++) {
      bool isVialSelected = _isVialSelected(widget.selectedVial, rack, rowNumber, columnNumber);
      result.add(
        VialWidget(
          radius: radius, 
          isSelected: isVialSelected, 
          onTap: () =>  widget.onVialClick(VialCoordinates(rack: rack, rowNumber: rowNumber, columnNumber: columnNumber))
        )
      );
    }
    return result;
  }

  double _getVialRadiusByType(ShiftedRowsRack rack, double rackHeight) {
    switch (rack.type) {
      case "VT12":
        return rackHeight * 0.3;
      case "R60":
        return rackHeight * 0.08;
      default: 
        return 0;
    }
  }

  bool _isVialSelected(VialCoordinates? vial, Rack rack, int rowNumber, int columnNumber) {
    return ((vial != null) && (vial.rack.name == rack.name) && (vial.rowNumber == rowNumber) && (vial.columnNumber == columnNumber));
  }
}