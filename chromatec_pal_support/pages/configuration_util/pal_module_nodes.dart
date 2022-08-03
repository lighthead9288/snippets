import 'package:chromatec_pal_support/models/pal_module.dart';
import 'package:chromatec_pal_support/providers/configuration_provider.dart';
import 'package:flutter/material.dart';

class PalModuleChildParameterNode extends StatelessWidget implements Node {
  final PalModuleParameter parameter;
  final double deviceWidth;

  PalModuleChildParameterNode({required this.parameter, required this.deviceWidth});

  @override
  Widget render() {
    return Row(
        children: [
          SizedBox(
            width: deviceWidth / 2,
            child: Text(parameter.xKey),
          ),
          SizedBox(width: deviceWidth * 0.05),
          SizedBox(
            width: deviceWidth / 2,
            child: Text(parameter.value)
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return render();
  }
}

class PalModuleParentNode extends StatelessWidget implements Node {
  final ConfigurationProvider provider;
  final double deviceWidth;
  final PalModule module;

  PalModuleParentNode({required this.module, required this.provider, required this.deviceWidth});

  @override
  Widget render() {
    var params = module.parameters.where((parameter) => (parameter.type != "Uri") && (parameter.type != "Bool")).toList();
    var paramNodes = params.map(
      (param) => PalModuleChildParameterNode(
        parameter: param, 
        deviceWidth: deviceWidth
      )
    ).toList();
    var refNodes = [];
    if (module.childReferences.isNotEmpty) {
      for(var ref in module.childReferences) {
        refNodes.add(
          PalModuleParentNode(
            module: provider.getModuleByUri(ref), 
            provider: provider, 
            deviceWidth: deviceWidth
          )
        );
      }
    }
    var nodes = [ ...paramNodes, ...refNodes ];
    return ExpansionTile(
      controlAffinity: ListTileControlAffinity.leading,
      tilePadding: EdgeInsets.all(0),
      childrenPadding: EdgeInsets.only(left: 10),
      title: Text(module.name, style: TextStyle(fontSize: 14)),
      children: [ 
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: EdgeInsets.all(10),
            width: deviceWidth * 2,
            child: ListView.separated(
              separatorBuilder: (_, index) => Divider(color: Colors.grey[300]),            
              itemCount: nodes.length,
              itemBuilder: (_, index) {
                return nodes[index] as StatelessWidget;
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            )
          )
        ) 
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return render();
  }
}

abstract class Node {
  Widget render();
}