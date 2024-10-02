import 'dart:async';
import 'package:awesometicks/ui/pages/bottomnavbar/bottom_navbar_screen.dart';
import 'package:awesometicks/ui/pages/splash/widgets/splash_widget.dart';
import 'package:flutter/material.dart';
import 'package:secure_storage/secure_storage.dart';
import '../../../core/services/syncing_services.dart';
import '../login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String id = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    handlingInitState();
    // TODO: implement initState
    super.initState();
  }

  handlingInitState() async {
    bool rememberMe = await StorageServices().getRememberMe();

    Future.delayed(const Duration(milliseconds: 500), () {
      String id = rememberMe ? BottomNavBarScreen.id : LoginScreen.id;

      Navigator.of(context).pushReplacementNamed(id);
    });
    // ignore: use_build_context_synchronously
    SyncingServices().listenForInternet(context);
  }

  @override
  Widget build(BuildContext context) {
    return const SplashWidget();
  }
}
