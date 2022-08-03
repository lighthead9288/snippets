import 'dart:io';
import 'dart:typed_data';

import 'package:chromatec_pal_support/models/pal_method.dart';
import 'package:chromatec_pal_support/models/pal_module.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';

class PalModelsParser {

  String? parseSessionId(XmlDocument document) {
    var rootElement = document.rootElement;
    var element = rootElement.getElement("PspResourceResponse");
    if (element != null) {
      return element.getAttribute("Result")!;
    }
  }
  
  List<PalModule> parseAllModules(XmlDocument document) {
    var modules = document.findAllElements("Module").toList();
    return modules.map((module) {
      var xns = module.getAttribute("xNS");
      return _parsePalModule(module, xns);
    }).toList();
  }

  PalModule parseSearchByIdResult(XmlDocument document) {
    var module = document.findAllElements("Result").first;
    var xt = module.getAttribute('xT');
    return _parsePalModule(module, xt);
  }

  PalModule _parsePalModule(XmlElement module, String? xns) {
    var type = module.getAttribute("Type");
    var name = module.getAttribute("Name");
    var reference = module.getAttribute("Reference");
    var parametersElement = module.findAllElements("Parameters").toList().first;
    var parameters = parametersElement.childElements.map((child) {
      var xKey = child.getAttribute("xKey");
      var value = child.innerText;
      var type = child.name.local;
      return PalModuleParameter(xKey: xKey!, value: value, type: type);
    }).toList();
    List<String> childRefs = [];
    var childRefsElement = module.findAllElements("ChildReferences").toList();
    if (childRefsElement.isNotEmpty) {
      childRefs = childRefsElement.first.childElements.map((child) => child.innerText).toList();
    }
    return PalModule(xNs: xns!, type: type!, name: name!, reference: reference!, parameters: parameters, childReferences: childRefs);
  }

  PalLiquidMethod getPalLiquidMethod(XmlDocument xml) {
    return PalLiquidMethod(
        methodName: _getXmlElementStringValueByName(xml.rootElement, "MethodName")!,
        description: _getXmlElementStringValueByName(xml.rootElement, "Description")!,
        setupParamsGroup: PalLiquidMethodSetupParamsGroup(
            syringeTool: _getXmlElementStringValueByName(xml.rootElement, "SelectedSyringe")!,
            gc: _getXmlElementStringValueByName(xml.rootElement, "SelectedGC")!,
            syringeTools: _getXmlElementListValueByName(xml.rootElement, "Syringes"),
            gcs: _getXmlElementListValueByName(xml.rootElement, "GCList")),
        preWashParamsGroup: PalLiquidPreWashParamsGroup(
          preWashSolventVolume: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PreWashSolventVolume")!),
          preWashCycles: int.parse(_getXmlElementStringValueByName(xml.rootElement, "PreWashCycles")!),
          preWashSolventPositionStep1: _getXmlElementStringValueByName(
            xml.rootElement, 
            "PreWashSolventPositionStep1")!.toLowerCase() == 'true',
          preWashSolventPositionStep2: _getXmlElementStringValueByName(
            xml.rootElement, 
            "PreWashSolventPositionStep2")!.toLowerCase() == 'true',
          preWashSolventPositionStep3: _getXmlElementStringValueByName(
            xml.rootElement, 
            "PreWashSolventPositionStep3")!.toLowerCase() == 'true',
          preWashSolventPositionStep4: _getXmlElementStringValueByName(
            xml.rootElement, 
            "PreWashSolventPositionStep4")!.toLowerCase() == 'true',   
            washStations: _getXmlElementListValueByName(xml.rootElement, "WashStations"
          ),
          selectedPreWashStation: _getXmlElementStringValueByName(xml.rootElement, "SelectedPreWashStation")!,
          wastePortDepth: double.parse(_getXmlElementStringValueByName(xml.rootElement, "WastePortDepth")!),
          washVialDepth: double.parse(_getXmlElementStringValueByName(xml.rootElement, "WashVialDepth")!),
          preWashAspirateFlowRate: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PreWashAspirateFlowRate")!),
        ),
        loadSampleParamsGroup: PalLiquidLoadSampleParamsGroup(
            sampleVolume: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleVolume")!),
            sampleVialDepth: int.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleVialDepth")!),
            airGapVolume: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PreWashSolventVolume")!),
            sampleRinseCycles: int.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleRinseCycles")!),
            sampleRinseVolume: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleRinseVolume")!),
            bottomSenseSampleVial: _getXmlElementStringValueByName(xml.rootElement, "BottomSenseSampleVial")!.toLowerCase() == 'true',
            heightFromBottomSampleVial: double.parse(_getXmlElementStringValueByName(xml.rootElement, "HeightFromBottomSampleVial")!),
            samplePostAspirateDelay: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SamplePostAspirateDelay")!),
            fillingStrokesCount: int.parse(_getXmlElementStringValueByName(xml.rootElement, "FillingStrokesCount")!),
            fillingStrokesVolume: double.parse(_getXmlElementStringValueByName(xml.rootElement, "FillingStrokesVolume")!),
            fillingStrokesAspirateFlowRate: double.parse(_getXmlElementStringValueByName(xml.rootElement, "FillingStrokesAspirateFlowRate")!),
            fillingStrokesPostDispenseDelay: double.parse(_getXmlElementStringValueByName(xml.rootElement, "FillingStrokesPostDispenseDelay")!),
            delayAfterFillingStrokes: double.parse(_getXmlElementStringValueByName(xml.rootElement, "DelayAfterFillingStrokes")!),
            sampleAspirateFlowRate: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleAspirateFlowRate")!),
            sampleVialPenetrationSpeed: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleVialPenetrationSpeed")!)),
        injectSampleParamsGroup: PalLiquidInjectSampleParamsGroup(
          injectors: _getXmlElementListValueByName(xml.rootElement, "Injectors"), 
          selectedInjector: _getXmlElementStringValueByName(xml.rootElement, "SelectedInjector")!, 
          injectionMode: _getXmlElementStringValueByName(xml.rootElement, "InjectionMode")!, 
          injectionSignalMode: _getXmlElementStringValueByName(xml.rootElement, "InjectionSignalMode")!, 
          injectionFlowRate: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InjectionFlowRate")!), 
          injectorPenetrationDepth: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InjectorPenetrationDepth")!), 
          injectorPenetrationSpeed: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InjectorPenetrationSpeed")!), 
          preInjectionDwellTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PreInjectionDwellTime")!), 
          postInjectionDwellTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PostInjectionDwellTime")!)
        ),
        postWashParamsGroup: PalLiquidPostWashParamsGroup(
          postWashSolventVolume: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PostWashSolventVolume")!), 
          postWashCycles: int.parse(_getXmlElementStringValueByName(xml.rootElement, "PostWashCycles")!), 
          postWashSolventPositionStep1: _getXmlElementStringValueByName(xml.rootElement, "PostWashSolventPositionStep1")!.toLowerCase() == 'true', 
          postWashSolventPositionStep2: _getXmlElementStringValueByName(xml.rootElement, "PostWashSolventPositionStep2")!.toLowerCase() == 'true', 
          postWashSolventPositionStep3: _getXmlElementStringValueByName(xml.rootElement, "PostWashSolventPositionStep3")!.toLowerCase() == 'true', 
          postWashSolventPositionStep4: _getXmlElementStringValueByName(xml.rootElement, "PostWashSolventPositionStep4")!.toLowerCase() == 'true', 
          washStations: _getXmlElementListValueByName(xml.rootElement, "WashStations"), 
          selectedPostWashStation: _getXmlElementStringValueByName(xml.rootElement, "SelectedPostWashStation")!, 
          postWashAspirateFlowRate: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PostWashAspirateFlowRate")!))
        );
  }

  PalHeadspaceMethod getPalHeadspaceMethod(XmlDocument xml) {
    return PalHeadspaceMethod(
        methodName: _getXmlElementStringValueByName(xml.rootElement, "MethodName")!,
        description: _getXmlElementStringValueByName(xml.rootElement, "Description")!,
        setupParamsGroup: PalHeadspaceSetupParamsGroup(
            syringes: _getXmlElementListValueByName(xml.rootElement, "Syringes"),
            selectedSyringe: _getXmlElementStringValueByName(
                xml.rootElement, "SelectedSyringe")!,
            gcList: _getXmlElementListValueByName(xml.rootElement, "GCList"),
            selectedGC: _getXmlElementStringValueByName(xml.rootElement, "SelectedGC")!,
            analysisTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "AnalysisTime")!),
            syncBeforeIncubationEndTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SyncBeforeIncubationEndTime")!)),
        incubateSampleParamsGroup: PalHeadspaceIncubateSampleParamsGroup(
            incubationTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "IncubationTime")!),
            incubationTemperature: double.parse(_getXmlElementStringValueByName(xml.rootElement, "IncubationTemperature")!),
            agitators: _getXmlElementListValueByName(xml.rootElement, "Agitators"),
            selectedAgitator: _getXmlElementStringValueByName(xml.rootElement, "SelectedAgitator")!,
            heatAgitator: _getXmlElementStringValueByName(xml.rootElement, "HeatAgitator")!.toLowerCase() == 'true',
            waitForReadinessAgitator: _getXmlElementStringValueByName(xml.rootElement, "WaitForReadinessAgitator")!.toLowerCase() == 'true',
            agitatorSpeed: double.parse(_getXmlElementStringValueByName(xml.rootElement, "AgitatorSpeed")!),
            agitatorOnTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "AgitatorOnTime")!),
            agitatorOffTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "AgitatorOffTime")!)),
        prePurgeSyringeParamsGroup: PalHeadspacePrePurgeSyringeParamsGroup(
          preInjectionPurgeTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PreInjectionPurgeTime")!)
        ),
        loadSampleParamsGroup: PalHeadspaceLoadSampleParamsGroup(
          sampleVialDepth: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleVialDepth")!), 
          sampleVolume: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleVolume")!), 
          sampleAspirateFlowRate: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleAspirateFlowRate")!), 
          enablePreFilling: _getXmlElementStringValueByName(xml.rootElement, "EnablePreFilling")!.toLowerCase() == 'true', 
          syringeTemperature: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SyringeTemperature")!), 
          heatSyringe: _getXmlElementStringValueByName(xml.rootElement, "HeatSyringe")!.toLowerCase() == 'true', 
          waitForReadinessSyringe: _getXmlElementStringValueByName(xml.rootElement, "WaitForReadinessSyringe")!.toLowerCase() == 'true', 
          fillingStrokesCount: int.parse(_getXmlElementStringValueByName(xml.rootElement, "FillingStrokesCount")!), 
          fillingStrokesVolume: double.parse(_getXmlElementStringValueByName(xml.rootElement, "FillingStrokesVolume")!), 
          fillingStrokesAspirateFlowRate: double.parse(_getXmlElementStringValueByName(xml.rootElement, "FillingStrokesAspirateFlowRate")!), 
          delayAfterFillingStrokes: double.parse(_getXmlElementStringValueByName(xml.rootElement, "DelayAfterFillingStrokes")!), 
          samplePostAspirateDelay: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SamplePostAspirateDelay")!), 
          sampleVialPenetrationSpeed: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleVialPenetrationSpeed")!)
        ),
        injectSampleParamsGroup: PalHeadspaceInjectSampleParamsGroup(
          injectionFlowRate: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InjectionFlowRate")!), 
          injectorPenetrationDepth: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InjectorPenetrationDepth")!), 
          injectionSignalMode: _getXmlElementStringValueByName(xml.rootElement, "InjectionSignalMode")!, 
          injectors: _getXmlElementListValueByName(xml.rootElement, "Injectors"), 
          selectedInjector: _getXmlElementStringValueByName(xml.rootElement, "SelectedInjector")!, 
          injectorPenetrationSpeed: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InjectorPenetrationSpeed")!), 
          preInjectionDwellTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PreInjectionDwellTime")!), 
          postInjectionDwellTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PostInjectionDwellTime")!)
        ),
        postPurgeSyringeParamsGroup: PalHeadspacePostPurgeSyringeParamsGroup(
          postInjectionPurgeTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PostInjectionPurgeTime")!), 
          continiousPurge: _getXmlElementStringValueByName(xml.rootElement, "ContiniousPurge")!.toLowerCase() == 'true')
        );
  }

  PalSPMEMethod getPalSPMEMethod(XmlDocument xml) {
    return PalSPMEMethod(
        methodName: _getXmlElementStringValueByName(xml.rootElement, "MethodName")!,
        description: _getXmlElementStringValueByName(xml.rootElement, "Description")!,
        setupParams: PalSPMESetupParams(
            syringes: _getXmlElementListValueByName(xml.rootElement, "Syringes"),
            selectedSyringe: _getXmlElementStringValueByName(xml.rootElement, "SelectedSyringe")!,
            gcList: _getXmlElementListValueByName(xml.rootElement, "GCList"),
            selectedGC: _getXmlElementStringValueByName(xml.rootElement, "SelectedGC")!,
            analysisTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "AnalysisTime")!),
            syncBeforeExtractionEndTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SyncBeforeExtractionEndTime")!)),
        preConditionFiberParamsGroup: PalSPMEPreConditionFiberParamsGroup(
            preconditioningTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PreconditioningTime")!),
            conditioningTemperature: double.parse(_getXmlElementStringValueByName(xml.rootElement, "ConditioningTemperature")!),
            conditioningPorts: _getXmlElementListValueByName(xml.rootElement, "ConditioningPorts"),
            selectedConditioningPort: _getXmlElementStringValueByName(xml.rootElement, "SelectedConditioningPort")!),
        incubateSampleParamsGroup: PalSPMEIncubateSampleParamsGroup(
            incubationTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "IncubationTime")!),
            incubationTemperature: double.parse(_getXmlElementStringValueByName(xml.rootElement, "IncubationTemperature")!),
            agitators: _getXmlElementListValueByName(xml.rootElement, "Agitators"),
            selectedAgitator: _getXmlElementStringValueByName(xml.rootElement, "SelectedAgitator")!,
            doAgitation: _getXmlElementStringValueByName(xml.rootElement, "DoAgitation")!.toLowerCase() == 'true',
            heatAgitator: _getXmlElementStringValueByName(xml.rootElement, "HeatAgitator")!.toLowerCase() == 'true',
            waitForReadinessAgitator: _getXmlElementStringValueByName(xml.rootElement, "WaitForReadinessAgitator")!.toLowerCase() == 'true',
            agitatorOnTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "AgitatorOnTime")!),
            agitatorOffTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "AgitatorOffTime")!)),
        loadSampleParamsGroup: PalSPMELoadSampleParamsGroup(
          sampleExtractTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleExtractTime")!), 
          sampleVialDepth: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleVialDepth")!), 
          internalStdAdsorbTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InternalStdAdsorbTime")!), 
          internalStdStations: _getXmlElementListValueByName(xml.rootElement, "InternalStdStations"), 
          selectedInternalStdStation: _getXmlElementStringValueByName(xml.rootElement, "SelectedInternalStdStation")!, 
          internalStdPosition: int.parse(_getXmlElementStringValueByName(xml.rootElement, "InternalStdPosition")!), 
          internalStdPenetrationDepth: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InternalStdPenetrationDepth")!), 
          sampleVialPenetrationSpeed: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleVialPenetrationSpeed")!)
        ),
        injectSampleParamsGroup: PalSPMEInjectSampleParamsGroup(
          sampleDesorbTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "SampleDesorbTime")!), 
          injectorPenetrationDepth: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InjectorPenetrationDepth")!), 
          injectionSignalMode: _getXmlElementStringValueByName(xml.rootElement, "InjectionSignalMode")!, 
          injectors: _getXmlElementListValueByName(xml.rootElement, "Injectors"), 
          selectedInjector: _getXmlElementStringValueByName(xml.rootElement, "SelectedInjector")!, 
          injectorPenetrationSpeed: double.parse(_getXmlElementStringValueByName(xml.rootElement, "InjectorPenetrationSpeed")!)
        ),
        postConditionFiber: PalSPMEPostConditionFiber(
          postConditioningTime: double.parse(_getXmlElementStringValueByName(xml.rootElement, "PostConditioningTime")!)
        )
      );
  }

  String? _getXmlElementStringValueByName(XmlElement rootElement, String paramName) {
    var element = rootElement.getElement(paramName);
    if (element == null) {
      return "";
    }
    return element.innerText;
  }

  List<String> _getXmlElementListValueByName(XmlElement rootElement, String paramName) {
    var listElement = rootElement.getElement(paramName);
    if (listElement == null) {
      return [];
    }
    return listElement.childElements.map((element) => element.innerText).toList();
  }
}


class XmlParser {
  static XmlDocument fromFile(FilePickerResult result) {
    File file;
    if (kIsWeb) {
      final fileBytes = result.files.first.bytes;
      file = File.fromRawPath(fileBytes!);
      return XmlDocument.parse(file.path);
    } else {
      file = File(result.files.single.path!);
      return XmlDocument.parse(file.readAsStringSync());
    }
  }

  static XmlDocument fromChars(Uint8List chars) {
    var decoded = String.fromCharCodes(chars);
    decoded = decoded.substring(7);
    decoded = decoded.substring(0, decoded.length - 2);
    return XmlDocument.parse(decoded);
  }
}


