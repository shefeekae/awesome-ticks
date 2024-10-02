import 'dart:async';

import 'package:awesometicks/main.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../core/blocs/internet/bloc/internet_available_bloc.dart';

class BaseWidget extends StatelessWidget {
  final Widget child;
  const BaseWidget({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          const PersistentWidget(),
        ],
      ),
    );
  }
}

class PersistentWidget extends StatelessWidget {
  const PersistentWidget({super.key});

  // Connecti
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
      builder: (context, state) {
        bool hasInternet = state.isInternetAvailable;

        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          height: hasInternet ? 0 : 4.h,
          child: Container(
            color: hasInternet ? Colors.green : kBlack,
            child: Center(
              child: Text(
                hasInternet ? "Back online" : 'Offline',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: hasInternet ? kWhite : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
