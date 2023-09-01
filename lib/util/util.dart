import 'package:intl/intl.dart';

class Util{
  static String convertDateTimeDisplay(String date, [String format = "dd-MMMM-yyyy"]) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat(format);
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  // this is used to set the default date if the date is null
  static DateTime defaultDateIfNull = DateTime(1993, 12, 20, 9, 9, 9, 9, 9);

  // this is used to set the default string if the string is null
  static const String defaultStringIfNull = "";

  // this is used to set the default int if the int is null
  static const int defaultIntIfNull = 0;

  // this is used to set the default double if the double is null
  static const double defaultDoubleIfNull = 0.0;

  static DateTime getCurrentDateWithoutTime() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}