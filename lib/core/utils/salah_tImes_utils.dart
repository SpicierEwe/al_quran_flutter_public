import 'dart:async';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class SalahTimesUtil {
  // calculates the current Salah and the time remaining for the current salah
  static Map<String, Map<String, dynamic>> liveCalculation(
      {required Map salahTimes}) {
    Map<String, dynamic> salahTimesData = salahTimes["times"];

    String currentSalahName = "";
    String timeRemaining = "";
    String salahEndTime = "";
    String nextSalahName = "";
    String nextSalahStartTime = "";
    String nextSalahEndTime = "";

    DateTime currentTime = DateTime.now();
    // DateTime midNightTime = calculateMidnight(salahTimesData: salahTimesData);

    DateTime midNightTime =
        SalahTimesUtil.calculateMidnight(salahTimesData: salahTimesData);
    // print("midnight time $midNightTime --- current time $currentTime");

    for (int i = 0; i < salahTimesData.length; i++) {
      // current Salah
      String salahName = salahTimesData.keys.elementAt(i);
      DateTime salahTime = SalahTimesUtil.convert12hrTo24hr(
          time12hr: salahTimesData.values.elementAt(i));

      // next salah data

      DateTime nextSalahTime24Hr = i == salahTimesData.length - 1
          ? SalahTimesUtil.convert12hrTo24hr(
              time12hr: salahTimesData.values.elementAt(0))
          : SalahTimesUtil.convert12hrTo24hr(
              time12hr: salahTimesData.values.elementAt(i + 1));

      nextSalahName = i == salahTimesData.length - 1
          ? salahTimesData.keys.elementAt(0)
          : salahTimesData.keys.elementAt(i + 1);

      nextSalahStartTime = i == salahTimesData.length - 1
          ? salahTimesData.values.elementAt(0)
          : salahTimesData.values.elementAt(i + 1);

      nextSalahEndTime =
          i == salahTimesData.length - 1 || i == salahTimesData.length - 2
              ? salahTimesData.values.elementAt(0)
              : salahTimesData.values.elementAt(i + 2);

      // ONGOING CURRENT SALAH
      if ((currentTime.isAfter(salahTime) &&
              currentTime.isBefore(nextSalahTime24Hr)) ||
          currentTime.isAtSameMomentAs(nextSalahTime24Hr)) {
        currentSalahName = salahName;
        timeRemaining = SalahTimesUtil.calculateRemainingTime(
            nextSalahTime: nextSalahTime24Hr, currentTime: currentTime);
        salahEndTime =
            DateFormat("h:mm a").format(nextSalahTime24Hr).toString();

        // SPECIAL CASE: Sunrise
        /*
        * The purpose of doing this is cause the sunrise is current even after
        * the current time is past it so we remove it after the current time is past sunrise */
        if (salahName.toLowerCase() == "sunrise" &&
            currentTime.isAfter(salahTime)) {
          currentSalahName = "-";
          timeRemaining = "-";
          salahEndTime = "-";

          nextSalahName = nextSalahName;
          nextSalahEndTime = nextSalahEndTime;
          nextSalahStartTime = calculateRemainingTime(
              nextSalahTime: nextSalahTime24Hr, currentTime: currentTime);

          Logger().i("Sunrise Bloc");
        }

        break; // Exit loop once current Salah is found
      }

      // SPECIAL CASE: Isha ends precisely at midnight
      if (salahName.toLowerCase() == "isha" &&
          currentTime.isBefore(midNightTime)) {
        // print("Isha Bloc");
        // print(" mid night time $midNightTime  --- current time $currentTime");

        currentSalahName = salahName;
        timeRemaining = SalahTimesUtil.calculateRemainingTime(
            nextSalahTime: midNightTime, currentTime: currentTime);
        salahEndTime = DateFormat("h:mm a").format(midNightTime).toString();

        // nextSalahName = "midnight";

        // No remaining time, as next Salah starts immediately after midnight
        break; // Exit loop once current Salah is found

        //   todo check functionality with different times
      }
      // SPECIAL CASE: Qiyam
      /*
      * In this case we check if the currentTime is before the Qiyam time
      * because there is no salah between
      * Midnight and before Qiyam so we return - in places of current salah
      * and Qiyam data as upcoming salah*/
      if (salahName.toLowerCase() == "qiyam" &&
          currentTime.isBefore(salahTime)) {
        currentSalahName = "-";
        timeRemaining = "-";
        salahEndTime = "-";

        nextSalahName = salahName;
        nextSalahEndTime = salahTimesData.values.elementAt(0).toString();
        nextSalahStartTime = DateFormat("h:mm a").format(salahTime).toString();

        break;
      }
    }

    return {
      "current_salah": {
        "name": currentSalahName,
        "time_remaining": timeRemaining,
        "end_time": salahEndTime,
      },
      "upcoming_salah": {
        "name": nextSalahName,
        "start_time": nextSalahStartTime,
        "end_time": nextSalahEndTime,
      },
    };
  }

  static DateTime calculateMidnight(
      {required Map<String, dynamic> salahTimesData}) {
    DateTime fajrTime = convert12hrTo24hr(time12hr: salahTimesData["Fajr"]);
    DateTime ishaTime = convert12hrTo24hr(time12hr: salahTimesData["Isha"]);

    // Calculate the difference between Isha and Fajr
    Duration difference = fajrTime.difference(ishaTime);

    // Calculate the time after adding half of the difference to Isha time
    DateTime midnight = ishaTime.add(difference ~/ 2);

    DateTime midnightInPm = convert12hrTo24hr(
        time12hr: "${DateFormat("h:mm").format(midnight)} PM");

    DateTime midnightInAm = convert12hrTo24hr(
        time12hr: "${DateFormat("h:mm").format(midnight)} AM");

    // Check if midnight falls before 12:00 AM
    // Check if midnight falls before 12:00 AM
    if (midnight.hour >= 0 && midnight.hour < 12) {
      return midnightInPm;
    } else {
      // If midnight falls after 12:00 AM, check if it's after the current time
      DateTime currentTime = DateTime.now();

      if (midnight.isAfter(currentTime)) {
        // If midnight is after the current time, it's on the same day
        return midnightInAm;
      } else {
        // If midnight is before the current time, it's on the next day
        return midnightInAm.add(const Duration(days: 1));
      }
    }
  }

  static String calculateRemainingTime(
      {required DateTime nextSalahTime, required DateTime currentTime}) {
    Duration tr = nextSalahTime.difference(currentTime);

    String hours = tr.inHours.toString().padLeft(1, '0');
    String minutes = (tr.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (tr.inSeconds % 60).toString().padLeft(2, '0');

    String formattedTimeRemaining = '-$hours:$minutes:$seconds';
    return formattedTimeRemaining;
  }

  static DateTime convert12hrTo24hr(
      {required String time12hr, bool nextDay = false}) {
    DateFormat format12hr =
        DateFormat.jm(); // Format for parsing 12-hour time strings
    DateFormat format24hr =
        DateFormat.Hms(); // Format for outputting 24-hour time strings
    DateTime dateTime = format12hr.parse(time12hr);
    if (nextDay) {
      return DateTime.parse(DateFormat("yyyy-MM-dd ")
              .format(DateTime.now().add(const Duration(days: 1))) +
          format24hr.format(dateTime));
    }
    return DateTime.parse(DateFormat("yyyy-MM-dd ").format(DateTime.now()) +
        format24hr.format(dateTime));
  }

  static int dateTimeToTimestamp() {
    // Get the milliseconds since epoch and convert to seconds
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  static DateTime timestampToDateTime({required int timestamp}) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }
}
