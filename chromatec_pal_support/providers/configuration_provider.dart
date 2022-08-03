import 'package:chromatec_pal_support/models/pal_module.dart';
import 'package:chromatec_pal_support/utils/pal_psp_communication.dart';
import 'package:chromatec_pal_support/utils/xml.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ConfigurationProvider extends ChangeNotifier {
  static ConfigurationProvider instance = ConfigurationProvider();
  List<PalModule> modules = [];
  String ipAddress = "";
  int? port;
  bool isConnected = false;
  String modulesSource = "";  
  final PalModelsParser _palModelsParser = PalModelsParser();
  final PalPspCommunication _palPspCommunication = PalPspCommunication();

  void onConnect() async {
    _palPspCommunication.connect(
      ipAddress: ipAddress, 
      port: port, 
      onConnectFinish: (source) { 
        modulesSource = source;
        isConnected = true;        
        notifyListeners();
      }, 
      onDisconnectFinish: () { 
        ipAddress = "";
        port = null;
        modulesSource = "";
        modules.clear();
        isConnected = false;
        notifyListeners();
      }, 
      onAddModules: (modules) { 
        _addNewModules(modules);
      }, 
      getModulesList: () => modules
    );
  }

  void onPickConfig() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [ 'xml' ]
    );

    if (result != null) {
      modulesSource = result.files.first.name;
      var xml = XmlParser.fromFile(result);
      modules = _palModelsParser.parseAllModules(xml);
      notifyListeners();
    }
  }  

  PalModule getModuleByUri(String uri) => modules.firstWhere((module) => module.reference == uri);

  void _addNewModules(List<PalModule> newModules) {
    for (var module in newModules) { 
      if (modules.where((item) => item.reference == module.reference).isEmpty) {
        modules.add(module);
      }
    }
  }
}