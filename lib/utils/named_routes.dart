import 'package:awesometicks/ui/pages/assets/details/asset_details_screen.dart';
import 'package:awesometicks/ui/pages/bottomnavbar/bottom_navbar_screen.dart';
import 'package:awesometicks/ui/pages/calendar/job_calendar.dart';
import 'package:awesometicks/ui/pages/home/home_screen.dart';
import 'package:awesometicks/ui/pages/job/job_details.dart';
import 'package:awesometicks/ui/pages/login/login_screen.dart';
import 'package:awesometicks/ui/pages/profile/profile_screen.dart';
import 'package:awesometicks/ui/pages/qr%20scanner/qr_scanner_screen.dart';
import 'package:awesometicks/ui/pages/service%20request/create_service_request.dart';
import 'package:awesometicks/ui/pages/service%20request/details/service_details.dart';
import 'package:awesometicks/ui/pages/service%20request/list/service_list_screen.dart';
import 'package:awesometicks/ui/pages/splash/splash_screen.dart';
import 'package:awesometicks/ui/pages/sync%20progress/sync_progress_screen.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> namedRoutes = {
  LoginScreen.id: (context) => LoginScreen(),
  BottomNavBarScreen.id: (context) => BottomNavBarScreen(),
  HomeScreen.id: (context) => const HomeScreen(),
  CreateOrEditServiceRequestScreen.id: (context) =>
      CreateOrEditServiceRequestScreen(),
  ServiceDetailsScreen.id: (context) => ServiceDetailsScreen(),
  ServiceListScreen.id: (context) => ServiceListScreen(),
  QrScannerScreen.id: (context) => QrScannerScreen(),
  JobDetailsScreen.id: (context) => JobDetailsScreen(),
  JobCalendarScreen.id: (context) => const JobCalendarScreen(),
  SplashScreen.id: (context) => const SplashScreen(),
  ProfileScreen.id: (context) =>  ProfileScreen(),
  SyncProgressScren.id: (context) => SyncProgressScren(),
  AssetDetailsScreen.id: (context) => AssetDetailsScreen(),
};
