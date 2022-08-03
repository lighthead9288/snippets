import 'package:chromatec_service/features/software_activation/domain/entities/software_license.dart';

class LicenseParser {
  static SoftwareLicense getSoftwareLicenseByUrl(String url) {
    try {
      var linkParts = url.split('?');
      var params = linkParts[1];
      var paramsList = params.split('|');
      return SoftwareLicense(paramsList[0], paramsList[1], paramsList[2], paramsList[3]);
    } catch (e) {
        print(e);
        throw Exception("License parameters parsing error");
    }
  }
}

