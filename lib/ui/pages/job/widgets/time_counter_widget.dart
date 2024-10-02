import 'dart:async';

import 'package:awesometicks/ui/pages/job/functions/time_counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeCounter extends StatefulWidget {
  const TimeCounter({super.key, required this.elapsedTimeNotifier});
  final ValueNotifier<String> elapsedTimeNotifier;

  @override
  State<TimeCounter> createState() => _TimeCounterState();
}

class _TimeCounterState extends State<TimeCounter> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.elapsedTimeNotifier,
      builder: (context, value, child) {
        return Text(value, style: const TextStyle(fontWeight: FontWeight.bold));
      },
    );
  }
}
