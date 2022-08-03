import 'dart:io';

import 'package:chromatec_pal_support/models/pal_module.dart';
import 'package:chromatec_pal_support/models/passive_modules.dart';
import 'package:chromatec_pal_support/pages/vials_util/tray_holder_widget.dart';
import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:chromatec_pal_support/widgets/android/android_controls.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class VialsUtilPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VialsUtilPageState();
}

class _VialsUtilPageState extends State<VialsUtilPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  VialCoordinates? _selectedVial;

  final TrayHolder _trayHolder1 = TrayHolder(
    name: "Tray Holder 1",
    slot1: TrayHolderSlot(
      name: "Slot 1",
      rack: UnshiftedRowsRack(name: "Rack 1", type: "VT54", rows: 6, columns: 9, enumerationType: RackEnumerationType.LeftToRight)      
    ),
    slot2: TrayHolderSlot(
      name: "Slot 2",
      rack: UnshiftedRowsRack(name: "Rack 2", type: "VT15", rows: 3, columns: 5, enumerationType: RackEnumerationType.LeftToRight)      
    ),
    slot3: TrayHolderSlot(
      name: "Slot 3",
      rack: ShiftedRowsRack(
        rackRowsShiftMode: RackShiftMode.RowRight, 
        name: "Rack 3", 
        type: "VT12", 
        rows: 3, 
        columns: 4, 
        enumerationType: RackEnumerationType.LeftToRight, 
        occupiesAll: false
      )
    )
    
  );

  final TrayHolder _trayHolder2 = TrayHolder(
    name: "Tray Holder 2",
    slot1: TrayHolderSlot(
      name: "Slot 1",
      rack: UnshiftedRowsRack(name: "Rack 4", type: "VT54", rows: 6, columns: 9, enumerationType: RackEnumerationType.LeftToRight)      
    ),
    slot2: TrayHolderSlot(
      name: "Slot 2",
      rack: UnshiftedRowsRack(name: "Rack 5", type: "VT15", rows: 3, columns: 5, enumerationType: RackEnumerationType.LeftToRight)      
    ),
    slot3: TrayHolderSlot(
      name: "Slot 3",
      rack: ShiftedRowsRack(rackRowsShiftMode: RackShiftMode.ColumnUp, name: "Rack 6", type: "R60", rows: 10, columns: 6, enumerationType: RackEnumerationType.TopToBottom, occupiesAll: true)
    )
  );

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
        return true;
      },
      child: ChangeNotifierProvider<ConfigurationProvider>.value(
        value: ConfigurationProvider.instance,
        child: Consumer<ConfigurationProvider>(
          builder: (_, provider, __) => _ui(provider)
        )
      ),
    );
  }

  Widget _ui(ConfigurationProvider provider) {
    var trayHolders = _getTrayHoldersList(provider);
    var widgetsFactory = (Platform.isWindows) ? WindowsControlsFactory(): AndroidControlsFactory();
    return DefaultTabController(
      length: trayHolders.length,
      child:  Scaffold(
        appBar: widgetsFactory.createVialsUtilAppBar().render(trayHolders),
        body: (trayHolders.isNotEmpty) 
          ? TabBarView(children: _getTrayHolders(trayHolders))
          : const Center(child: Text('No data yet'))
      )
    );
  }


  List<Widget> _getTrayHolders(List<TrayHolder> trayHolders) {
    return trayHolders.map((trayHolder) => 
        Center(
        child: TrayHolderWidget(
          trayHolder: trayHolder, 
          onVialClick: (vial) {
            setState(() {
              _selectedVial = vial;
            });
          },
          selectedVial: _selectedVial,
        )
      )
    ).toList();
  }

  List<TrayHolder> _getTrayHoldersList(ConfigurationProvider provider) {
    try {
      var trayHolderModules = provider.modules.where((module) => module.type == "TrayHolderRectangleDescription").toList();
      return trayHolderModules.map((module) {
        var slots = module.childReferences.map((ref) => provider.getModuleByUri(ref)).toList();
        var rackModules = slots.map((slot) => 
          (slot.childReferences.isNotEmpty) 
            ? provider.getModuleByUri(slot.childReferences.first)
            : null
        ).toList();
        var racks = rackModules.map((rack) => 
          (rack != null) 
          ? _getRackData(rack, provider)
          : null
        ).toList();      
        return TrayHolder(
          name: module.name, 
          slot1: TrayHolderSlot(name: slots[0].name, rack: racks[0]), 
          slot2: TrayHolderSlot(name: slots[1].name, rack: racks[1]), 
          slot3: TrayHolderSlot(name: slots[2].name, rack: racks[2])
        );
      }).toList();
    } catch(e) {
      return [];
    }
    
  }

  Rack? _getRackData(PalModule rack, ConfigurationProvider provider) {
    var rackTypeUri = rack.parameters.firstWhere((param) => param.xKey == "RackType").value;
    var rackType = provider.getModuleByUri(rackTypeUri);
    var indexingOrientation = rackType.parameters.firstWhere((param) => param.xKey == "IndexingOrientation").value;        
    var type = rackType.name;
    var rows = rackType.parameters.firstWhere((param) => param.xKey == "Rows").value;
    var columns = rackType.parameters.firstWhere((param) => param.xKey == "Columns").value;
    if (indexingOrientation == "2") {
          var slotSpan = rackType.parameters.firstWhere((param) => param.xKey == "SlotSpan").value;
          bool occupiesAll = (slotSpan == "3");          
          return ShiftedRowsRack(
            rackRowsShiftMode: _getRackShiftMode(type), 
            name: rack.name, 
            type: type, 
            rows: int.parse(rows), 
            columns: int.parse(columns), 
            enumerationType: _getRackEnumerationType(type), 
            occupiesAll: occupiesAll
          );
    } else {
          return UnshiftedRowsRack(
            name: rack.name, 
            type: type, 
            rows: int.parse(rows), 
            columns: int.parse(columns),  
            enumerationType: _getRackEnumerationType(type),            
          );
    }
  }

  RackShiftMode _getRackShiftMode(String rackType) {
    if (rackType == "R60") {
      return RackShiftMode.ColumnUp;
    } else {
      return RackShiftMode.RowRight;
    }
  }

  RackEnumerationType _getRackEnumerationType(String rackType) {
    if (rackType == "R60") {
      return RackEnumerationType.TopToBottom;
    } else {
      return RackEnumerationType.LeftToRight;
    }
  }
}