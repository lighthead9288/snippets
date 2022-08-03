import 'dart:io';

import 'package:chromatec_pal_support/models/pal_module.dart';
import 'package:chromatec_pal_support/pages/configuration_util/pal_module_nodes.dart';
import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:chromatec_pal_support/widgets/android/android_controls.dart';
import 'package:chromatec_pal_support/widgets/windows/windows_controls.dart';
import 'package:flutter/material.dart';

class ConfigurationUtilPage extends StatefulWidget {
  final ConfigurationProvider provider;

  ConfigurationUtilPage({required this.provider});

  @override
  State<StatefulWidget> createState() => _ConfigurationUtilPageState();
}

class _ConfigurationUtilPageState extends State<ConfigurationUtilPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  
  final List<String> _requiredModulesTypes = [
    "AgitatorDescription", 
    "InjectorDescription", 
    "SPMEArrowCondDescription", 
    "HeatexStirrerDescription",
    "ArrowInjectorDescription",
    "StandardWashStationDescription",
    "ToolLiquidD7_57Description",
    "ToolGas2500Description",
    "ToolSPMEArrowDescription",
    "GCDescription",
    "LCDescription",
    "TrayHolderRectangleDescription"
  ];  
  
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var provider = widget.provider;
    var _filteredModules = _filterRequiredModules(provider.modules);
    var widgetsFactory = (Platform.isWindows) ? WindowsControlsFactory(): AndroidControlsFactory();
    return Scaffold(
      appBar: widgetsFactory.createAppBar().render('Configuration'),
      body: (_filteredModules.isNotEmpty) 
        ? ListView.builder(          
            itemCount: _filteredModules.length,
            itemBuilder: (_context, index) {
              return _moduleCard(_filteredModules[index]);
            }        
          ) 
        : const Center(child: Text('No modules yet'))
    );
  }

  Widget _moduleCard(PalModule module) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(5),
        width: (_deviceWidth > 500) ? 500 : _deviceWidth,
        child: PalModuleParentNode(module: module, provider: widget.provider, deviceWidth: _deviceWidth)
      ),
    );
  }

  List<PalModule> _filterRequiredModules(List<PalModule> modules) {
    return modules.where((module) => _requiredModulesTypes.contains(module.type)).toList();
  }
}