import 'dart:async';
import 'package:flutter/material.dart';

class TimeCounterService {
  Stopwatch watch = Stopwatch();
  Timer? timer;

  final ValueNotifier elapsedTimeNotifier;

  TimeCounterService({required this.elapsedTimeNotifier});

  bool isRunning = false;

  startOrStopTimer() {
    if (isRunning) {
      stopWatch();
    } else {
      startWatch();
    }
  }

  updateTime(Timer timer) {
    if (watch.isRunning) {
      elapsedTimeNotifier.value =
          transformMilliSeconds(watch.elapsedMilliseconds);
    }
  }

  void startWatch() {
    isRunning = true;
    watch.start();
    timer = Timer.periodic(
        const Duration(seconds: 1), updateTime); // Update every second
  }

  void stopWatch() {
    isRunning = false;
    watch.stop();
    timer?.cancel(); // Cancel the timer when stopwatch is stopped
  }

  String transformMilliSecondsToStringFormat(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    int days = (hours / 24).truncate();

    String result = '';

    if (days > 0) {
      result += '${days}d ';
      hours = hours % 24;
    }
    if (hours > 0) {
      result += '${hours}h ';
      minutes = minutes % 60;
    }
    if (minutes > 0) {
      result += '${minutes}m ';
      seconds = seconds % 60;
    }
    result += '${seconds}s';

    return result.trim();
  }

  String transformMilliSeconds(int milliseconds) {
    // Calculate total seconds from milliseconds
    int totalSeconds = (milliseconds / 1000).truncate();

    // Extract minutes and seconds
    int minutes = (totalSeconds / 60).truncate();
    int seconds = (totalSeconds % 60).truncate();

    // Format minutes and seconds with leading zeros for seconds
    String formattedMinutes = minutes.toString();
    String formattedSeconds = seconds.toString().padLeft(2, '0');

    // Combine them into the final string in M:SS format
    String result = '$formattedMinutes:$formattedSeconds';

    return result;
  }
  
  
 static String convertToMinutesSeconds(String timeString) {
    // Split the input string by colons
    List<String> parts = timeString.split(':');

    // Ensure the input string is in the expected format (HH:MM:SS.ssssss)
    if (parts.length >= 3) {
      // Extract the minutes and seconds from the string
      String minutes = parts[1].split('').last;
      String secondsWithMillis = parts[2];

      // Extract the seconds part, removing milliseconds if present
      String seconds = secondsWithMillis.split('.')[0];

      // Combine minutes and seconds into the desired format
      return '$minutes:$seconds';
    }

    // Return the original string if it does not match the expected format
    return timeString;
  }
}
