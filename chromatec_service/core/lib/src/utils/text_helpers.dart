import 'package:intl/intl.dart';

class TextHelper {
  static String cutText(String text, int limit) {
    if (text.length > limit) {
      return "${text.substring(0, limit)}..";
    } else {
      return text;
    }
  }

  static String formatDate(DateTime date) {
    var local = date.toLocal();
    return DateFormat.yMd().format(local);
  }
} 

