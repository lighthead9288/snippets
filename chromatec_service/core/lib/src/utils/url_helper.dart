import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  static void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}

