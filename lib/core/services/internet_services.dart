import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/internet/bloc/internet_available_bloc.dart';

class InterNetServices {
  static StreamSubscription<ConnectivityResult>? internetStreamSubscription;

  Future<bool> checkInternetConnectivity() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }

    return false;
  }

  void addValueToInternetState(BuildContext context) async {
    InternetAvailableBloc internetAvailableBloc =
        BlocProvider.of<InternetAvailableBloc>(context);

    bool hasInternet = await InterNetServices().checkInternetConnectivity();
    internetAvailableBloc
        .add(ChangeInternetAvailablity(available: hasInternet));
  }

  void cancelListenInternetAvailablity() {}
}
