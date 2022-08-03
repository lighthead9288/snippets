import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chromatec_pal_support/models/pal_module.dart';
import 'package:chromatec_pal_support/utils/xml.dart';

class PalPspCommunication {
  final String startOfFrame = "[PSPBm]";
  final List<int> endOfFrameBytes = [241, 255];
  Socket? socket;
  Stream<Uint8List>? broadcastStream;
  String? sessionId;
  StreamSubscription<Uint8List>? _subscription;
  Queue<Function> queryModulesQueue = Queue();
  Queue<Function> queryChildRefs = Queue();
  final PalModelsParser _palModelsParser = PalModelsParser();

  void connect({ 
    required String ipAddress, 
    required int? port, 
    required void Function(String modulesSource) onConnectFinish,
    required void Function() onDisconnectFinish,
    required void Function(List<PalModule> modules) onAddModules, 
    required List<PalModule> Function() getModulesList
  }) {
    if (sessionId == null) {
      _connect(ipAddress, port, onConnectFinish, onAddModules, getModulesList);
    } else {
      _disconnect(ipAddress, onDisconnectFinish);
    }
  }
  
  void _connect(
    String ipAddress, 
    int? port, 
    void Function(String modulesSource) onConnectFinish,
    void Function(List<PalModule> modules) onAddModules, 
    List<PalModule> Function() getModulesList
  ) async {   
    List<int> resultArray = [];
    List<int> startOfFrameBytes = utf8.encode(startOfFrame);
    var connectFrame = "<PSPEnvelope>\r\n<PspResource Uri=\"psp://$ipAddress:${port.toString()}/MachineServices/Open?Description=PSP Console;schedulerRole=GC1\"/>\r\n</PSPEnvelope>";
    List<int> connectBytes = utf8.encode(connectFrame);    
    resultArray = resultArray
      ..addAll(startOfFrameBytes)
      ..addAll(connectBytes)
      ..addAll(endOfFrameBytes);

    socket = await Socket.connect(ipAddress, port!);
    broadcastStream = socket?.asBroadcastStream();
    _subscription = broadcastStream?.listen((event) async {
      var xml = XmlParser.fromChars(event);
      sessionId = _palModelsParser.parseSessionId(xml);
      if (sessionId != null) {
        onConnectFinish("${socket?.address.address ?? ''}:${socket?.remotePort.toString()}");     
        await _subscription?.cancel();
        queryModulesQueue = Queue.from([
          () => _queryPalModules('ITool', onAddModules, getModulesList),
          () => _queryPalModules('IInjector', onAddModules, getModulesList),          
          () => _queryPalModules('IAgitator', onAddModules, getModulesList),
          () => _queryPalModules('IRack', onAddModules, getModulesList),
          () => _queryPalModules('SPMEArrowCondDescription', onAddModules, getModulesList),
          () => _queryPalModules('TrayHolderRectangleDescription', onAddModules, getModulesList),
          () => _queryPalModules('IWashStation', onAddModules, getModulesList),
          () => _queryPalModules('GCDescription', onAddModules, getModulesList),
          () => _queryPalModules('RackTypeRectangleDescription', onAddModules, getModulesList)
        ]);
        queryModulesQueue.removeFirst().call();
        
      }
    });  
    socket?.add(resultArray);
  }

  void _disconnect(String ipAddress, void Function() onDisconnectFinish) async {
    List<int> resultArray = [];
    List<int> startOfFrameBytes = utf8.encode(startOfFrame);
    var disconnectFrame = '<PSPEnvelope><PspResource Uri="psp://$ipAddress/MachineServices/Close?clientId=$sessionId" /></PSPEnvelope>';
    List<int> connectBytes = utf8.encode(disconnectFrame);    
    resultArray = resultArray
      ..addAll(startOfFrameBytes)
      ..addAll(connectBytes)
      ..addAll(endOfFrameBytes);
    socket?.add(resultArray);
    _subscription?.cancel();    
    sessionId = null;
    onDisconnectFinish();
  }

  void _queryPalModules(String moduleName, void Function(List<PalModule> modules) onAddModules, List<PalModule> Function() getModulesList) {
    List<int> resultArray = [];
    String queryModuleFrame = '<PSPEnvelope><PspMethod Name="QueryModules" Service="ConfigurationService">'  
      '<Attributes><String>$moduleName</String><Bool>True</Bool><Bool>True</Bool></Attributes></PspMethod></PSPEnvelope>';
    List<int> startOfFrameBytes = utf8.encode(startOfFrame);
    List<int> queryModuleFrameBytes = utf8.encode(queryModuleFrame);
    resultArray = resultArray
      ..addAll(startOfFrameBytes)
      ..addAll(queryModuleFrameBytes)
      ..addAll(endOfFrameBytes);
    var frames = <int>[];
    _subscription = broadcastStream?.listen((frame) async {
      frames.addAll(frame);
      if (_isLastFrame(frame)) {
        var xml = XmlParser.fromChars(Uint8List.fromList(frames));
        frames.clear();
        var newModules = _palModelsParser.parseAllModules(xml);
        onAddModules(newModules);
        await _subscription?.cancel();

        if (queryModulesQueue.isNotEmpty) {
          queryModulesQueue.removeFirst().call();
        } else {
            var modules = getModulesList();
            modules.where((module) => module.childReferences.isNotEmpty).forEach((module) {
              module.childReferences.forEach((childRef) { 
                queryChildRefs.add(() => _queryModuleByUri(childRef, onAddModules)); 
              });
            });
            queryChildRefs.removeFirst().call();
        }
      }     
      
    }); 
    socket?.add(resultArray);
  }

  bool _isLastFrame(Uint8List frame) {
    var reversedByteList = frame.reversed;
    return ((reversedByteList.elementAt(1) == endOfFrameBytes[0]) && (reversedByteList.elementAt(0) == endOfFrameBytes[1]));
  }

  void _queryModuleByUri(String uri, void Function(List<PalModule> modules) onAddModules) {
    List<int> resultArray = [];
    String queryModuleFrame = '<PSPEnvelope><PspMethod Name="GetModule" Service="ConfigurationService">'  
      '<Attributes><Uri>$uri</Uri><Bool>True</Bool><Bool>True</Bool></Attributes></PspMethod></PSPEnvelope>';
    List<int> startOfFrameBytes = utf8.encode(startOfFrame);
    List<int> queryModuleFrameBytes = utf8.encode(queryModuleFrame);
    resultArray = resultArray
      ..addAll(startOfFrameBytes)
      ..addAll(queryModuleFrameBytes)
      ..addAll(endOfFrameBytes);
    _subscription = broadcastStream?.listen((event) async {
      var xml = XmlParser.fromChars(event);
      var newModule = _palModelsParser.parseSearchByIdResult(xml);
      onAddModules([ newModule ]);
      await _subscription?.cancel();

      newModule.childReferences.forEach((childRef) { 
         queryChildRefs.add(() => _queryModuleByUri(childRef, onAddModules)); 
      });

      if (queryChildRefs.isNotEmpty) {
        queryChildRefs.removeFirst().call();
      }
    });    
    socket?.add(resultArray);
  }  
}